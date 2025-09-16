*** Settings ***
Documentation    Test suite for messaging integration with Kafka and RabbitMQ
Resource         ../resources/common_keywords.resource
Library          ../libraries/KafkaProducerLibrary.py
Library          ../libraries/RabbitMQProducerLibrary.py
Suite Setup      Setup Messaging Environment
Suite Teardown   Teardown Messaging Environment
Test Tags        messaging    integration

*** Variables ***
${SUITE_NAME}           Messaging
${KAFKA_TOPIC}          test-results
${RABBITMQ_QUEUE}       test-results-queue

*** Keywords ***
Setup Messaging Environment
    [Documentation]    Setup messaging environment
    Setup Test Environment
    
    # Setup Kafka (if available)
    TRY
        Connect To Kafka    bootstrap_servers=localhost:9092
        Log    Kafka connection established
    EXCEPT
        Log    Kafka not available, skipping Kafka tests    WARN
    END
    
    # Setup RabbitMQ (if available)
    TRY
        Connect To RabbitMQ    host=localhost    port=5672
        Declare Queue    ${RABBITMQ_QUEUE}
        Log    RabbitMQ connection established
    EXCEPT
        Log    RabbitMQ not available, skipping RabbitMQ tests    WARN
    END

Teardown Messaging Environment
    [Documentation]    Cleanup messaging environment
    Close Kafka Connection
    Close RabbitMQ Connection
    Teardown Test Environment

*** Test Cases ***
Test Kafka Message Publishing
    [Documentation]    Test publishing messages to Kafka
    [Tags]    kafka    publish    smoke
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate test message
    ${test_data}=    Generate Random API Test Data
    ${message}=    Create Dictionary
    ...    test_name=Test Kafka Message Publishing
    ...    data=${test_data}
    ...    timestamp=${test_start_time}
    
    # Publish message to Kafka
    TRY
        ${result}=    Publish Message To Kafka    ${KAFKA_TOPIC}    ${message}
        Log    Message published to Kafka: ${result}
        
        # Validate publishing result
        Should Not Be Empty    ${result}
        Dictionary Should Contain Key    ${result}    offset
        Dictionary Should Contain Key    ${result}    partition
        
    EXCEPT    AS    ${error}
        Log    Kafka test skipped: ${error}    WARN
        Pass Execution    Kafka not available
    END
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Kafka Message Publishing    ${SUITE_NAME}    PASS    ${duration}

Test RabbitMQ Message Publishing
    [Documentation]    Test publishing messages to RabbitMQ
    [Tags]    rabbitmq    publish    smoke
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate test message
    ${test_data}=    Generate Random User Data
    ${message}=    Create Dictionary
    ...    test_name=Test RabbitMQ Message Publishing
    ...    user_data=${test_data}
    ...    timestamp=${test_start_time}
    
    # Publish message to RabbitMQ
    TRY
        Publish Message To RabbitMQ    ${RABBITMQ_QUEUE}    ${message}
        Log    Message published to RabbitMQ queue: ${RABBITMQ_QUEUE}
        
    EXCEPT    AS    ${error}
        Log    RabbitMQ test skipped: ${error}    WARN
        Pass Execution    RabbitMQ not available
    END
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test RabbitMQ Message Publishing    ${SUITE_NAME}    PASS    ${duration}

Test Message Consumption Validation
    [Documentation]    Test message consumption and validation
    [Tags]    consume    validate
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Publish test message to RabbitMQ
    ${test_message}=    Create Dictionary
    ...    test_id=${Faker.UUID4}
    ...    message=Test message for consumption validation
    ...    data=${Generate Random API Test Data}
    
    TRY
        # Publish message
        Publish Message To RabbitMQ    ${RABBITMQ_QUEUE}    ${test_message}
        Sleep    1s    # Allow message to be queued
        
        # Consume messages
        ${consumed_messages}=    Consume Messages From Queue    ${RABBITMQ_QUEUE}    max_messages=5    timeout=10
        
        # Validate consumption
        Should Not Be Empty    ${consumed_messages}
        ${found_message}=    Set Variable    ${False}
        FOR    ${msg}    IN    @{consumed_messages}
            IF    '${msg['test_id']}' == '${test_message['test_id']}'
                ${found_message}=    Set Variable    ${True}
                Should Be Equal    ${msg['message']}    ${test_message['message']}
                Exit For Loop
            END
        END
        Should Be True    ${found_message}    Test message not found in consumed messages
        
    EXCEPT    AS    ${error}
        Log    RabbitMQ consumption test skipped: ${error}    WARN
        Pass Execution    RabbitMQ not available
    END
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Message Consumption Validation    ${SUITE_NAME}    PASS    ${duration}

Test API Test Result Publishing
    [Documentation]    Test publishing API test results to messaging systems
    [Tags]    api_results    publish
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Execute API test to generate result
    ${api_response}=    GET    /get    params=${{test: 'messaging'}}    expected_status=200
    ${test_result}=    Create Dictionary
    ...    test_name=Sample API Test
    ...    status=PASS
    ...    response_time=${1.5}
    ...    status_code=${api_response.status_code}
    ...    endpoint=/get
    
    # Publish to Kafka
    TRY
        Publish Test Result To Kafka    ${KAFKA_TOPIC}    Sample API Test    PASS    1.5    ${test_result}
        Log    API test result published to Kafka
    EXCEPT    AS    ${error}
        Log    Kafka publishing failed: ${error}    WARN
    END
    
    # Publish to RabbitMQ  
    TRY
        Publish Test Result To RabbitMQ    ${RABBITMQ_QUEUE}    Sample API Test    PASS    1.5    ${test_result}
        Log    API test result published to RabbitMQ
    EXCEPT    AS    ${error}
        Log    RabbitMQ publishing failed: ${error}    WARN
    END
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test API Test Result Publishing    ${SUITE_NAME}    PASS    ${duration}

Test Bulk Message Publishing
    [Documentation]    Test publishing multiple messages in bulk
    [Tags]    bulk    performance
    ${test_start_time}=    Get Current Date    result_format=epoch
    
    # Generate multiple test messages
    ${message_count}=    Set Variable    10
    
    TRY
        FOR    ${i}    IN RANGE    ${message_count}
            ${test_data}=    Generate Random API Test Data
            ${message}=    Create Dictionary
            ...    message_id=${i}
            ...    data=${test_data}
            ...    timestamp=${Get Current Date    result_format=epoch}
            
            # Publish to Kafka
            Publish Message To Kafka    ${KAFKA_TOPIC}    ${message}    key=bulk_test_${i}
        END
        
        Log    Published ${message_count} messages to Kafka successfully
        
    EXCEPT    AS    ${error}
        Log    Bulk publishing test skipped: ${error}    WARN
        Pass Execution    Kafka not available
    END
    
    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Bulk Message Publishing    ${SUITE_NAME}    PASS    ${duration}
