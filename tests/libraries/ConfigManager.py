import os
import yaml
import json
from pathlib import Path
from dotenv import load_dotenv
from robot.api.deco import keyword
from robot.api import logger

class ConfigManager:
    """Configuration management library for Robot Framework"""
    
    def __init__(self):
        self.config = {}
        self.env_loaded = False
        
    @keyword('Load Configuration')
    def load_configuration(self, config_path='config/config.yaml', env_path='.env'):
        """Load configuration from YAML and environment files"""
        try:
            # Load .env file
            if os.path.exists(env_path) and not self.env_loaded:
                load_dotenv(env_path)
                self.env_loaded = True
                logger.info(f"Loaded environment variables from {env_path}")
            
            # Load YAML config
            if os.path.exists(config_path):
                with open(config_path, 'r') as f:
                    self.config = yaml.safe_load(f)
                logger.info(f"Loaded configuration from {config_path}")
            else:
                logger.warn(f"Configuration file {config_path} not found")
                
        except Exception as e:
            logger.error(f"Failed to load configuration: {str(e)}")
            raise
            
        return self.config
    
    @keyword('Get Config Value')
    def get_config_value(self, key_path, default=None):
        """Get configuration value using dot notation (e.g., 'api.base_url')"""
        try:
            keys = key_path.split('.')
            value = self.config
            
            for key in keys:
                value = value[key]
                
            logger.info(f"Retrieved config value for '{key_path}': {value}")
            return value
            
        except (KeyError, TypeError):
            env_key = key_path.upper().replace('.', '_')
            env_value = os.getenv(env_key, default)
            
            if env_value is not None:
                logger.info(f"Retrieved environment value for '{env_key}': {env_value}")
                return env_value
            
            logger.warn(f"Config key '{key_path}' not found, using default: {default}")
            return default
    
    @keyword('Set Config Value')
    def set_config_value(self, key_path, value):
        """Set configuration value using dot notation"""
        try:
            keys = key_path.split('.')
            config_ref = self.config
            
            # Navigate to the parent of the target key
            for key in keys[:-1]:
                if key not in config_ref:
                    config_ref[key] = {}
                config_ref = config_ref[key]
            
            # Set the value
            config_ref[keys[-1]] = value
            logger.info(f"Set config value '{key_path}' to: {value}")
            
        except Exception as e:
            logger.error(f"Failed to set config value '{key_path}': {str(e)}")
            raise
    
    @keyword('Get Environment Variable')
    def get_environment_variable(self, var_name, default=None):
        """Get environment variable with optional default"""
        value = os.getenv(var_name, default)
        logger.info(f"Environment variable '{var_name}': {value}")
        return value
    
    @keyword('Dump Configuration')
    def dump_configuration(self):
        """Dump current configuration for debugging"""
        config_str = json.dumps(self.config, indent=2)
        logger.info(f"Current configuration:\n{config_str}")
        return config_str
