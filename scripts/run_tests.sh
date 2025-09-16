#!/bin/bash

# Robot Framework Test Execution Script
set -e

# Configuration
ROBOT_TESTS_DIR=${ROBOT_TESTS_DIR:-"tests/api"}
ROBOT_REPORTS_DIR=${ROBOT_REPORTS_DIR:-"reports"}
ALLURE_RESULTS_DIR=${ALLURE_RESULTS_DIR:-"reports/allure-results"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Robot Framework Test Execution${NC}"

# Create directories
mkdir -p "$ROBOT_REPORTS_DIR"
mkdir -p "$ALLURE_RESULTS_DIR"

# Function to run tests with different configurations
run_tests() {
    local test_suite="$1"
    local tags="$2"
    local output_name="$3"

    echo -e "${YELLOW}Running $test_suite with tags: $tags${NC}"

    robot \
        --listener allure_robotframework \
        --outputdir "$ROBOT_REPORTS_DIR" \
        --output "$output_name.xml" \
        --log "$output_name.html" \
        --report "$output_name-report.html" \
        --include "$tags" \
        --loglevel INFO \
        --pythonpath . \
        "$ROBOT_TESTS_DIR/$test_suite" || true
}

# Run test suites
echo -e "${BLUE}Executing test suites...${NC}"

# Run smoke tests first
run_tests "http_methods_tests.robot" "smoke" "smoke-tests"

# Run all HTTP method tests
run_tests "http_methods_tests.robot" "http_methods" "http-methods"

# Run response format tests
run_tests "response_formats_tests.robot" "response_formats" "response-formats"

# Run authentication and status tests
run_tests "auth_status_tests.robot" "auth" "auth-status"

# Run dynamic data tests
run_tests "dynamic_data_tests.robot" "dynamic_data" "dynamic-data"

# Run messaging tests (if services available)
run_tests "messaging_tests.robot" "messaging" "messaging"

# Generate Allure report
echo -e "${YELLOW}Generating Allure report...${NC}"
if command -v allure &> /dev/null; then
    allure generate "$ALLURE_RESULTS_DIR" -o "$ROBOT_REPORTS_DIR/allure-reports" --clean
    echo -e "${GREEN}Allure report generated at: $ROBOT_REPORTS_DIR/allure-reports${NC}"
else
    echo -e "${RED}Allure command not found. Skipping report generation.${NC}"
fi

# Display results
echo -e "${BLUE}Test execution completed!${NC}"
echo -e "Reports available at:"
echo -e "  - Robot Framework: ${GREEN}$ROBOT_REPORTS_DIR/${NC}"
echo -e "  - Allure Reports: ${GREEN}$ROBOT_REPORTS_DIR/allure-reports/${NC}"

# Return appropriate exit code
if [ -f "$ROBOT_REPORTS_DIR/output.xml" ]; then
    # Check if there were any failures
    if grep -q 'stat="FAIL"' "$ROBOT_REPORTS_DIR"/*.xml 2>/dev/null; then
        echo -e "${RED}Some tests failed. Check the reports for details.${NC}"
        exit 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    fi
fi
