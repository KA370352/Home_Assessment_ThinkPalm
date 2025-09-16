*** Settings ***
Documentation    Common keywords and variables for API testing
Library          RequestsLibrary
Library          Collections
Library          OperatingSystem
Library          String
Library          DateTime
Library          ../libraries/ConfigManager.py
Library          ../libraries/TestDataGenerator.py
Library          ../libraries/RetryDecorator.py
Library          ../libraries/MetricsCollector.py

*** Variables ***
${BASE_URL}              https://httpbin.org
${DEFAULT_TIMEOUT}       30
${MAX_RETRIES}           3
${RETRY_DELAY}           2

*** Keywords ***
Setup Test Environment
    [Documentation]    Initialize test environment and configuration
    Load Configuration
    ${base_url}=    Get Config Value    api.base_url    ${BASE_URL}
    Set Suite Variable    ${BASE_URL}    ${base_url}
    ${timeout}=    Get Config Value    api.timeout    ${DEFAULT_TIMEOUT}
    Set Suite Variable    ${DEFAULT_TIMEOUT}    ${timeout}
    
    # Initialize HTTP session
    Create Session    httpbin    ${BASE_URL}    timeout=${DEFAULT_TIMEOUT}
    Record Test Execution    Setup    Common    PASS    0

Teardown Test Environment
    [Documentation]    Clean up test environment
    Delete All Sessions
    Push Metrics To Prometheus

Generate Test Headers
    [Documentation]    Generate random HTTP headers for testing
    ${headers}=    Generate Random HTTP Headers
    [Return]    ${headers}

Generate API Payload
    [Documentation]    Generate random API payload
    [Arguments]    ${complexity}=simple
    ${payload}=    Generate Random JSON Payload    ${complexity}
    [Return]    ${payload}

Validate Response Status
    [Documentation]    Validate HTTP response status code
    [Arguments]    ${response}    ${expected_status}=200
    Should Be Equal As Numbers    ${response.status_code}    ${expected_status}
    Log    Response Status: ${response.status_code}

Validate Response Contains
    [Documentation]    Validate response contains specific data
    [Arguments]    ${response}    ${expected_data}
    ${response_text}=    Convert To String    ${response.text}
    Should Contain    ${response_text}    ${expected_data}
    Log    Response contains expected data: ${expected_data}

Validate JSON Response Structure
    [Documentation]    Validate JSON response has expected structure
    [Arguments]    ${response}    @{expected_keys}
    ${json_data}=    Set Variable    ${response.json()}
    FOR    ${key}    IN    @{expected_keys}
        Dictionary Should Contain Key    ${json_data}    ${key}
    END

Log Response Details
    [Documentation]    Log detailed response information
    [Arguments]    ${response}
    Log    Status Code: ${response.status_code}
    Log    Headers: ${response.headers}
    Log    Content: ${response.text}

Execute With Retry
    [Documentation]    Execute keyword with retry mechanism
    [Arguments]    ${keyword_name}    @{args}    &{kwargs}
    ${result}=    Retry Keyword    ${keyword_name}    max_attempts=${MAX_RETRIES}    delay=${RETRY_DELAY}
    [Return]    ${result}

Record Test Metrics
    [Documentation]    Record test execution metrics
    [Arguments]    ${test_name}    ${suite_name}    ${status}    ${duration}
    Record Test Execution    ${test_name}    ${suite_name}    ${status}    ${duration}

Wait For Response
    [Documentation]    Wait for response with timeout
    [Arguments]    ${response}    ${max_wait_time}=10
    ${start_time}=    Get Current Date    result_format=epoch
    WHILE    True    limit=${max_wait_time}
        ${current_time}=    Get Current Date    result_format=epoch
        ${elapsed}=    Evaluate    ${current_time} - ${start_time}
        Exit For Loop If    ${elapsed} > ${max_wait_time}
        Sleep    1s
    END

Create Test Data File
    [Documentation]    Create test data file for dynamic testing
    [Arguments]    ${filename}    ${data}
    ${json_data}=    Convert To JSON    ${data}
    Create File    data/${filename}    ${json_data}
    Log    Created test data file: data/${filename}

Read Test Data File  
    [Documentation]    Read test data from file
    [Arguments]    ${filename}
    ${file_content}=    Get File    data/${filename}
    ${data}=    Evaluate    json.loads($file_content)    json
    [Return]    ${data}
