#!/bin/bash

# Environment setup helper for ClaudeToGo

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

get_input() {
    local prompt="$1"
    local default="$2"
    local result
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " result
        echo "${result:-$default}"
    else
        read -p "$prompt: " result
        echo "$result"
    fi
}

echo "🔧 ClaudeToGo Environment Setup"
echo ""

# Get shell configuration file
SHELL_NAME=$(basename "$SHELL")
case $SHELL_NAME in
    "bash")
        SHELL_CONFIG="$HOME/.bashrc"
        ;;
    "zsh")
        SHELL_CONFIG="$HOME/.zshrc"
        ;;
    "fish")
        SHELL_CONFIG="$HOME/.config/fish/config.fish"
        ;;
    *)
        print_warning "Unknown shell: $SHELL_NAME"
        SHELL_CONFIG=$(get_input "Path to your shell configuration file" "$HOME/.bashrc")
        ;;
esac

print_status "Using shell config: $SHELL_CONFIG"

# Get configuration values
echo ""
echo "Enter your configuration values:"

SUPABASE_URL=$(get_input "Supabase Project URL" "$CTG_SUPABASE_URL")
SUPABASE_SERVICE_KEY=$(get_input "Supabase Service Role Key" "$CTG_SUPABASE_SERVICE_KEY")
NETLIFY_URL=$(get_input "Netlify PWA URL (after deployment)" "$CTG_NOTIFICATIONS_URL")
CLAUDE_USER_ID=$(get_input "Claude User ID (from PWA)" "$CTG_USER_ID")

# Create environment configuration
ENV_CONFIG="
# ClaudeToGo Configuration
export CTG_SUPABASE_URL=\"$SUPABASE_URL\"
export CTG_SUPABASE_SERVICE_KEY=\"$SUPABASE_SERVICE_KEY\"
export CTG_NOTIFICATIONS_URL=\"$NETLIFY_URL\"
export CTG_USER_ID=\"$CLAUDE_USER_ID\"
"

echo ""
print_status "Configuration to be added:"
echo "$ENV_CONFIG"

read -p "Add this configuration to $SHELL_CONFIG? (y/N): " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "$ENV_CONFIG" >> "$SHELL_CONFIG"
    print_success "Configuration added to $SHELL_CONFIG"
    
    # Source the configuration
    if [ "$SHELL_NAME" = "fish" ]; then
        print_status "Reload your shell or run: source $SHELL_CONFIG"
    else
        source "$SHELL_CONFIG"
        print_success "Configuration loaded into current session"
    fi
else
    echo ""
    print_warning "Configuration not added automatically."
    print_status "Add these lines manually to your shell configuration:"
    echo "$ENV_CONFIG"
fi

echo ""
print_status "Testing environment variables..."

if [ -n "$CTG_SUPABASE_URL" ] && [ -n "$CTG_SUPABASE_SERVICE_KEY" ]; then
    print_success "Environment variables are available"
    
    # Test Supabase connection
    print_status "Testing Supabase connection..."
    if curl -s -f -H "apikey: $CTG_SUPABASE_SERVICE_KEY" "$CTG_SUPABASE_URL/rest/v1/" >/dev/null; then
        print_success "Supabase connection successful"
    else
        print_warning "Supabase connection test failed - check your credentials"
    fi
else
    print_warning "Some environment variables are missing"
    print_status "You may need to restart your terminal or source your shell config"
fi

echo ""
print_success "Environment setup complete!"
print_status "Next steps:"
echo "1. Deploy your PWA to Netlify (if not done already)"
echo "2. Update CTG_NOTIFICATIONS_URL with your Netlify URL"
echo "3. Get your user ID from the PWA and update CTG_USER_ID"
echo "4. Run the test script: ./scripts/test-notifications.sh"