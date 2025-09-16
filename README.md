# Robot Framework API Automation - HttpBin Testing Suite

[![Robot Framework Tests](https://github.com/your-username/httpbin-robot-automation/actions/workflows/robot-tests.yml/badge.svg)](https://github.com/your-username/httpbin-robot-automation/actions/workflows/robot-tests.yml)

A comprehensive Robot Framework test automation suite for API testing using [httpbin.org](https://httpbin.org/) as the target service. This project demonstrates advanced test automation practices including custom retry mechanisms, dynamic data generation, messaging integration, and observability with Prometheus and Grafana.

## Features

### Core Features
-  **Robot Framework** with custom keyword libraries
-  **HTTP API Testing** covering all major methods (GET, POST, PUT, PATCH, DELETE)
-  **Response Format Testing** (JSON, XML, HTML, compression formats)
-  **Request Inspection** (headers, user-agent, authentication)
-  **Dynamic Data Generation** using Faker library
-  **Custom Retry Decorator** with detailed logging
-  **Configuration Management** via YAML and environment files

### Advanced Features
-  **Messaging Integration** (Kafka & RabbitMQ)
-  **Observability & Metrics** (Prometheus & Grafana)
-  **Dockerized Environment** with health checks
-  **Allure Reporting** with rich test documentation
-  **CI/CD Integration** with GitHub Actions
-  **Test Data Management** with Faker integration

## Project Structure

```
httpbin-robot-automation/
├── .github/
│   └── workflows/
│       └── robot-tests.yml          # GitHub Actions CI/CD pipeline
├── config/
│   └── config.yaml                  # Main configuration file
├── data/                            # Test data files
├── docker/
│   └── Dockerfile.robot             # Robot Framework container
├── grafana/
│   ├── dashboards/
│   │   └── robot-framework-dashboard.json
│   └── provisioning/
│       ├── dashboards/
│       └── datasources/
├── prometheus/
│   └── prometheus.yml               # Prometheus configuration
├── reports/                         # Test execution reports
├── scripts/
│   ├── setup_environment.sh         # Environment setup script
│   ├── run_tests.sh                 # Test execution script
│   └── cleanup.sh                   # Cleanup script
├── tests/
│   ├── api/
│   │   ├── auth_status_tests.robot  # Authentication & status tests
│   │   ├── dynamic_data_tests.robot # Dynamic data generation tests
│   │   ├── http_methods_tests.robot # HTTP method tests
│   │   ├── messaging_tests.robot    # Messaging integration tests
│   │   └── response_formats_tests.robot # Response format tests
│   ├── libraries/
│   │   ├── ConfigManager.py         # Configuration management
│   │   ├── KafkaProducerLibrary.py  # Kafka integration
│   │   ├── MetricsCollector.py      # Prometheus metrics
│   │   ├── RabbitMQProducerLibrary.py # RabbitMQ integration
│   │   ├── RetryDecorator.py        # Custom retry mechanism
│   │   └── TestDataGenerator.py     # Dynamic data generation
│   └── resources/
│       └── common_keywords.resource # Shared keywords and variables
├── .env                             # Environment variables
├── docker-compose.yml               # Multi-service Docker setup
├── requirements.txt                 # Python dependencies
└── README.md                        # This file
```

## Prerequisites

- **Docker & Docker Compose** (recommended approach)
- **Python 3.11+** (for local development)
- **Java 11+** (for Allure reporting)
- **Git** (for version control)

## Quick Start

### Option 1: Docker Compose (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/httpbin-robot-automation.git
   cd httpbin-robot-automation
   ```

2. **Setup the environment**
   ```bash
   chmod +x scripts/*.sh
   ./scripts/setup_environment.sh
   ```

3. **Run the tests**
   ```bash
   ./scripts/run_tests.sh
   ```

4. **View the results**
   - Robot Framework Reports: `http://localhost:5050`
   - Grafana Dashboard: `http://localhost:3000` (admin/admin)
   - Prometheus Metrics: `http://localhost:9090`

### Option 2: Local Development

1. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Install Allure (optional)**
   ```bash
   # On macOS
   brew install allure

   # On Ubuntu/Debian
   wget -q https://github.com/allure-framework/allure2/releases/download/2.24.0/allure-2.24.0.tgz
   tar -xf allure-2.24.0.tgz
   sudo mv allure-2.24.0 /opt/allure
   sudo ln -s /opt/allure/bin/allure /usr/local/bin/allure
   ```

3. **Run tests locally**
   ```bash
   robot --outputdir reports tests/api/
   ```

## Test Suites

### 1. HTTP Methods Tests (`http_methods_tests.robot`)
- GET requests with parameters
- POST requests with JSON payloads
- PUT requests with form data
- PATCH requests
- DELETE requests
- Header inspection and validation

### 2. Response Formats Tests (`response_formats_tests.robot`)
- JSON response handling
- XML response processing
- HTML content validation
- Compression testing (GZIP, Deflate, Brotli)
- Encoding validation (UTF-8)

### 3. Authentication & Status Tests (`auth_status_tests.robot`)
- Basic authentication (success/failure)
- Bearer token authentication
- Various HTTP status codes (200, 201, 400, 401, 404, 500)
- Random status code handling

### 4. Dynamic Data Tests (`dynamic_data_tests.robot`)
- Faker-based data generation
- UUID generation and validation
- Base64 encoding/decoding
- Random bytes generation
- Delayed response handling
- Streaming response processing

### 5. Messaging Integration Tests (`messaging_tests.robot`)
- Kafka message publishing and validation
- RabbitMQ message publishing and consumption
- Test result publishing to message brokers
- Bulk message processing

## Observability & Monitoring

### Prometheus Metrics
The framework collects custom metrics including:
- `robot_tests_total` - Counter of executed tests by status and suite
- `robot_test_duration_seconds` - Histogram of test execution times
- `robot_test_retries_total` - Counter of test retries
- `robot_active_tests` - Gauge of currently running tests

### Grafana Dashboard
Pre-configured dashboard showing:
- Test execution rate over time
- Total tests executed
- Pass/fail distribution (pie chart)
- Test duration percentiles (95th, 50th)

### Allure Reports
Rich HTML reports with:
- Test execution timeline
- Step-by-step test breakdown
- Attachments and screenshots
- Historical test trends
- Test categorization and filtering

## Configuration

### Environment Variables (.env)
```env
# API Configuration
API_BASE_URL=https://httpbin.org
API_TIMEOUT=30

# Messaging Configuration
KAFKA_BOOTSTRAP_SERVERS=localhost:9092
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672

# Monitoring Configuration
PROMETHEUS_GATEWAY=http://localhost:9091
GRAFANA_URL=http://localhost:3000
```

### YAML Configuration (config/config.yaml)
```yaml
api:
  base_url: https://httpbin.org
  timeout: 30
  retries: 3

messaging:
  kafka:
    bootstrap_servers: ['localhost:9092']
    topic: 'test-results'
  rabbitmq:
    host: localhost
    port: 5672
    queue: 'test-results'

monitoring:
  prometheus:
    gateway_url: 'http://localhost:9091'
  grafana:
    url: 'http://localhost:3000'
```

## Docker Services

The `docker-compose.yml` includes:

- **robot-tests**: Main test execution container
- **kafka**: Message streaming platform
- **zookeeper**: Kafka coordination service
- **rabbitmq**: Message broker with management UI
- **prometheus**: Metrics collection and storage
- **pushgateway**: Prometheus push gateway for batch jobs
- **grafana**: Metrics visualization and dashboards
- **allure**: Test reporting service

## CI/CD Integration

### GitHub Actions
The project includes a comprehensive GitHub Actions workflow that:
- Runs on push, pull requests, and daily schedule
- Sets up all required services using GitHub service containers
- Executes smoke tests and full test suite
- Generates and publishes Allure reports
- Uploads test artifacts
- Comments on PRs with report links

### Customization
To customize the CI/CD pipeline:
1. Update `.github/workflows/robot-tests.yml`
2. Modify test execution parameters
3. Add additional deployment steps
4. Configure secrets for external integrations

## Writing Custom Tests

### 1. Create a new test file
```robot
*** Settings ***
Documentation    Custom test suite
Resource         ../resources/common_keywords.resource
Suite Setup      Setup Test Environment
Suite Teardown   Teardown Test Environment

*** Test Cases ***
My Custom Test
    [Documentation]    Test description
    [Tags]    custom    api
    ${response}=    GET    /custom-endpoint
    Validate Response Status    ${response}    200
```

### 2. Use custom libraries
```robot
*** Settings ***
Library    ../libraries/TestDataGenerator.py

*** Test Cases ***
Test With Dynamic Data
    ${user_data}=    Generate Random User Data
    ${response}=    POST    /post    json=${user_data}
    Validate Response Status    ${response}    200
```

### 3. Add custom keywords
```robot
*** Keywords ***
Custom Validation Keyword
    [Arguments]    ${response}    ${expected_field}
    ${json_data}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json_data}    ${expected_field}
```

## Troubleshooting

### Common Issues

1. **Services not starting**
   ```bash
   # Check service status
   docker-compose ps

   # View service logs
   docker-compose logs [service-name]

   # Restart services
   docker-compose restart
   ```

2. **Test failures due to timeouts**
   - Increase timeout values in `config/config.yaml`
   - Check network connectivity to httpbin.org
   - Verify service health using `docker-compose ps`

3. **Allure report not generating**
   - Ensure Java is installed and in PATH
   - Check Allure installation: `allure --version`
   - Verify allure-results directory has content

4. **Kafka/RabbitMQ connection issues**
   - Wait for services to fully start (30-60 seconds)
   - Check service health endpoints
   - Verify network connectivity between containers

### Debug Mode
Run tests with debug logging:
```bash
robot --loglevel DEBUG --outputdir reports tests/api/
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Make your changes and add tests
4. Run the test suite: `./scripts/run_tests.sh`
5. Commit your changes: `git commit -am 'Add new feature'`
6. Push to the branch: `git push origin feature/new-feature`
7. Create a Pull Request

### Code Standards
- Follow Robot Framework style guidelines
- Add appropriate documentation and tags
- Include error handling and logging
- Write unit tests for custom Python libraries
- Update README.md for significant changes

## Performance Testing

For load testing, consider:
- Running tests in parallel: `robot --processes 4`
- Using test data pools to avoid conflicts
- Implementing rate limiting for API calls
- Monitoring resource usage during execution

## Security Considerations

- Store sensitive data in environment variables or encrypted vaults
- Use secure connections for message brokers in production
- Implement proper authentication for monitoring services
- Regularly update dependencies for security patches

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [HttpBin](https://httpbin.org/) for providing the excellent HTTP testing service
- [Robot Framework](https://robotframework.org/) community for the amazing framework
- [Faker](https://faker.readthedocs.io/) for dynamic test data generation
- All contributors and maintainers of the open-source libraries used in this project

---

**Happy Testing!**

For questions, issues, or contributions, please visit our [GitHub repository](https://github.com/your-username/httpbin-robot-automation).
