#!/bin/bash

# ClaudeToGo - Automated Setup Script
# For Debian/Ubuntu/Mint/PopOS systems

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

print_header() {
    echo -e "${PURPLE}=== $1 ===${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get user input with default value
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

# Function to validate URL format
validate_url() {
    local url="$1"
    if [[ $url =~ ^https://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]; then
        return 0
    else
        return 1
    fi
}

print_header "ClaudeToGo Setup"
echo "This script will help you set up ClaudeToGo mobile notifications for Claude Code."
echo "You'll need accounts with Supabase and Netlify (both have free tiers)."
echo ""

# Check if running on supported system
if ! grep -qE "(Ubuntu|Debian|Mint|Pop)" /etc/os-release 2>/dev/null; then
    print_warning "This script is designed for Ubuntu/Debian/Mint/PopOS systems."
    print_warning "It may work on other systems, but is not tested."
    read -p "Continue anyway? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Setup cancelled."
        exit 1
    fi
fi

# Check for root permissions (we don't want to run as root)
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root (don't use sudo)."
    print_error "The script will ask for sudo when needed."
    exit 1
fi

print_header "Step 1: Installing System Dependencies"

# Update package lists
print_status "Updating package lists..."
sudo apt update

# Install curl if not present
if ! command_exists curl; then
    print_status "Installing curl..."
    sudo apt install -y curl
fi

# Install git if not present
if ! command_exists git; then
    print_status "Installing git..."
    sudo apt install -y git
fi

# Check Node.js version
if command_exists node; then
    NODE_VERSION=$(node --version | cut -c2-)
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d. -f1)
    if [ "$NODE_MAJOR" -lt 18 ]; then
        print_warning "Node.js $NODE_VERSION is too old. Installing Node.js 20 LTS..."
        INSTALL_NODE=true
    else
        print_success "Node.js $NODE_VERSION is already installed and compatible."
        INSTALL_NODE=false
    fi
else
    print_status "Node.js not found. Installing Node.js 20 LTS..."
    INSTALL_NODE=true
fi

if [ "$INSTALL_NODE" = true ]; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_success "Node.js $(node --version) installed successfully."
fi

print_header "Step 2: Creating Project Directory"

# Get project directory
PROJECT_DIR=$(get_input "Enter project directory path" "$HOME/claude-to-go")

# Create project directory
if [ -d "$PROJECT_DIR" ]; then
    print_warning "Directory $PROJECT_DIR already exists."
    read -p "Continue and overwrite? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Setup cancelled."
        exit 1
    fi
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
print_success "Created project directory: $PROJECT_DIR"

print_header "Step 3: Downloading PWA Template"

# Download PWA template files
print_status "Downloading PWA template..."

# Create directory structure
mkdir -p src/components src/hooks src/utils public

# Download template files (we'll create them in the next step)
cat > package.json << 'EOF'
{
  "name": "claude-to-go-pwa",
  "version": "1.0.0",
  "description": "ClaudeToGo - Mobile notifications for Claude Code",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "@supabase/supabase-js": "^2.39.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.0.8",
    "vite-plugin-pwa": "^0.17.4",
    "workbox-window": "^7.0.0"
  }
}
EOF

print_success "Created package.json"

# Install dependencies
print_status "Installing NPM dependencies..."
npm install

print_header "Step 4: Account Configuration"

echo "Now you need to configure your Supabase and Netlify accounts."
echo "Please have the following information ready:"
echo "1. Supabase Project URL"
echo "2. Supabase Anon Key"
echo "3. Supabase Service Role Key"
echo ""

while true; do
    read -p "Have you created your Supabase project? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        break
    else
        echo ""
        print_warning "Please create your Supabase project first:"
        echo ""
        echo "📋 DETAILED SETUP STEPS:"
        echo "1. 🌐 Go to https://supabase.com and sign up/login"
        echo "2. 🆕 Click 'New Project' → Choose organization"
        echo "3. 📝 Name: 'claudetogo-notifications'"
        echo "4. 🔐 Generate strong database password (save it!)"
        echo "5. 📍 Choose region closest to you → Click 'Create new project'"
        echo "6. ⏳ Wait for project creation (takes 1-2 minutes)"
        echo "7. 🔧 Go to Settings → API → Copy your:"
        echo "   • Project URL (starts with https://...supabase.co)"
        echo "   • anon public key"
        echo "   • service_role key (keep secret!)"
        echo "8. 📊 Go to SQL Editor → Run this SQL schema:"
        echo ""
        echo "   CREATE TABLE public.notifications ("
        echo "     id uuid DEFAULT gen_random_uuid() PRIMARY KEY,"
        echo "     user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,"
        echo "     title text NOT NULL,"
        echo "     message text NOT NULL,"
        echo "     event_type text NOT NULL DEFAULT 'notification',"
        echo "     metadata jsonb DEFAULT '{}',"
        echo "     read boolean DEFAULT false,"
        echo "     created_at timestamptz DEFAULT now()"
        echo "   );"
        echo "   ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;"
        echo "   CREATE POLICY \"Users can view own notifications\" ON public.notifications"
        echo "     FOR SELECT USING (auth.uid() = user_id);"
        echo "   CREATE POLICY \"Service can insert notifications\" ON public.notifications"
        echo "     FOR INSERT WITH CHECK (true);"
        echo "   ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;"
        echo ""
        print_status "📱 This script will wait for you to complete these steps."
        echo "Press Enter when you have your Supabase credentials ready, or Ctrl+C to exit..."
        read -r
    fi
done

echo ""
echo "Enter your Supabase configuration:"

# Get Supabase configuration
while true; do
    SUPABASE_URL=$(get_input "Supabase Project URL")
    if validate_url "$SUPABASE_URL"; then
        break
    else
        print_error "Invalid URL format. Please enter a valid HTTPS URL."
    fi
done

SUPABASE_ANON_KEY=$(get_input "Supabase Anon Key")
SUPABASE_SERVICE_KEY=$(get_input "Supabase Service Role Key")

# Create environment file
cat > .env << EOF
VITE_SUPABASE_URL=$SUPABASE_URL
VITE_SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
EOF

print_success "Created .env file with Supabase configuration"

# Create environment setup script
cat > setup-env.sh << EOF
#!/bin/bash
# Add these to your ~/.bashrc or ~/.zshrc

export CTG_NOTIFICATIONS_URL="https://your-netlify-url.netlify.app"  # Update after Netlify deployment
export CTG_SUPABASE_URL="$SUPABASE_URL"
export CTG_SUPABASE_SERVICE_KEY="$SUPABASE_SERVICE_KEY"
export CTG_USER_ID="your-user-id"  # Get this from the PWA after login

echo "Environment variables configured for Claude Code hooks"
EOF

chmod +x setup-env.sh

print_header "Step 5: Claude Code Hooks Configuration"

# Create Claude Code settings directory
CLAUDE_CONFIG_DIR="$HOME/.config/claude-code"
mkdir -p "$CLAUDE_CONFIG_DIR"

# Create hooks configuration
cat > claude-hooks.json << 'EOF'
{
  "hooks": {
    "Notification": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "curl -X POST \"$CTG_SUPABASE_URL/rest/v1/notifications\" -H \"apikey: $CTG_SUPABASE_SERVICE_KEY\" -H \"Authorization: Bearer $CTG_SUPABASE_SERVICE_KEY\" -H \"Content-Type: application/json\" -d '{\"user_id\": \"'$CTG_USER_ID'\", \"title\": \"Claude Code Needs Input\", \"message\": \"'$CLAUDE_NOTIFICATION'\", \"event_type\": \"notification\"}'"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "curl -X POST \"$CTG_SUPABASE_URL/rest/v1/notifications\" -H \"apikey: $CTG_SUPABASE_SERVICE_KEY\" -H \"Authorization: Bearer $CTG_SUPABASE_SERVICE_KEY\" -H \"Content-Type: application/json\" -d '{\"user_id\": \"'$CTG_USER_ID'\", \"title\": \"Claude Code Task Complete\", \"message\": \"Your Claude Code task has finished successfully!\", \"event_type\": \"completion\"}'"
          }
        ]
      }
    ]
  }
}
EOF

print_success "Created Claude Code hooks configuration"

print_header "Setup Complete!"

echo ""
print_success "Basic setup is complete! Here's what was created:"
echo "📁 Project directory: $PROJECT_DIR"
echo "📦 NPM dependencies installed"
echo "⚙️  Environment configuration created"
echo "🔧 Claude Code hooks template created"
echo ""

print_warning "Next steps:"
echo "1. Deploy the PWA to Netlify:"
echo "   - Push this directory to GitHub"
echo "   - Connect to Netlify and deploy"
echo "   - Set environment variables in Netlify"
echo ""
echo "2. Configure environment variables:"
echo "   source $PROJECT_DIR/setup-env.sh"
echo ""
echo "3. Update Claude Code settings:"
echo "   cp $PROJECT_DIR/claude-hooks.json $CLAUDE_CONFIG_DIR/settings.json"
echo ""
echo "4. Test the system by running Claude Code commands"
echo ""

print_status "For detailed instructions, see the README.md file."
print_success "Happy coding with ClaudeToGo! 🚀"