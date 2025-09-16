*** Settings ***
Documentation    Test suite for different response formats using httpbin.org
Resource         ../resources/common_keywords.resource
Suite Setup      Setup Test Environment
Suite Teardown   Teardown Test Environment
Test Tags        response_formats    api_testing

*** Variables ***
${SUITE_NAME}    ResponseFormats

*** Test Cases ***
Test JSON Response Format
    [Documentation]    Test JSON response format handling
    [Tags]    json    format    smoke
    ${test_start_time}=    Get Current Date    result_format=epoch

    # Execute request
    ${response}=    GET    /json    expected_status=200

    # Validate response
    Validate Response Status    ${response}    200
    Should Contain    ${response.headers['Content-Type']}    application/json

    # Validate JSON structure
    ${json_data}=    Set Variable    ${response.json()}
    Should Be True    isinstance($json_data, dict)

    # Validate specific JSON content from httpbin
    Dictionary Should Contain Key    ${json_data}    slideshow
    Dictionary Should Contain Key    ${json_data['slideshow']}    author
    Dictionary Should Contain Key    ${json_data['slideshow']}    date
    Dictionary Should Contain Key    ${json_data['slideshow']}    slides
    Dictionary Should Contain Key    ${json_data['slideshow']}    title

    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test JSON Response Format    ${SUITE_NAME}    PASS    ${duration}

Test HTML Response Format
    [Documentation]    Test HTML response format handling
    [Tags]    html    format
    ${test_start_time}=    Get Current Date    result_format=epoch

    # Execute request
    ${response}=    GET    /html    expected_status=200

    # Validate response
    Validate Response Status    ${response}    200
    Should Contain    ${response.headers['Content-Type']}    text/html

    # Validate HTML content
    Should Contain    ${response.text}    <!DOCTYPE html>
    Should Contain    ${response.text}    <html>
    Should Contain    ${response.text}    </html>
    Should Contain    ${response.text}    <head>
    Should Contain    ${response.text}    <body>
    Should Contain    ${response.text}    <h1>Herman Melville - Moby-Dick</h1>

    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test HTML Response Format    ${SUITE_NAME}    PASS    ${duration}

Test XML Response Format
    [Documentation]    Test XML response format handling
    [Tags]    xml    format
    ${test_start_time}=    Get Current Date    result_format=epoch

    # Execute request
    ${response}=    GET    /xml    expected_status=200

    # Validate response
    Validate Response Status    ${response}    200
    Should Contain    ${response.headers['Content-Type']}    application/xml

    # Validate XML content
    Should Contain    ${response.text}    <?xml version="1.0"
    Should Contain    ${response.text}    <slideshow
    Should Contain    ${response.text}    </slideshow>
    Should Contain    ${response.text}    author=
    Should Contain    ${response.text}    title=

    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test XML Response Format    ${SUITE_NAME}    PASS    ${duration}

Test GZIP Compression
    [Documentation]    Test GZIP compressed response
    [Tags]    gzip    compression    smoke
    ${test_start_time}=    Get Current Date    result_format=epoch

    # Execute request with appropriate headers
    ${headers}=    Create Dictionary    Accept-Encoding=gzip
    ${response}=    GET    /gzip    headers=${headers}    expected_status=200

    # Validate response
    Validate Response Status    ${response}    200
    Should Contain    ${response.headers['Content-Type']}    application/json

    # Validate compression was applied
    ${json_data}=    Set Variable    ${response.json()}
    Should Be True    ${json_data['gzipped']}
    Dictionary Should Contain Key    ${json_data}    headers
    Dictionary Should Contain Key    ${json_data}    origin
    Dictionary Should Contain Key    ${json_data}    args

    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test GZIP Compression    ${SUITE_NAME}    PASS    ${duration}

Test Deflate Compression
    [Documentation]    Test Deflate compressed response
    [Tags]    deflate    compression
    ${test_start_time}=    Get Current Date    result_format=epoch

    # Execute request with appropriate headers
    ${headers}=    Create Dictionary    Accept-Encoding=deflate
    ${response}=    GET    /deflate    headers=${headers}    expected_status=200

    # Validate response
    Validate Response Status    ${response}    200
    Should Contain    ${response.headers['Content-Type']}    application/json

    # Validate compression was applied
    ${json_data}=    Set Variable    ${response.json()}
    Should Be True    ${json_data['deflated']}
    Dictionary Should Contain Key    ${json_data}    headers
    Dictionary Should Contain Key    ${json_data}    origin

    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Deflate Compression    ${SUITE_NAME}    PASS    ${duration}

Test Brotli Compression
    [Documentation]    Test Brotli compressed response
    [Tags]    brotli    compression
    ${test_start_time}=    Get Current Date    result_format=epoch

    # Execute request with appropriate headers
    ${headers}=    Create Dictionary    Accept-Encoding=br
    ${response}=    GET    /brotli    headers=${headers}    expected_status=200

    # Validate response
    Validate Response Status    ${response}    200
    Should Contain    ${response.headers['Content-Type']}    application/json

    # Validate compression was applied
    ${json_data}=    Set Variable    ${response.json()}
    Should Be True    ${json_data['brotli']}
    Dictionary Should Contain Key    ${json_data}    headers
    Dictionary Should Contain Key    ${json_data}    origin

    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Brotli Compression    ${SUITE_NAME}    PASS    ${duration}

