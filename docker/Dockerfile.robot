FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Java for Allure
RUN apt-get update && apt-get install -y default-jdk && rm -rf /var/lib/apt/lists/*

# Install Allure commandline
RUN wget -q https://github.com/allure-framework/allure2/releases/download/2.24.0/allure-2.24.0.tgz \
    && tar -xf allure-2.24.0.tgz \
    && mv allure-2.24.0 /opt/allure \
    && ln -s /opt/allure/bin/allure /usr/local/bin/allure \
    && rm allure-2.24.0.tgz

# Set work directory
WORKDIR /app

# Copy requirements and install Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Set environment variables
ENV PYTHONPATH=/app
ENV ROBOT_TESTS_DIR=/app/tests
ENV ROBOT_REPORTS_DIR=/app/reports
ENV ALLURE_RESULTS_DIR=/app/reports/allure-results

# Create necessary directories
RUN mkdir -p /app/reports/allure-results /app/reports/allure-reports /app/data

# Set permissions
RUN chmod +x /app/scripts/*.sh

# Default command
CMD ["robot", "--outputdir", "/app/reports", "/app/tests/api/"]
