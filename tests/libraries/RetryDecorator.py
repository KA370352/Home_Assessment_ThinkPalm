import functools
import time
import logging
from typing import Callable, Type, Union, Tuple
from robot.api.deco import keyword
from robot.api import logger

class RetryDecorator:
    """Custom retry decorator with detailed logging for Robot Framework"""
    
    def __init__(self, max_attempts: int = 3, delay: float = 1.0, 
                 backoff: float = 2.0, exceptions: Tuple[Type[Exception], ...] = (Exception,)):
        self.max_attempts = max_attempts
        self.delay = delay
        self.backoff = backoff
        self.exceptions = exceptions
        
    def __call__(self, func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            attempt = 1
            current_delay = self.delay
            
            while attempt <= self.max_attempts:
                try:
                    logger.info(f"Attempt {attempt}/{self.max_attempts} for {func.__name__}")
                    result = func(*args, **kwargs)
                    if attempt > 1:
                        logger.info(f"Success on attempt {attempt} for {func.__name__}")
                    return result
                    
                except self.exceptions as e:
                    if attempt == self.max_attempts:
                        logger.error(f"All {self.max_attempts} attempts failed for {func.__name__}. Last error: {str(e)}")
                        raise
                    
                    logger.warn(f"Attempt {attempt} failed for {func.__name__}: {str(e)}. Retrying in {current_delay}s...")
                    time.sleep(current_delay)
                    current_delay *= self.backoff
                    attempt += 1
                    
            return None
        return wrapper

@keyword('Retry Keyword')
def retry_keyword(keyword_name: str, max_attempts: int = 3, delay: float = 1.0):
    """
    Retry a Robot Framework keyword with exponential backoff
    
    Args:
        keyword_name: Name of the keyword to retry
        max_attempts: Maximum number of retry attempts
        delay: Initial delay between retries in seconds
    """
    from robot.libraries.BuiltIn import BuiltIn
    builtin = BuiltIn()
    
    attempt = 1
    current_delay = delay
    
    while attempt <= max_attempts:
        try:
            logger.info(f"Executing {keyword_name} - Attempt {attempt}/{max_attempts}")
            result = builtin.run_keyword(keyword_name)
            if attempt > 1:
                logger.info(f"Keyword {keyword_name} succeeded on attempt {attempt}")
            return result
            
        except Exception as e:
            if attempt == max_attempts:
                logger.error(f"Keyword {keyword_name} failed after {max_attempts} attempts. Error: {str(e)}")
                raise
            
            logger.warn(f"Keyword {keyword_name} failed on attempt {attempt}: {str(e)}. Retrying in {current_delay}s...")
            time.sleep(current_delay)
            current_delay *= 2.0
            attempt += 1
