import json
import logging
from kafka import KafkaProducer
from kafka.errors import KafkaError
from robot.api.deco import keyword
from robot.api import logger

class KafkaProducerLibrary:
    """Kafka producer library for Robot Framework messaging integration"""
    
    def __init__(self):
        self.producer = None
        
    @keyword('Connect To Kafka')
    def connect_to_kafka(self, bootstrap_servers='localhost:9092', **kwargs):
        """Connect to Kafka broker"""
        try:
            config = {
                'bootstrap_servers': bootstrap_servers.split(','),
                'value_serializer': lambda v: json.dumps(v).encode('utf-8'),
                'key_serializer': lambda k: str(k).encode('utf-8') if k else None,
                **kwargs
            }
            
            self.producer = KafkaProducer(**config)
            logger.info(f"Connected to Kafka at {bootstrap_servers}")
            
        except Exception as e:
            logger.error(f"Failed to connect to Kafka: {str(e)}")
            raise
    
    @keyword('Publish Message To Kafka')
    def publish_message_to_kafka(self, topic, message, key=None):
        """Publish message to Kafka topic"""
        if not self.producer:
            raise RuntimeError("Not connected to Kafka. Use 'Connect To Kafka' first.")
        
        try:
            future = self.producer.send(topic, value=message, key=key)
            record_metadata = future.get(timeout=10)
            
            logger.info(f"Message published to topic '{topic}' at offset {record_metadata.offset}")
            return {
                'topic': record_metadata.topic,
                'partition': record_metadata.partition,
                'offset': record_metadata.offset,
                'timestamp': record_metadata.timestamp
            }
            
        except Exception as e:
            logger.error(f"Failed to publish message to Kafka: {str(e)}")
            raise
    
    @keyword('Publish Test Result To Kafka')
    def publish_test_result_to_kafka(self, topic, test_name, status, duration, details=None):
        """Publish test result to Kafka"""
        message = {
            'test_name': test_name,
            'status': status,
            'duration': duration,
            'timestamp': logger.timestamp(),
            'details': details or {}
        }
        
        return self.publish_message_to_kafka(topic, message, key=test_name)
    
    @keyword('Close Kafka Connection')
    def close_kafka_connection(self):
        """Close Kafka producer connection"""
        if self.producer:
            self.producer.close()
            self.producer = None
            logger.info("Kafka connection closed")
