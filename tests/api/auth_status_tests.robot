*** Settings ***
Documentation    Test suite for authentication and status code handling
Resource         ../resources/common_keywords.resource
Library          FakerLibrary    WITH NAME    Faker
Suite Setup      Setup Test Environment
Suite Teardown   Teardown Test Environment
Test Tags        auth    status_codes    api_testing

*** Variables ***
${SUITE_NAME}    AuthAndStatus

*** Test Cases ***
Test Basic Authentication Success
    [Documentation]    Test successful basic authentication
    [Tags]    basic_auth    success    smoke
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Define credentials
    ${username}=    Set Variable    testuser
    ${password}=    Set Variable    testpass
    
    # Create auth tuple
    ${auth}=    Create List    ${username}    ${password}
    
    # Execute request with authentication
    ${response}=    GET    /basic-auth/${username}/${password}    auth=${auth}    expected_status=200
    
    # Validate successful authentication
    Validate Response Status    ${response}    200
    ${json_data}=    Set Variable    ${response.json()}
    Should Be True    ${json_data['authenticated']}
    Should Be Equal    ${json_data['user']}    ${username}
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Basic Authentication Success    ${SUITE_NAME}    PASS    ${duration}

Test Basic Authentication Failure
    [Documentation]    Test failed basic authentication
    [Tags]    basic_auth    failure
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Use wrong credentials
    ${auth}=    Create List    wronguser    wrongpass
    
    # Execute request expecting 401
    ${response}=    GET    /basic-auth/testuser/testpass    auth=${auth}    expected_status=401
    
    # Validate authentication failure
    Validate Response Status    ${response}    401
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Basic Authentication Failure    ${SUITE_NAME}    PASS    ${duration}

Test Bearer Token Authentication
    [Documentation]    Test bearer token authentication
    [Tags]    bearer_auth    token
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate random token
    ${token}=    Set Variable    ${Faker.UUID4}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    
    # Execute request with bearer token
    ${response}=    GET    /bearer    headers=${headers}    expected_status=200
    
    # Validate token authentication
    Validate Response Status    ${response}    200
    ${json_data}=    Set Variable    ${response.json()}
    Should Be True    ${json_data['authenticated']}
    Should Be Equal    ${json_data['token']}    ${token}
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Bearer Token Authentication    ${SUITE_NAME}    PASS    ${duration}

Test Status Code 200 OK
    [Documentation]    Test 200 OK status code
    [Tags]    status_200    success
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    ${response}=    GET    /status/200    expected_status=200
    Validate Response Status    ${response}    200
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Status Code 200 OK    ${SUITE_NAME}    PASS    ${duration}

Test Status Code 201 Created
    [Documentation]    Test 201 Created status code
    [Tags]    status_201    created
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    ${response}=    POST    /status/201    expected_status=201
    Validate Response Status    ${response}    201
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Status Code 201 Created    ${SUITE_NAME}    PASS    ${duration}

Test Status Code 400 Bad Request
    [Documentation]    Test 400 Bad Request status code
    [Tags]    status_400    client_error
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    ${response}=    GET    /status/400    expected_status=400
    Validate Response Status    ${response}    400
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Status Code 400 Bad Request    ${SUITE_NAME}    PASS    ${duration}

Test Status Code 401 Unauthorized
    [Documentation]    Test 401 Unauthorized status code
    [Tags]    status_401    unauthorized
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    ${response}=    GET    /status/401    expected_status=401
    Validate Response Status    ${response}    401
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Status Code 401 Unauthorized    ${SUITE_NAME}    PASS    ${duration}

Test Status Code 404 Not Found
    [Documentation]    Test 404 Not Found status code
    [Tags]    status_404    not_found
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    ${response}=    GET    /status/404    expected_status=404
    Validate Response Status    ${response}    404
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Status Code 404 Not Found    ${SUITE_NAME}    PASS    ${duration}

Test Status Code 500 Internal Server Error
    [Documentation]    Test 500 Internal Server Error status code
    [Tags]    status_500    server_error
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    ${response}=    GET    /status/500    expected_status=500
    Validate Response Status    ${response}    500
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Status Code 500 Internal Server Error    ${SUITE_NAME}    PASS    ${duration}

Test Random Status Codes
    [Documentation]    Test multiple random status codes
    [Tags]    status_random    multiple
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Test multiple status codes in one request
    ${status_codes}=    Set Variable    200,201,202
    ${response}=    GET    /status/${status_codes}    expected_status=any
    
    # Validate response has one of the expected status codes
    ${status_list}=    Create List    200    201    202
    Should Contain    ${status_list}    ${response.status_code}
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Random Status Codes    ${SUITE_NAME}    PASS    ${duration}
