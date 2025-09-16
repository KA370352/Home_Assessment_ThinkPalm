*** Settings ***
Documentation    Test suite for dynamic data generation and handling
Resource         ../resources/common_keywords.resource
Library          FakerLibrary    WITH NAME    Faker
Suite Setup      Setup Test Environment
Suite Teardown   Teardown Test Environment
Test Tags        dynamic_data    api_testing

*** Variables ***
${SUITE_NAME}    DynamicData

*** Test Cases ***
Test Dynamic Data Generation
    [Documentation]    Test dynamic data generation using Faker
    [Tags]    faker    dynamic    smoke
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate dynamic user data
    ${user_data}=    Generate Random User Data
    
    # Test with generated data
    ${params}=    Create Dictionary
    ...    name=${user_data['name']}
    ...    email=${user_data['email']}
    ...    uuid=${user_data['uuid']}
    
    ${response}=    GET    /get    params=${params}    expected_status=200
    
    # Validate dynamic data was used correctly
    ${json_data}=    Set Variable    ${response.json()}
    Should Be Equal    ${json_data['args']['name']}    ${user_data['name']}
    Should Be Equal    ${json_data['args']['email']}    ${user_data['email']}
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Dynamic Data Generation    ${SUITE_NAME}    PASS    ${duration}

Test UUID Generation and Validation
    [Documentation]    Test UUID generation and validation in requests
    [Tags]    uuid    validation
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate UUID using httpbin
    ${response}=    GET    /uuid    expected_status=200
    ${json_data}=    Set Variable    ${response.json()}
    ${generated_uuid}=    Set Variable    ${json_data['uuid']}
    
    # Validate UUID format
    Should Match Regexp    ${generated_uuid}    ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$
    
    # Use UUID in subsequent request
    ${headers}=    Create Dictionary    X-Request-ID=${generated_uuid}
    ${response2}=    GET    /headers    headers=${headers}    expected_status=200
    
    ${json_data2}=    Set Variable    ${response2.json()}
    Should Be Equal    ${json_data2['headers']['X-Request-Id']}    ${generated_uuid}
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test UUID Generation and Validation    ${SUITE_NAME}    PASS    ${duration}

Test Base64 Encoding Decoding
    [Documentation]    Test base64 encoding and decoding functionality
    [Tags]    base64    encoding
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate random string to encode
    ${original_string}=    Set Variable    ${Faker.Text    max_nb_chars=50}
    ${encoded_string}=    Evaluate    base64.b64encode($original_string.encode()).decode()    base64
    
    # Test decoding via httpbin
    ${response}=    GET    /base64/${encoded_string}    expected_status=200
    
    # Validate decoded content
    Should Be Equal    ${response.text}    ${original_string}
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Base64 Encoding Decoding    ${SUITE_NAME}    PASS    ${duration}

Test Random Bytes Generation
    [Documentation]    Test random bytes generation endpoint
    [Tags]    bytes    random
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate random number of bytes to request
    ${num_bytes}=    Set Variable    ${Faker.Random Int    min=10    max=100}
    
    # Request random bytes
    ${response}=    GET    /bytes/${num_bytes}    expected_status=200
    
    # Validate response length
    ${content_length}=    Get Length    ${response.content}
    Should Be Equal As Numbers    ${content_length}    ${num_bytes}
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Random Bytes Generation    ${SUITE_NAME}    PASS    ${duration}

Test Delayed Response Handling
    [Documentation]    Test handling of delayed responses
    [Tags]    delay    timeout
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Test with 2 second delay
    ${delay_seconds}=    Set Variable    2
    ${response}=    GET    /delay/${delay_seconds}    expected_status=200
    
    # Validate response contains delay information
    ${json_data}=    Set Variable    ${response.json()}
    Validate JSON Response Structure    ${response}    args    headers    origin    url
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Should Be True    ${duration} >= ${delay_seconds}
    Record Test Metrics    Test Delayed Response Handling    ${SUITE_NAME}    PASS    ${duration}

Test Stream Response Processing
    [Documentation]    Test streaming response processing
    [Tags]    stream    processing
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Request streaming data
    ${num_lines}=    Set Variable    5
    ${response}=    GET    /stream/${num_lines}    expected_status=200
    
    # Validate streaming response
    ${lines}=    Split String    ${response.text}    ${
}
    ${actual_lines}=    Get Length    ${lines}
    Should Be True    ${actual_lines} >= ${num_lines}
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Stream Response Processing    ${SUITE_NAME}    PASS    ${duration}

Test Dynamic Payload Complexity
    [Documentation]    Test different complexity levels of dynamic payloads
    [Tags]    payload    complexity
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Test simple payload
    ${simple_payload}=    Generate API Payload    complexity=simple
    ${response1}=    POST    /post    json=${simple_payload}    expected_status=200
    
    # Test medium payload  
    ${medium_payload}=    Generate API Payload    complexity=medium
    ${response2}=    POST    /post    json=${medium_payload}    expected_status=200
    
    # Test complex payload
    ${complex_payload}=    Generate API Payload    complexity=complex
    ${response3}=    POST    /post    json=${complex_payload}    expected_status=200
    
    # Validate all payloads were processed correctly
    FOR    ${response}    IN    ${response1}    ${response2}    ${response3}
        Validate Response Status    ${response}    200
        Validate JSON Response Structure    ${response}    json    headers
    END
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Dynamic Payload Complexity    ${SUITE_NAME}    PASS    ${duration}
