import time
from prometheus_client import Counter, Histogram, Gauge, push_to_gateway, CollectorRegistry
from robot.api.deco import keyword
from robot.api import logger

class MetricsCollector:
    """Prometheus metrics collector for Robot Framework"""
    
    def __init__(self):
        self.registry = CollectorRegistry()
        self.metrics = {}
        self._init_default_metrics()
        
    def _init_default_metrics(self):
        """Initialize default metrics"""
        self.metrics['test_total'] = Counter(
            'robot_tests_total', 
            'Total number of tests executed',
            ['test_name', 'suite', 'status'],
            registry=self.registry
        )
        
        self.metrics['test_duration'] = Histogram(
            'robot_test_duration_seconds',
            'Test execution duration in seconds',
            ['test_name', 'suite'],
            registry=self.registry
        )
        
        self.metrics['test_retries'] = Counter(
            'robot_test_retries_total',
            'Total number of test retries',
            ['test_name', 'suite'],
            registry=self.registry
        )
        
        self.metrics['active_tests'] = Gauge(
            'robot_active_tests',
            'Number of currently running tests',
            registry=self.registry
        )
    
    @keyword('Record Test Execution')
    def record_test_execution(self, test_name, suite_name, status, duration):
        """Record test execution metrics"""
        try:
            # Record test count
            self.metrics['test_total'].labels(
                test_name=test_name, 
                suite=suite_name, 
                status=status.lower()
            ).inc()
            
            # Record test duration
            self.metrics['test_duration'].labels(
                test_name=test_name,
                suite=suite_name
            ).observe(float(duration))
            
            logger.info(f"Recorded metrics for test '{test_name}': status={status}, duration={duration}s")
            
        except Exception as e:
            logger.error(f"Failed to record test metrics: {str(e)}")
    
    @keyword('Record Test Retry')
    def record_test_retry(self, test_name, suite_name):
        """Record test retry metrics"""
        try:
            self.metrics['test_retries'].labels(
                test_name=test_name,
                suite=suite_name
            ).inc()
            
            logger.info(f"Recorded retry for test '{test_name}' in suite '{suite_name}'")
            
        except Exception as e:
            logger.error(f"Failed to record retry metrics: {str(e)}")
    
    @keyword('Set Active Tests Count')
    def set_active_tests_count(self, count):
        """Set the number of active tests"""
        try:
            self.metrics['active_tests'].set(int(count))
            logger.info(f"Set active tests count to {count}")
            
        except Exception as e:
            logger.error(f"Failed to set active tests count: {str(e)}")
    
    @keyword('Push Metrics To Prometheus')
    def push_metrics_to_prometheus(self, gateway_url='http://localhost:9091', job_name='robot-tests'):
        """Push metrics to Prometheus pushgateway"""
        try:
            push_to_gateway(gateway_url, job=job_name, registry=self.registry)
            logger.info(f"Pushed metrics to Prometheus gateway at {gateway_url}")
            
        except Exception as e:
            logger.error(f"Failed to push metrics to Prometheus: {str(e)}")
            raise
    
    @keyword('Create Custom Counter')
    def create_custom_counter(self, name, description, labels=None):
        """Create a custom counter metric"""
        try:
            labels = labels or []
            self.metrics[name] = Counter(
                name,
                description,
                labels,
                registry=self.registry
            )
            logger.info(f"Created custom counter '{name}'")
            
        except Exception as e:
            logger.error(f"Failed to create custom counter: {str(e)}")
            raise
    
    @keyword('Increment Custom Counter')
    def increment_custom_counter(self, name, label_values=None):
        """Increment a custom counter"""
        try:
            if name not in self.metrics:
                raise ValueError(f"Counter '{name}' not found")
            
            if label_values:
                self.metrics[name].labels(**label_values).inc()
            else:
                self.metrics[name].inc()
                
            logger.info(f"Incremented counter '{name}' with labels {label_values}")
            
        except Exception as e:
            logger.error(f"Failed to increment counter: {str(e)}")
            raise
