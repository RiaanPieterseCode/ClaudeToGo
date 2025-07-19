# 📱 ClaudeToGo - Mobile Notifications for Claude Code

Get instant mobile notifications when your Claude Code tasks complete or need input. Never miss a long-running task completion again!

## ⚠️ SETUP WARNING - READ BEFORE INSTALLATION

**🚨 CAUTION**: This project's setup scripts can affect your existing development environment. Read warnings below before proceeding.

### Real Issues That Can Break Your Setup
- **Node.js Conflicts**: Forces Node.js 20 installation, may break projects using different versions
- **Missing PWA Files**: Critical icon files missing - deployment will fail
- **Directory Overwrites**: Scripts may overwrite existing projects without backup
- **Git Repository Risk**: Deploy script can affect existing git repositories
- **Package Conflicts**: npm installs without checking existing lock files

### 🛡️ SAFE INSTALLATION RECOMMENDATIONS
1. **Test in isolation**: Use a separate directory for initial setup
2. **Check Node version**: Run `node --version` to verify compatibility
3. **Backup important projects**: Especially if testing in existing directories
4. **Manual setup preferred**: For better control over the process

### 🔒 Security Note
ClaudeToGo uses standard developer credential practices (environment variables). Your security depends on your laptop security - keep it encrypted and locked when away.

## 🎯 What You're Building

A real-time notification system that sends push notifications to your mobile device when:
- Claude Code completes a task
- Claude Code needs your input
- Long-running operations finish

**Architecture**: Linux Laptop (Claude Code) → Supabase API → PWA (Netlify) → Mobile Device Notifications

## 📋 Prerequisites

