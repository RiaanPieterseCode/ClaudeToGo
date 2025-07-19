#!/bin/bash

# Deploy ClaudeToGo PWA to Netlify
# This script helps automate the deployment process

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
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

echo "🚀 ClaudeToGo - Netlify Deployment Helper"
echo ""

# Check if we're in a PWA project directory
if [ ! -f "package.json" ]; then
    print_error "No package.json found. Please run this script from your PWA directory."
    exit 1
fi

# Check if git is initialized
if [ ! -d ".git" ]; then
    print_status "Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: Claude Code Notifications PWA"
fi

# Check if remote origin exists
if ! git remote get-url origin >/dev/null 2>&1; then
    echo ""
    print_warning "No git remote found. You need to create a GitHub repository first."
    echo ""
    echo "Steps to create GitHub repository:"
    echo "1. Go to https://github.com/new"
    echo "2. Create a repository named 'claudetogo-pwa'"
    echo "3. Copy the repository URL"
    echo ""
    
    GITHUB_REPO=$(get_input "Enter your GitHub repository URL")
    
    if [ -n "$GITHUB_REPO" ]; then
        git remote add origin "$GITHUB_REPO"
        print_success "Added remote origin: $GITHUB_REPO"
    else
        print_error "GitHub repository URL is required"
        exit 1
    fi
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    print_warning ".env file not found. Creating from template..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_warning "Please edit .env with your Supabase credentials before continuing."
        read -p "Press Enter after editing .env file..."
    else
        print_error "No .env.example found. Please create .env manually."
        exit 1
    fi
fi

# Check environment variables
if ! grep -q "VITE_SUPABASE_URL=https://" .env 2>/dev/null; then
    print_error "Please configure VITE_SUPABASE_URL in your .env file"
    exit 1
fi

if ! grep -q "VITE_SUPABASE_ANON_KEY=" .env 2>/dev/null; then
    print_error "Please configure VITE_SUPABASE_ANON_KEY in your .env file"
    exit 1
fi

print_success "Environment variables configured"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    print_status "Installing dependencies..."
    npm install
fi

# Test build
print_status "Testing build process..."
if npm run build; then
    print_success "Build successful"
else
    print_error "Build failed. Please fix errors before deploying."
    exit 1
fi

# Commit and push to GitHub
print_status "Committing and pushing to GitHub..."
git add .
git commit -m "ClaudeToGo: Ready for Netlify deployment" || true  # Don't fail if nothing to commit
git push -u origin main || git push -u origin master

print_success "Code pushed to GitHub"

echo ""
print_success "🎉 Ready for Netlify deployment!"
echo ""
echo "Next steps:"
echo "1. Go to https://netlify.com and sign in"
echo "2. Click 'Add new site' → 'Import an existing project'"
echo "3. Choose 'Deploy with GitHub'"
echo "4. Select your repository"
echo "5. Configure build settings:"
echo "   - Build command: npm run build"
echo "   - Publish directory: dist"
echo "6. Add environment variables in Netlify:"
echo "   - VITE_SUPABASE_URL: $(grep VITE_SUPABASE_URL .env | cut -d= -f2)"
echo "   - VITE_SUPABASE_ANON_KEY: [your anon key]"
echo "7. Deploy!"
echo ""
print_status "After deployment, update your CTG_NOTIFICATIONS_URL environment variable with the Netlify URL."

# Create a deployment checklist
cat > DEPLOYMENT_CHECKLIST.md << 'EOF'
# Netlify Deployment Checklist

## Pre-deployment
- [x] Code pushed to GitHub
- [x] Build tested locally
- [x] Environment variables configured

## Netlify Setup
- [ ] Netlify account created
- [ ] Repository connected to Netlify
- [ ] Build settings configured:
  - Build command: `npm run build`
  - Publish directory: `dist`
- [ ] Environment variables added:
  - `VITE_SUPABASE_URL`
  - `VITE_SUPABASE_ANON_KEY`
- [ ] Site deployed successfully

## Post-deployment
- [ ] PWA accessible at Netlify URL
- [ ] Authentication working
- [ ] Notifications permission can be granted
- [ ] Test notifications working
- [ ] Real-time updates working

## Claude Code Configuration
- [ ] Update `CTG_NOTIFICATIONS_URL` environment variable
- [ ] Update Claude Code hooks configuration
- [ ] Test end-to-end notification flow

## Final Test
- [ ] Run Claude Code command
- [ ] Receive mobile notification
- [ ] Notification appears in PWA
EOF

print_success "Created DEPLOYMENT_CHECKLIST.md for tracking progress"