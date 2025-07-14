# Environment Variables Support - Changelog

## Overview

This update adds support for configuring API keys through environment variables, providing better security and flexibility for deployment scenarios.

## Changes Made

### 1. Core Code Changes

#### `app/services/material.py`
- **Modified**: `get_api_key()` function
- **Added**: Environment variable support for `pexels_api_keys` and `pixabay_api_keys`
- **Features**:
  - Priority: Environment variables > Configuration file
  - Support for multiple API keys (comma-separated)
  - Automatic key rotation for load balancing
  - Fallback to config.toml if environment variables not set

#### `app/services/llm.py`
- **Modified**: OpenAI API key retrieval logic
- **Added**: Environment variable support for `openai_api_key`
- **Features**:
  - Priority: Environment variables > Configuration file
  - Updated error messages to mention both configuration methods

#### `app/config/config.py`
- **Added**: Automatic .env file loading
- **Features**:
  - Uses python-dotenv library
  - Graceful fallback if dotenv not installed
  - Logs loading status

### 2. Configuration Files

#### `config.example.toml`
- **Added**: Environment variable documentation
- **Updated**: Comments for all three API key configurations
- **Added**: Priority information and usage examples

#### `requirements.txt`
- **Added**: `python-dotenv>=1.0.0` dependency

#### `.gitignore`
- **Added**: Environment variable file patterns
  - `.env`
  - `.env.local`
  - `.env.*.local`

### 3. Documentation

#### `env.example`
- **Created**: Environment variables template file
- **Includes**: All three API key configurations
- **Added**: Usage examples and comments

#### `ENVIRONMENT_VARIABLES.md`
- **Created**: Comprehensive environment variables guide
- **Includes**:
  - Setup instructions for different platforms
  - Security best practices
  - Troubleshooting guide
  - Multiple deployment scenarios

#### `USAGE_EXAMPLES.md`
- **Created**: Practical usage examples
- **Includes**:
  - Quick start guide
  - Docker deployment examples
  - Production deployment scenarios
  - Security best practices

#### `README.md` and `README-en.md`
- **Updated**: Configuration section
- **Added**: Environment variables as recommended method
- **Added**: Links to detailed documentation

### 4. Testing

#### `test_env.py`
- **Created**: Environment variables test script
- **Features**:
  - Verifies .env file loading
  - Checks environment variable status
  - Tests configuration module loading
  - Security-conscious output (masks API keys)

## Supported Environment Variables

| Variable | Description | Format | Example |
|----------|-------------|--------|---------|
| `PEXELS_API_KEYS` | Pexels API keys for video search | Single key or comma-separated | `key1,key2,key3` |
| `PIXABAY_API_KEYS` | Pixabay API keys for video search | Single key or comma-separated | `key1,key2,key3` |
| `OPENAI_API_KEY` | OpenAI API key for LLM services | Single key | `your_openai_key` |

## Priority Order

1. **Environment Variables** (highest priority)
2. **config.toml file** (fallback)

## Installation

```bash
# Install the new dependency
pip install python-dotenv>=1.0.0

# Or install all dependencies
pip install -r requirements.txt
```

## Usage

### Quick Start
```bash
# Copy environment template
cp env.example .env

# Edit with your API keys
nano .env

# Test configuration
python test_env.py
```

### Environment Variables Format
```bash
# Single keys
PEXELS_API_KEYS=your_pexels_key
PIXABAY_API_KEYS=your_pixabay_key
OPENAI_API_KEY=your_openai_key

# Multiple keys (no spaces around commas)
PEXELS_API_KEYS=key1,key2,key3
PIXABAY_API_KEYS=key1,key2,key3
```

## Benefits

1. **Security**: API keys not stored in version control
2. **Flexibility**: Easy to use different keys for different environments
3. **Deployment**: Better support for containerized deployments
4. **Compliance**: Follows security best practices
5. **Backward Compatibility**: Existing config.toml files still work

## Migration Guide

### From config.toml to Environment Variables

1. **Extract API keys** from your existing `config.toml`
2. **Create .env file**:
   ```bash
   cp env.example .env
   ```
3. **Add your keys** to `.env` file
4. **Test configuration**: `python test_env.py`
5. **Optional**: Remove keys from `config.toml` for security

### Docker Users

Update your docker-compose.yml or docker run commands to include environment variables:

```yaml
environment:
  - PEXELS_API_KEYS=your_pexels_key
  - PIXABAY_API_KEYS=your_pixabay_key
  - OPENAI_API_KEY=your_openai_key
```

## Security Notes

- `.env` files are automatically ignored by git
- Environment variables take precedence over config files
- API keys are masked in test output
- Multiple keys support automatic rotation for load balancing

## Troubleshooting

If you encounter issues:

1. **Check environment variables**: `echo $PEXELS_API_KEYS`
2. **Verify .env file**: `python test_env.py`
3. **Check documentation**: `ENVIRONMENT_VARIABLES.md`
4. **Review examples**: `USAGE_EXAMPLES.md`

## Future Enhancements

Potential future improvements:
- Support for more API providers via environment variables
- Encrypted environment variable support
- Integration with secret management services
- Environment-specific configuration profiles 