Test UTF-8 Encoding
    [Documentation]    Test UTF-8 encoded response
    [Tags]    utf8    encoding
    ${test_start_time}=    Get Current Date    result_format=epoch

    # Execute request
    ${response}=    GET    /encoding/utf8    expected_status=200

    # Validate response
    Validate Response Status    ${response}    200
    Should Contain    ${response.headers['Content-Type']}    text/html

    # Validate UTF-8 content with special characters
    Should Contain    ${response.text}    UTF-8
    Should Contain    ${response.text}    ☃    # Snowman character
    Should Contain    ${response.text}    ♠ ♣ ♥ ♦    # Card suits
    Should Contain    ${response.text}    ✓    # Check mark

    # Validate HTML structure
    Should Contain    ${response.text}    <!DOCTYPE html>
    Should Contain    ${response.text}    <html>
    Should Contain    ${response.text}    charset=utf-8

    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test UTF-8 Encoding    ${SUITE_NAME}    PASS    ${duration}

Test Robots.txt Format
    [Documentation]    Test robots.txt format response
    [Tags]    robots    format
    ${test_start_time}=    Get Current Date    result_format=epoch

    # Execute request
    ${response}=    GET    /robots.txt    expected_status=200

    # Validate response
    Validate Response Status    ${response}    200
    Should Contain    ${response.headers['Content-Type']}    text/plain

    # Validate robots.txt content
    Should Contain    ${response.text}    User-agent:
    Should Contain    ${response.text}    Disallow:
    Should Match Regexp    ${response.text}    User-agent:\s*\*

    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Robots.txt Format    ${SUITE_NAME}    PASS    ${duration}

Test Deny Response Format
    [Documentation]    Test deny response (robots.txt denied content)
    [Tags]    deny    format
    ${test_start_time}=    Get Current Date    result_format=epoch

    # Execute request
    ${response}=    GET    /deny    expected_status=200

    # Validate response
    Validate Response Status    ${response}    200
    Should Contain    ${response.headers['Content-Type']}    text/plain

    # Validate deny message content
    ${response_text_upper}=    Convert To Upper Case    ${response.text}
    Should Contain    ${response_text_upper}    YOU
    Should Contain    ${response_text_upper}    SHOULDN'T
    Should Contain    ${response_text_upper}    BE
    Should Contain    ${response_text_upper}    HERE

    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Deny Response Format    ${SUITE_NAME}    PASS    ${duration}

Test Multiple Compression Formats
    [Documentation]    Test multiple compression formats in single test
    [Tags]    compression    multiple    performance
    ${test_start_time}=    Get Current Date    result_format=epoch

    # Test multiple compression formats
    @{compression_tests}=    Create List
    ...    ${{ {'encoding': 'gzip', 'endpoint': '/gzip', 'key': 'gzipped'} }}
    ...    ${{ {'encoding': 'deflate', 'endpoint': '/deflate', 'key': 'deflated'} }}
    ...    ${{ {'encoding': 'br', 'endpoint': '/brotli', 'key': 'brotli'} }}

    FOR    ${compression_test}    IN    @{compression_tests}
        ${headers}=    Create Dictionary    Accept-Encoding=${compression_test['encoding']}
        ${response}=    GET    ${compression_test['endpoint']}    headers=${headers}    expected_status=200

        # Validate response
        Validate Response Status    ${response}    200
        ${json_data}=    Set Variable    ${response.json()}
        Should Be True    ${json_data['${compression_test['key']}']}

        Log    Successfully tested ${compression_test['encoding']} compression
    END

    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Multiple Compression Formats    ${SUITE_NAME}    PASS    ${duration}

Test Content Negotiation
    [Documentation]    Test content negotiation with Accept headers
    [Tags]    content_negotiation    headers
    ${test_start_time}=    Get Current Date    result_format=epoch

    # Test different Accept headers
    ${json_headers}=    Create Dictionary    Accept=application/json
    ${xml_headers}=    Create Dictionary    Accept=application/xml
    ${html_headers}=    Create Dictionary    Accept=text/html

    # Test JSON content negotiation
    ${json_response}=    GET    /json    headers=${json_headers}    expected_status=200
    Should Contain    ${json_response.headers['Content-Type']}    application/json

    # Test XML content negotiation  
    ${xml_response}=    GET    /xml    headers=${xml_headers}    expected_status=200
    Should Contain    ${xml_response.headers['Content-Type']}    application/xml

    # Test HTML content negotiation
    ${html_response}=    GET    /html    headers=${html_headers}    expected_status=200
    Should Contain    ${html_response.headers['Content-Type']}    text/html

    # Validate content types match requested formats
    Log    JSON Content-Type: ${json_response.headers['Content-Type']}
    Log    XML Content-Type: ${xml_response.headers['Content-Type']}
    Log    HTML Content-Type: ${html_response.headers['Content-Type']}

    # Record metrics
    ${test_end_time}=    Get Current Date    result_format=epoch
    ${duration}=    Evaluate    ${test_end_time} - ${test_start_time}
    Record Test Metrics    Test Content Negotiation    ${SUITE_NAME}    PASS    ${duration}
