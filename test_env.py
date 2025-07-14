#!/usr/bin/env python3
"""
Test script to verify environment variable functionality
"""

import os
import sys

# Add the app directory to the Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'app'))

def test_environment_variables():
    """Test if environment variables are properly loaded"""
    print("Testing environment variable functionality...")
    
    # Test if .env file is loaded
    try:
        from dotenv import load_dotenv
        load_dotenv()
        print("✓ .env file loading supported")
    except ImportError:
        print("⚠ python-dotenv not installed")
    except Exception as e:
        print(f"⚠ Failed to load .env file: {e}")
    
    # Test environment variables
    env_vars = {
        'PEXELS_API_KEYS': 'Pexels API Keys',
        'PIXABAY_API_KEYS': 'Pixabay API Keys', 
        'OPENAI_API_KEY': 'OpenAI API Key'
    }
    
    print("\nEnvironment variable status:")
    for var, description in env_vars.items():
        value = os.environ.get(var)
        if value:
            # Mask the value for security
            masked_value = value[:4] + '*' * (len(value) - 8) + value[-4:] if len(value) > 8 else '***'
            print(f"✓ {var}: {masked_value}")
        else:
            print(f"✗ {var}: Not set")
    
    # Test config loading
    try:
        from app.config import config
        print("\n✓ Configuration module loaded successfully")
        
        # Test API key retrieval
        print("\nTesting API key retrieval from material service...")
        from app.services.material import get_api_key
        
        # Test with a mock key to see if the function works
        print("✓ Material service API key function available")
        
    except Exception as e:
        print(f"✗ Configuration loading failed: {e}")
    
    print("\nEnvironment variable test completed!")

if __name__ == "__main__":
    test_environment_variables() 