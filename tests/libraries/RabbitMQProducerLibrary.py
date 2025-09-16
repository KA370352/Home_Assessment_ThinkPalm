import json
import pika
from robot.api.deco import keyword
from robot.api import logger

class RabbitMQProducerLibrary:
    """RabbitMQ producer library for Robot Framework messaging integration"""
    
    def __init__(self):
        self.connection = None
        self.channel = None
        
    @keyword('Connect To RabbitMQ')
    def connect_to_rabbitmq(self, host='localhost', port=5672, username='guest', password='guest', virtual_host='/'):
        """Connect to RabbitMQ broker"""
        try:
            credentials = pika.PlainCredentials(username, password)
            parameters = pika.ConnectionParameters(
                host=host,
                port=port,
                virtual_host=virtual_host,
                credentials=credentials
            )
            
            self.connection = pika.BlockingConnection(parameters)
            self.channel = self.connection.channel()
            
            logger.info(f"Connected to RabbitMQ at {host}:{port}")
            
        except Exception as e:
            logger.error(f"Failed to connect to RabbitMQ: {str(e)}")
            raise
    
    @keyword('Declare Queue')
    def declare_queue(self, queue_name, durable=True):
        """Declare a queue in RabbitMQ"""
        if not self.channel:
            raise RuntimeError("Not connected to RabbitMQ. Use 'Connect To RabbitMQ' first.")
        
        try:
            result = self.channel.queue_declare(queue=queue_name, durable=durable)
            logger.info(f"Queue '{queue_name}' declared successfully")
            return result.method.queue
            
        except Exception as e:
            logger.error(f"Failed to declare queue '{queue_name}': {str(e)}")
            raise
    
    @keyword('Publish Message To RabbitMQ')
    def publish_message_to_rabbitmq(self, queue_name, message, exchange='', routing_key=None):
        """Publish message to RabbitMQ queue"""
        if not self.channel:
            raise RuntimeError("Not connected to RabbitMQ. Use 'Connect To RabbitMQ' first.")
        
        try:
            routing_key = routing_key or queue_name
            
            # Ensure message is JSON string
            if isinstance(message, dict):
                message = json.dumps(message)
            
            self.channel.basic_publish(
                exchange=exchange,
                routing_key=routing_key,
                body=message,
                properties=pika.BasicProperties(delivery_mode=2)  # Make message persistent
            )
            
            logger.info(f"Message published to queue '{queue_name}'")
            
        except Exception as e:
            logger.error(f"Failed to publish message to RabbitMQ: {str(e)}")
            raise
    
    @keyword('Publish Test Result To RabbitMQ')
    def publish_test_result_to_rabbitmq(self, queue_name, test_name, status, duration, details=None):
        """Publish test result to RabbitMQ"""
        message = {
            'test_name': test_name,
            'status': status,
            'duration': duration,
            'timestamp': logger.timestamp(),
            'details': details or {}
        }
        
        return self.publish_message_to_rabbitmq(queue_name, message)
    
    @keyword('Consume Messages From Queue')
    def consume_messages_from_queue(self, queue_name, max_messages=10, timeout=30):
        """Consume messages from RabbitMQ queue for validation"""
        if not self.channel:
            raise RuntimeError("Not connected to RabbitMQ. Use 'Connect To RabbitMQ' first.")
        
        messages = []
        count = 0
        
        try:
            for method_frame, properties, body in self.channel.consume(queue_name, inactivity_timeout=timeout):
                if method_frame is None:
                    break
                    
                message = json.loads(body.decode('utf-8'))
                messages.append(message)
                
                # Acknowledge the message
                self.channel.basic_ack(method_frame.delivery_tag)
                count += 1
                
                if count >= max_messages:
                    break
            
            self.channel.cancel()
            logger.info(f"Consumed {count} messages from queue '{queue_name}'")
            return messages
            
        except Exception as e:
            logger.error(f"Failed to consume messages from queue '{queue_name}': {str(e)}")
            raise
    
    @keyword('Close RabbitMQ Connection')
    def close_rabbitmq_connection(self):
        """Close RabbitMQ connection"""
        if self.connection and not self.connection.is_closed:
            self.connection.close()
            self.connection = None
            self.channel = None
            logger.info("RabbitMQ connection closed")