### Required Accounts (All Free Tiers Available)
1. **GitHub Account** - You probably have this already
2. **Supabase Account** - Sign up at [supabase.com](https://supabase.com)
3. **Netlify Account** - Sign up at [netlify.com](https://netlify.com)

### System Requirements
- Linux (Debian/Ubuntu/Mint/PopOS)
- Node.js 18+ (we'll install this)
- Claude Code installed
- Modern browser (Chrome/Firefox/Safari)

## 🚀 Quick Setup (Automated) - ⚠️ NOT RECOMMENDED

**WARNING**: The automated setup script has critical issues and is **NOT RECOMMENDED** for production environments.

### Why Automated Setup Is Risky
- Forces Node.js installation without checking existing setups
- Modifies system configuration without backup
- Stores credentials insecurely in shell configs
- No rollback mechanism if installation fails
- Can break existing development environments

### If You Must Use Automated Setup
```bash
# ⚠️ ONLY run this in an isolated test environment
# NEVER on your main development machine
curl -fsSL https://raw.githubusercontent.com/yourusername/claude-to-go/main/scripts/setup.sh | bash
```

**STRONGLY RECOMMENDED**: Follow the manual setup below for full control and safety.

## 🛠️ Manual Setup

### Step 1: Install Dependencies ⚠️ READ FIRST

**CRITICAL**: These commands will modify your system. Check compatibility first!

```bash
# ⚠️ BACKUP YOUR CURRENT SETUP FIRST
cp ~/.bashrc ~/.bashrc.backup
cp ~/.zshrc ~/.zshrc.backup 2>/dev/null || true

# ⚠️ CHECK EXISTING NODE.JS VERSION FIRST
node --version 2>/dev/null || echo "Node.js not installed"
# If you have Node.js and need a different version, consider using nvm instead

# Update system (generally safe)
sudo apt update && sudo apt upgrade -y

# ⚠️ WARNING: This will install Node.js 20 LTS system-wide
# May conflict with existing Node.js installations or projects requiring different versions
# Consider using nvm (Node Version Manager) instead for safer version management
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Git (if not already installed) - generally safe
sudo apt install git -y

# Verify installations
node --version  # Should be v20.x.x
npm --version   # Should be 10.x.x
git --version   # Should show git version
```

### Alternative: Safer Node.js Installation with nvm
```bash
# Install nvm (Node Version Manager) for safer version management
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc

# Install Node.js 20 without affecting system-wide installation
nvm install 20
nvm use 20
```

### Step 2: Create Supabase Project

1. **Sign up/Login to Supabase**
   - Go to [supabase.com](https://supabase.com)
   - Click "Start your project" 
   - Sign up with GitHub (recommended)

2. **Create New Project**
   - Click "New Project"
   - Choose organization (create if needed)
   - Name: `claude-to-go`
   - Database Password: Generate strong password (save it!)
   - Region: Choose closest to your location
   - Click "Create new project"

3. **Get Project Credentials**
   - After project creation, go to Settings → API
   - Copy and save these values:
     - `Project URL`
     - `anon public` key
     - `service_role` key (keep this secret!)

4. **Set up Database Schema**
   - Go to SQL Editor in your Supabase dashboard
   - Run this SQL to create the notifications table:

```sql
-- Create notifications table
CREATE TABLE public.notifications (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL,
  message text NOT NULL,
  event_type text NOT NULL DEFAULT 'notification',
  metadata jsonb DEFAULT '{}',
  read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Create policy so users can only see their own notifications
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

-- Create policy so the service can insert notifications
CREATE POLICY "Service can insert notifications" ON public.notifications
  FOR INSERT WITH CHECK (true);

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
```

### Step 3: Set up the PWA

1. **Clone and Set up the PWA**

```bash
# Create project directory
mkdir claude-to-go-pwa
cd claude-to-go-pwa

# Initialize the project
npm init -y

# Install dependencies
npm install @supabase/supabase-js
npm install -D vite @vitejs/plugin-react vite-plugin-pwa workbox-window
```

2. **Create the PWA files** (we'll provide these in the repository)

### Step 4: Deploy to Netlify

1. **Push to GitHub**
   - Create a new repository on GitHub: `claude-to-go-pwa`
   - Push your PWA code to the repository

2. **Deploy on Netlify**
   - Go to [netlify.com](https://netlify.com) and sign up/login
   - Click "Add new site" → "Import an existing project"
   - Choose "Deploy with GitHub"
   - Select your `claude-to-go-pwa` repository
   - Build settings:
     - Build command: `npm run build`
     - Publish directory: `dist`
   - Click "Deploy site"

3. **Configure Environment Variables**
   - In Netlify dashboard, go to Site settings → Environment variables
   - Add these variables:
     - `VITE_SUPABASE_URL`: Your Supabase project URL
     - `VITE_SUPABASE_ANON_KEY`: Your Supabase anon public key

4. **Get Your PWA URL**
   - After deployment, copy your PWA URL (something like `https://amazing-app-123.netlify.app`)

### Step 5: Configure Claude Code Hooks

**Standard Developer Practice**: ClaudeToGo stores credentials as environment variables (like most development tools).

1. **Create Environment Variables**

```bash
# Add to your ~/.bashrc or ~/.zshrc (standard practice)
export CTG_NOTIFICATIONS_URL="https://your-pwa-url.netlify.app"
export CTG_SUPABASE_URL="your-supabase-project-url"
export CTG_SUPABASE_SERVICE_KEY="your-supabase-service-role-key"
export CTG_USER_ID="your-user-id-from-pwa"

# Reload your shell
source ~/.bashrc  # or source ~/.zshrc
```

**Note**: The CTG_ prefix prevents conflicts with existing environment variables.

2. **Set up Claude Code Hooks**

Create or edit your Claude Code settings file:

```bash
# Create settings directory if it doesn't exist
mkdir -p ~/.config/claude-code

# Edit settings file
nano ~/.config/claude-code/settings.json
```

Add this hook configuration:

```json
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
```

### ⚠️ Note: Hook Behavior
**IMPORTANT**: These hooks will trigger on **ALL** Claude Code operations, which may result in notification spam. Consider adding selective matchers for production use.

### Step 6: Test the System

1. **Open PWA on Mobile**
   - Visit your Netlify PWA URL on your mobile device
   - Allow notifications when prompted
   - Sign up/login to get your user ID

2. **Test Notifications**
   - Run a Claude Code command: `claude help`
   - You should receive a mobile notification when it completes

3. **Test Input Notifications**
   - Start a Claude Code session that requires input
   - You should receive a notification when Claude needs your input

## 🔧 Configuration Options

### Customizing Notifications

Edit the hook commands in your `settings.json` to customize:
- Notification titles and messages
- Which events trigger notifications
- Add filters to prevent spam

### Security Settings

- Never commit your service keys to git
- Use environment variables for all sensitive data
- Consider rotating keys periodically

## 🎯 Usage

1. **Start Claude Code task**
2. **Step away from your computer**
3. **Receive mobile notification when:**
   - Task completes
   - Input is needed
   - Errors occur

ClaudeToGo runs seamlessly in the background, keeping you connected to your development workflow.

## 🔍 Troubleshooting

### No Notifications Received
1. Check browser permissions for notifications
2. Verify environment variables are set correctly: `echo $CTG_SUPABASE_SERVICE_KEY`
3. Check Supabase logs for API errors
4. Test curl commands manually with your credentials

### PWA Not Working (⚠️ Known Issues)
1. Ensure HTTPS is enabled (Netlify provides this automatically)
2. **Missing PWA Assets**: Critical - PWA icons are missing from template
3. Check service worker registration in browser dev tools
4. Verify manifest.json is accessible

### Hook Errors
1. Test curl commands manually with your credentials
2. Check Claude Code hook logs
3. Verify Supabase RLS policies allow inserts
4. **Check for notification spam**: Hooks trigger on ALL operations

### Environment Issues
1. **Node.js Conflicts**: Check if installation broke existing projects (`node --version`)
2. **Directory Conflicts**: Ensure scripts didn't overwrite important files
3. **Git Issues**: Check if deploy script affected existing repositories
4. **Package Issues**: Check for npm/dependency conflicts

## 🚧 Development

### Local Development

```bash
# Start local development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### Making Changes

1. Edit PWA code locally
2. Push to GitHub
3. Netlify automatically rebuilds and deploys

## 📚 Resources

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Supabase Documentation](https://supabase.com/docs)
- [Netlify Documentation](https://docs.netlify.com)
- [PWA Documentation](https://web.dev/progressive-web-apps/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

---

## ⚠️ SETUP SUMMARY

**Before implementing ClaudeToGo:**
1. **Test in isolation** - Use a separate directory for initial setup
2. **Check Node.js compatibility** - Verify with existing projects (`node --version`)  
3. **Backup important files** - Especially if testing in existing directories
4. **Consider manual setup** - For better control over the process
5. **Note missing PWA assets** - You'll need to add icon files for deployment

**ClaudeToGo works but has some setup quirks that need attention.**

**Need help?** Open an issue on GitHub or check the troubleshooting section above.