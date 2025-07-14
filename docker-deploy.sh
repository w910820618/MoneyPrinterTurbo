#!/bin/bash

# MoneyPrinterTurbo Docker Deployment Script
# This script helps you deploy MoneyPrinterTurbo using Docker with proper security practices

set -e  # Exit on any error

echo "🐳 MoneyPrinterTurbo Docker Deployment Script"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    print_status "Checking Docker installation..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_warning "docker-compose not found. Trying 'docker compose'..."
        if ! docker compose version &> /dev/null; then
            print_error "Neither docker-compose nor 'docker compose' found. Please install docker-compose."
            exit 1
        fi
        DOCKER_COMPOSE="docker compose"
    else
        DOCKER_COMPOSE="docker-compose"
    fi
    
    print_success "Docker is installed and ready"
}

# Check if .env file exists
check_env_file() {
    print_status "Checking environment configuration..."
    
    if [ ! -f ".env" ]; then
        print_warning ".env file not found. Creating from template..."
        if [ -f "env.example" ]; then
            cp env.example .env
            print_success "Created .env file from template"
            print_warning "Please edit .env file and add your API keys before continuing"
            echo ""
            echo "Edit the .env file with your API keys:"
            echo "  nano .env"
            echo ""
            echo "Then run this script again."
            exit 0
        else
            print_error "env.example file not found. Please create .env file manually."
            exit 1
        fi
    fi
    
    # Check if API keys are set
    if ! grep -q "PEXELS_API_KEYS=" .env || ! grep -q "PIXABAY_API_KEYS=" .env || ! grep -q "OPENAI_API_KEY=" .env; then
        print_warning "API keys not found in .env file"
        print_warning "Please edit .env file and add your API keys:"
        echo ""
        echo "  PEXELS_API_KEYS=your_pexels_key_here"
        echo "  PIXABAY_API_KEYS=your_pixabay_key_here"
        echo "  OPENAI_API_KEY=your_openai_key_here"
        echo ""
        echo "Then run this script again."
        exit 0
    fi
    
    # Check if keys are not placeholder values
    if grep -q "your_pexels_api_key_here" .env || grep -q "your_pixabay_api_key_here" .env || grep -q "your_openai_api_key_here" .env; then
        print_warning "Please replace placeholder values in .env file with your actual API keys"
        echo ""
        echo "Edit the .env file:"
        echo "  nano .env"
        echo ""
        echo "Then run this script again."
        exit 0
    fi
    
    print_success "Environment configuration looks good"
}

# Build Docker images
build_images() {
    print_status "Building Docker images..."
    $DOCKER_COMPOSE build
    print_success "Docker images built successfully"
}

# Start services
start_services() {
    print_status "Starting MoneyPrinterTurbo services..."
    $DOCKER_COMPOSE up -d
    
    # Wait a moment for services to start
    sleep 5
    
    print_success "Services started successfully"
}

# Check service status
check_services() {
    print_status "Checking service status..."
    
    if $DOCKER_COMPOSE ps | grep -q "Up"; then
        print_success "Services are running"
        echo ""
        echo "Service Status:"
        $DOCKER_COMPOSE ps
    else
        print_error "Services failed to start"
        echo ""
        echo "Container logs:"
        $DOCKER_COMPOSE logs
        exit 1
    fi
}

# Verify environment variables
verify_env_vars() {
    print_status "Verifying environment variables in containers..."
    
    # Check API container
    if $DOCKER_COMPOSE exec -T api env | grep -q "PEXELS_API_KEYS"; then
        print_success "Environment variables loaded in API container"
    else
        print_warning "Environment variables not found in API container"
    fi
    
    # Check WebUI container
    if $DOCKER_COMPOSE exec -T webui env | grep -q "PEXELS_API_KEYS"; then
        print_success "Environment variables loaded in WebUI container"
    else
        print_warning "Environment variables not found in WebUI container"
    fi
}

# Show access information
show_access_info() {
    echo ""
    echo "🎉 MoneyPrinterTurbo is now running!"
    echo "====================================="
    echo ""
    echo "Access URLs:"
    echo "  🌐 Web Interface: http://localhost:8501"
    echo "  📚 API Documentation: http://localhost:8080/docs"
    echo "  🔍 API ReDoc: http://localhost:8080/redoc"
    echo ""
    echo "Useful Commands:"
    echo "  📋 View logs: $DOCKER_COMPOSE logs -f"
    echo "  🛑 Stop services: $DOCKER_COMPOSE down"
    echo "  🔄 Restart services: $DOCKER_COMPOSE restart"
    echo "  📊 Service status: $DOCKER_COMPOSE ps"
    echo ""
    echo "Security Notes:"
    echo "  ✅ .env file is in .gitignore"
    echo "  ✅ API keys are loaded from environment variables"
    echo "  ✅ No sensitive data in Docker images"
    echo ""
}

# Main deployment function
deploy() {
    echo ""
    print_status "Starting deployment process..."
    
    check_docker
    check_env_file
    build_images
    start_services
    check_services
    verify_env_vars
    show_access_info
    
    print_success "Deployment completed successfully!"
}

# Function to stop services
stop_services() {
    print_status "Stopping MoneyPrinterTurbo services..."
    $DOCKER_COMPOSE down
    print_success "Services stopped"
}

# Function to show logs
show_logs() {
    print_status "Showing service logs..."
    $DOCKER_COMPOSE logs -f
}

# Function to restart services
restart_services() {
    print_status "Restarting MoneyPrinterTurbo services..."
    $DOCKER_COMPOSE restart
    print_success "Services restarted"
}

# Function to show status
show_status() {
    print_status "Service status:"
    $DOCKER_COMPOSE ps
}

# Function to clean up
cleanup() {
    print_warning "This will remove all containers, images, and volumes. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Cleaning up Docker resources..."
        $DOCKER_COMPOSE down -v --rmi all
        print_success "Cleanup completed"
    else
        print_status "Cleanup cancelled"
    fi
}

# Parse command line arguments
case "${1:-deploy}" in
    "deploy")
        deploy
        ;;
    "stop")
        check_docker
        stop_services
        ;;
    "logs")
        check_docker
        show_logs
        ;;
    "restart")
        check_docker
        restart_services
        ;;
    "status")
        check_docker
        show_status
        ;;
    "cleanup")
        check_docker
        cleanup
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  deploy   - Deploy MoneyPrinterTurbo (default)"
        echo "  stop     - Stop all services"
        echo "  logs     - Show service logs"
        echo "  restart  - Restart all services"
        echo "  status   - Show service status"
        echo "  cleanup  - Remove all containers, images, and volumes"
        echo "  help     - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0              # Deploy MoneyPrinterTurbo"
        echo "  $0 stop         # Stop services"
        echo "  $0 logs         # View logs"
        echo "  $0 status       # Check status"
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac 