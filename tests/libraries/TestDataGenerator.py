import random
import json
from datetime import datetime, timedelta
from faker import Faker
from robot.api.deco import keyword
from robot.api import logger
from datetime import datetime

class TestDataGenerator:
    """Custom test data generation library using Faker"""
    
    def __init__(self, locale='en_US', seed=None):
        self.fake = Faker(locale)
        if seed:
            Faker.seed(seed)
            random.seed(seed)
    
    @keyword('Generate Random User Data')
    def generate_random_user_data(self):
        """Generate random user data for testing"""
         
        user_data = {
            'name': self.fake.name(),
            'email': self.fake.email(),
            'phone': self.fake.phone_number(),
            'address': self.fake.address(),
            'company': self.fake.company(),
            'job_title': self.fake.job(),
            'date_of_birth': datetime.strptime(str(self.fake.date_of_birth(minimum_age=18, maximum_age=80)),"%Y-%m-%d %H:%M:%S").isoformat(),
            'username': self.fake.user_name(),
            'password': self.fake.password(length=12),
            'ssn': self.fake.ssn(),
            'credit_card': self.fake.credit_card_number(),
            'uuid': str(self.fake.uuid4())
        }
        logger.info(f"Generated user data: {json.dumps(user_data, indent=2)}")
        return user_data
    
    @keyword('Generate Random API Test Data')
    def generate_random_api_test_data(self):
        """Generate random data suitable for API testing"""
        test_data = {
            'string_field': self.fake.text(max_nb_chars=50),
            'number_field': self.fake.random_int(min=1, max=1000),
            'float_field': round(self.fake.random.uniform(1.0, 100.0), 2),
            'boolean_field': self.fake.boolean(),
            'date_field': datetime.strptime(str(self.fake.date()), "%Y-%m-%d").isoformat(),
            'datetime_field': datetime.strptime(str(self.fake.date_time()), "%Y-%m-%d %H:%M:%S").isoformat(),
            'url_field': self.fake.url(),
            'ipv4_field': self.fake.ipv4(),
            'mac_address_field': self.fake.mac_address(),
            'user_agent_field': self.fake.user_agent(),
            'file_name_field': self.fake.file_name(),
            'mime_type_field': self.fake.mime_type()
        }
        logger.info(f"Generated API test data: {json.dumps(test_data, indent=2)}")
        return test_data
    
    @keyword('Generate Random HTTP Headers')
    def generate_random_http_headers(self):
        """Generate random HTTP headers for testing"""
        headers = {
            'User-Agent': self.fake.user_agent(),
            'Accept': self.fake.mime_type(),
            'Accept-Language': f"{self.fake.language_code()}-{self.fake.country_code()}",
            'X-Request-ID': str(self.fake.uuid4()),
            'X-Client-Version': f"{self.fake.random_int(1, 10)}.{self.fake.random_int(0, 9)}.{self.fake.random_int(0, 9)}",
            'X-Custom-Header': self.fake.word()
        }
        logger.info(f"Generated HTTP headers: {json.dumps(headers, indent=2)}")
        return headers
    
    @keyword('Generate Random JSON Payload')
    def generate_random_json_payload(self, complexity='simple'):
        """Generate random JSON payload with different complexity levels"""
        if complexity == 'simple':
            payload = {
                'id': self.fake.random_int(1, 10000),
                'name': self.fake.name(),
                'message': self.fake.sentence()
            }
        elif complexity == 'medium':
            payload = {
                'user': {
                    'id': self.fake.random_int(1, 10000),
                    'profile': {
                        'name': self.fake.name(),
                        'email': self.fake.email(),
                        'preferences': {
                            'theme': self.fake.random_element(['dark', 'light']),
                            'notifications': self.fake.boolean()
                        }
                    }
                },
                'metadata': {
                    'timestamp': datetime.strptime(str(datetime.now()), "%Y-%m-%d %H:%M:%S").isoformat(),
                    'version': f"{self.fake.random_int(1, 5)}.{self.fake.random_int(0, 9)}"
                }
            }
        else:  # complex
            payload = {
                'users': [
                    {
                        'id': self.fake.random_int(1, 1000),
                        'name': self.fake.name(),
                        'contacts': [self.fake.email() for _ in range(self.fake.random_int(1, 5))]
                    } for _ in range(self.fake.random_int(2, 5))
                ],
                'settings': {
                    'global': {
                        'timeout': self.fake.random_int(10, 300),
                        'retries': self.fake.random_int(1, 10)
                    },
                    'features': {feature: self.fake.boolean() for feature in 
                               ['analytics', 'caching', 'logging', 'monitoring']}
                }
            }
        
        logger.info(f"Generated {complexity} JSON payload: {json.dumps(payload, indent=2)}")
        return payload
