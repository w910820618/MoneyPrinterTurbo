# Usage Examples

This document provides practical examples of how to configure and use MoneyPrinterTurbo with environment variables.

## Quick Start with Environment Variables

### 1. Basic Setup

```bash
# Clone the repository
git clone https://github.com/harry0703/MoneyPrinterTurbo.git
cd MoneyPrinterTurbo

# Copy the environment variables template
cp env.example .env

# Edit the .env file with your API keys
nano .env
```

### 2. Configure Your API Keys

Edit the `.env` file with your actual API keys:

```bash
# Single API key for each service
PEXELS_API_KEYS=your_pexels_api_key_here
PIXABAY_API_KEYS=your_pixabay_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
```

### 3. Multiple API Keys (Load Balancing)

For better performance and to avoid rate limits, you can use multiple API keys:

```bash
# Multiple keys separated by commas (no spaces)
PEXELS_API_KEYS=key1,key2,key3
PIXABAY_API_KEYS=key1,key2,key3
OPENAI_API_KEY=your_openai_api_key_here
```

### 4. Install Dependencies

```bash
# Install Python dependencies
pip install -r requirements.txt
```

### 5. Test Configuration

```bash
# Run the test script to verify your configuration
python test_env.py
```

### 6. Start the Application

```bash
# Start the web interface
sh webui.sh

# In another terminal, start the API service
python main.py
```

## Docker Deployment with Environment Variables

### Using docker-compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  moneyprinter:
    build: .
    ports:
      - "8080:8080"
      - "8501:8501"
    environment:
      - PEXELS_API_KEYS=your_pexels_key1,your_pexels_key2
      - PIXABAY_API_KEYS=your_pixabay_key1,your_pixabay_key2
      - OPENAI_API_KEY=your_openai_key
    volumes:
      - ./storage:/app/storage
```

### Using Docker run

```bash
docker run -d \
  -p 8080:8080 \
  -p 8501:8501 \
  -e PEXELS_API_KEYS="your_pexels_key" \
  -e PIXABAY_API_KEYS="your_pixabay_key" \
  -e OPENAI_API_KEY="your_openai_key" \
  -v $(pwd)/storage:/app/storage \
  moneyprinterturbo
```

## Production Deployment

### Using System Environment Variables

#### Linux/macOS

Add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export PEXELS_API_KEYS="your_pexels_key1,your_pexels_key2"
export PIXABAY_API_KEYS="your_pixabay_key1,your_pixabay_key2"
export OPENAI_API_KEY="your_openai_key"
```

#### Windows

Set system environment variables:

```cmd
setx PEXELS_API_KEYS "your_pexels_key1,your_pexels_key2"
setx PIXABAY_API_KEYS "your_pixabay_key1,your_pixabay_key2"
setx OPENAI_API_KEY "your_openai_key"
```

### Using a Service Manager (systemd)

Create a service file `/etc/systemd/system/moneyprinter.service`:

```ini
[Unit]
Description=MoneyPrinterTurbo
After=network.target

[Service]
Type=simple
User=your_user
WorkingDirectory=/path/to/MoneyPrinterTurbo
Environment=PEXELS_API_KEYS=your_pexels_key1,your_pexels_key2
Environment=PIXABAY_API_KEYS=your_pixabay_key1,your_pixabay_key2
Environment=OPENAI_API_KEY=your_openai_key
ExecStart=/usr/bin/python3 main.py
Restart=always

[Install]
WantedBy=multi-user.target
```

## Security Best Practices

### 1. Never Commit API Keys

```bash
# Ensure .env is in .gitignore
echo ".env" >> .gitignore

# Check if .env is tracked
git status
```

### 2. Use Different Keys for Different Environments

```bash
# Development
PEXELS_API_KEYS=dev_key1,dev_key2
PIXABAY_API_KEYS=dev_key1,dev_key2
OPENAI_API_KEY=dev_openai_key

# Production
PEXELS_API_KEYS=prod_key1,prod_key2,prod_key3
PIXABAY_API_KEYS=prod_key1,prod_key2,prod_key3
OPENAI_API_KEY=prod_openai_key
```

### 3. Rotate API Keys Regularly

```bash
# Example of key rotation
# Month 1
PEXELS_API_KEYS=key1,key2,key3

# Month 2 (rotate out key1)
PEXELS_API_KEYS=key2,key3,key4

# Month 3 (rotate out key2)
PEXELS_API_KEYS=key3,key4,key5
```

## Troubleshooting

### Check Environment Variables

```bash
# Linux/macOS
echo $PEXELS_API_KEYS
echo $PIXABAY_API_KEYS
echo $OPENAI_API_KEY

# Windows
echo %PEXELS_API_KEYS%
echo %PIXABAY_API_KEYS%
echo %OPENAI_API_KEY%
```

### Verify .env File Loading

```bash
# Test if .env file is loaded correctly
python test_env.py
```

### Common Issues

1. **Environment variables not recognized**
   - Restart your terminal/application after setting variables
   - Check for typos in variable names
   - Ensure no spaces around the `=` sign in `.env` file

2. **Multiple keys not working**
   - Use commas without spaces: `key1,key2,key3`
   - Don't use quotes around the entire value in `.env` file

3. **Docker environment variables not working**
   - Use `-e` flag for each variable
   - Check docker-compose syntax
   - Restart containers after changing environment variables 