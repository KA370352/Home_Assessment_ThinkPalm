*** Settings ***
Documentation    Test suite for HTTP methods using httpbin.org
Resource         ../resources/common_keywords.resource
Library          FakerLibrary    WITH NAME    Faker
Suite Setup      Setup Test Environment
Suite Teardown   Teardown Test Environment
Test Tags        http_methods    api_testing

*** Variables ***
${SUITE_NAME}    HTTPMethods

*** Test Cases ***
Test GET Request With Parameters
    [Documentation]    Test GET request with query parameters
    [Tags]    get    parameters    smoke
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate test data
    ${user_data}=    Generate Random User Data
    ${params}=    Create Dictionary    name=${user_data['name']}    email=${user_data['email']}
    
    # Execute request
    ${response}=    GET    /get    params=${params}    expected_status=200
    
    # Validate response
    Validate Response Status    ${response}    200
    Validate JSON Response Structure    ${response}    args    headers    origin    url
    
    # Validate parameters were sent correctly
    ${json_data}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json_data['args']}    name
    Dictionary Should Contain Key    ${json_data['args']}    email
    Should Be Equal    ${json_data['args']['name']}    ${user_data['name']}
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test GET Request With Parameters    ${SUITE_NAME}    PASS    ${duration}
    
    Log Response Details    ${response}

Test POST Request With JSON Data
    [Documentation]    Test POST request with JSON payload
    [Tags]    post    json    smoke
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate test data
    ${api_data}=    Generate Random API Test Data
    ${headers}=    Generate Test Headers
    Set To Dictionary    ${headers}    Content-Type=application/json
    
    # Execute request
    ${response}=    POST    /post    json=${api_data}    headers=${headers}    expected_status=200
    
    # Validate response
    Validate Response Status    ${response}    200
    Validate JSON Response Structure    ${response}    json    data    headers    origin    url
    
    # Validate JSON data was sent correctly
    ${json_data}=    Set Variable    ${response.json()}
    Dictionaries Should Be Equal    ${json_data['json']}    ${api_data}
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test POST Request With JSON Data    ${SUITE_NAME}    PASS    ${duration}
    
    Log Response Details    ${response}

Test PUT Request With Form Data
    [Documentation]    Test PUT request with form data
    [Tags]    put    form_data
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate test data
    ${form_data}=    Create Dictionary
    ...    field1=${Faker.Word}
    ...    field2=${Faker.Random Int    min=1    max=100}
    ...    field3=${Faker.Boolean}
    
    # Execute request
    ${response}=    PUT    /put    data=${form_data}    expected_status=200
    
    # Validate response
    Validate Response Status    ${response}    200
    Validate JSON Response Structure    ${response}    form    headers    origin    url
    
    # Validate form data was sent correctly
    ${json_data}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json_data['form']}    field1
    Dictionary Should Contain Key    ${json_data['form']}    field2
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test PUT Request With Form Data    ${SUITE_NAME}    PASS    ${duration}

Test PATCH Request
    [Documentation]    Test PATCH request functionality
    [Tags]    patch
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate test data
    ${patch_data}=    Generate API Payload    complexity=medium
    
    # Execute request
    ${response}=    PATCH    /patch    json=${patch_data}    expected_status=200
    
    # Validate response
    Validate Response Status    ${response}    200
    Validate JSON Response Structure    ${response}    json    headers    origin    url
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test PATCH Request    ${SUITE_NAME}    PASS    ${duration}

Test DELETE Request
    [Documentation]    Test DELETE request functionality
    [Tags]    delete
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Execute request
    ${response}=    DELETE    /delete    expected_status=200
    
    # Validate response
    Validate Response Status    ${response}    200
    Validate JSON Response Structure    ${response}    headers    origin    url
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test DELETE Request    ${SUITE_NAME}    PASS    ${duration}

Test HTTP Headers Inspection
    [Documentation]    Test request header inspection
    [Tags]    headers    inspection
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate custom headers
    ${custom_headers}=    Generate Test Headers
    Set To Dictionary    ${custom_headers}    X-Test-Suite=Robot-Framework    X-Test-ID=${Faker.UUID4}
    
    # Execute request
    ${response}=    GET    /headers    headers=${custom_headers}    expected_status=200
    
    # Validate response
    Validate Response Status    ${response}    200
    Validate JSON Response Structure    ${response}    headers
    
    # Validate custom headers were sent
    ${json_data}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json_data['headers']}    X-Test-Suite
    Should Be Equal    ${json_data['headers']['X-Test-Suite']}    Robot-Framework
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test HTTP Headers Inspection    ${SUITE_NAME}    PASS    ${duration}

Test User Agent Detection
    [Documentation]    Test user agent detection functionality
    [Tags]    user_agent    inspection
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate custom user agent
    ${user_agent}=    Set Variable    Robot-Framework-Test-Agent/1.0
    ${headers}=    Create Dictionary    User-Agent=${user_agent}
    
    # Execute request
    ${response}=    GET    /user-agent    headers=${headers}    expected_status=200
    
    # Validate response
    Validate Response Status    ${response}    200
    ${json_data}=    Set Variable    ${response.json()}
    Should Be Equal    ${json_data['user-agent']}    ${user_agent}
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test User Agent Detection    ${SUITE_NAME}    PASS    ${duration}
