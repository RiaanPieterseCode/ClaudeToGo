#!/bin/bash

# Test script for ClaudeToGo notifications
# This script helps test if your notification system is working

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo "🧪 Testing ClaudeToGo Notifications System"
echo ""

# Check if required environment variables are set
print_status "Checking environment variables..."

if [ -z "$CTG_SUPABASE_URL" ]; then
    print_error "CTG_SUPABASE_URL environment variable not set"
    exit 1
fi

if [ -z "$CTG_SUPABASE_SERVICE_KEY" ]; then
    print_error "CTG_SUPABASE_SERVICE_KEY environment variable not set"
    exit 1
fi

if [ -z "$CTG_USER_ID" ]; then
    print_error "CTG_USER_ID environment variable not set"
    print_warning "Get your user ID from the PWA after login"
    exit 1
fi

print_success "All environment variables are set"

# Test basic connectivity to Supabase
print_status "Testing Supabase connectivity..."

response=$(curl -s -w "%{http_code}" -o /tmp/supabase_test \
    -H "apikey: $CTG_SUPABASE_SERVICE_KEY" \
    -H "Authorization: Bearer $CTG_SUPABASE_SERVICE_KEY" \
    "$CTG_SUPABASE_URL/rest/v1/notifications?select=count")

http_code="${response: -3}"

if [ "$http_code" = "200" ]; then
    print_success "Supabase connection successful"
else
    print_error "Supabase connection failed (HTTP $http_code)"
    cat /tmp/supabase_test
    exit 1
fi

# Test sending a notification
print_status "Sending test notification..."

test_response=$(curl -s -w "%{http_code}" -o /tmp/test_notification \
    -X POST "$CTG_SUPABASE_URL/rest/v1/notifications" \
    -H "apikey: $CTG_SUPABASE_SERVICE_KEY" \
    -H "Authorization: Bearer $CTG_SUPABASE_SERVICE_KEY" \
    -H "Content-Type: application/json" \
    -d "{
        \"user_id\": \"$CTG_USER_ID\",
        \"title\": \"Test Notification\",
        \"message\": \"This is a test notification from the setup script at $(date)\",
        \"event_type\": \"test\"
    }")

test_http_code="${test_response: -3}"

if [ "$test_http_code" = "201" ]; then
    print_success "Test notification sent successfully!"
    print_status "Check your mobile device for the notification."
else
    print_error "Failed to send test notification (HTTP $test_http_code)"
    cat /tmp/test_notification
    exit 1
fi

# Test Claude Code hooks configuration
print_status "Checking Claude Code hooks configuration..."

CLAUDE_SETTINGS="$HOME/.config/claude-code/settings.json"

if [ -f "$CLAUDE_SETTINGS" ]; then
    if grep -q "notifications" "$CLAUDE_SETTINGS"; then
        print_success "Claude Code hooks are configured"
    else
        print_warning "Claude Code settings file exists but may not have notification hooks"
    fi
else
    print_warning "Claude Code settings file not found at $CLAUDE_SETTINGS"
    print_status "You may need to run: /hooks in Claude Code to configure hooks"
fi

echo ""
print_success "🎉 Test complete!"
echo ""
print_status "What to do next:"
echo "1. Check your mobile device for the test notification"
echo "2. If you received it, the system is working!"
echo "3. If not, check the PWA is open and notifications are enabled"
echo "4. Try running a Claude Code command to test the hooks"

# Cleanup
rm -f /tmp/supabase_test /tmp/test_notification