# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ SETUP WARNINGS - READ BEFORE IMPLEMENTATION

**ATTENTION**: This project's automated setup scripts can break existing development environments. Review warnings below before proceeding.

### 🚨 Real Breaking Issues
- **Node.js Version Conflicts**: Scripts install Node.js 20 LTS, potentially breaking projects using different versions
- **Missing PWA Assets**: Critical icon files missing - will cause deployment failures
- **Directory Overwrites**: Scripts may overwrite existing projects without backup
- **Git Repository Risks**: Deploy script can corrupt existing git repositories
- **Dependency Conflicts**: npm installs without checking existing lock files

### 🛡️ Safe Implementation Guidelines
1. **BACKUP**: Create backups of important projects before running scripts
2. **CHECK NODE VERSION**: Verify compatibility with existing projects (`node --version`)
3. **ISOLATED TESTING**: Test in a separate directory first
4. **MANUAL SETUP**: Consider manual setup for better control
5. **GIT SAFETY**: Ensure you're in the right directory before running deploy scripts

## Project Overview

ClaudeToGo is a mobile notifications system for Claude Code. This repository contains the complete implementation including documentation, setup scripts, and PWA template. The project enables real-time mobile notifications for developers using Claude Code.

**STATUS**: ⚠️ Functional but requires careful implementation to avoid environment conflicts

## Architecture

ClaudeToGo uses a modern web architecture with the following components:

- **Backend**: Supabase (PostgreSQL + Real-time + Auth)
- **Frontend**: Progressive Web App (PWA) deployed on Netlify  
- **Integration**: Claude Code hooks system with curl commands
- **Authentication**: Supabase Auth with JWT tokens

The system flow:
```
Linux Laptop (Claude Code) → Supabase API → PWA (Netlify) → Mobile Device Notifications
```

## Key Features (Planned)

- Real-time notification delivery to mobile devices
- Secure authentication and data transmission
- Integration with Claude Code hooks system
- Support for task completion and input-required events
- Message filtering to prevent sensitive data exposure
- Offline PWA functionality

## Development Status

ClaudeToGo is fully implemented and ready for deployment. The repository contains:
- Complete PWA template with React and Supabase integration
- Automated setup scripts for Linux systems
- Comprehensive documentation and troubleshooting guides
- Production-ready deployment automation

## Security Considerations

### 🔒 Security Note
ClaudeToGo uses standard developer practices for credential management. Your security depends on your laptop security:

- Keep your laptop encrypted and locked when away
- Use secure login (strong password, 2FA where possible)
- Keep your system updated

**Context**: If someone has access to your laptop, they already have access to all your development tools, credentials, and logged-in services anyway.

### Implementation Security
- All API communications over HTTPS with authentication
- Environment variables with CTG_ prefix to avoid conflicts
- Message content filtering to prevent sensitive data exposure
- Row-level security (RLS) in Supabase
- Input sanitization for notification content

## Environment Variables

ClaudeToGo uses CTG_ prefixed environment variables (standard developer practice):
- `CTG_SUPABASE_URL` - Supabase project URL
- `CTG_SUPABASE_SERVICE_KEY` - Supabase service role key
- `CTG_NOTIFICATIONS_URL` - PWA URL on Netlify
- `CTG_USER_ID` - User ID from PWA authentication

**Note**: These are stored in your shell config like any other development credentials. The CTG_ prefix prevents conflicts with existing environment variables.

## Known Breaking Issues & Solutions

### 1. Missing PWA Assets (HIGH IMPACT)
- **Issue**: PWA icons missing - deployment will fail
- **Solution**: Create placeholder icons or generate during setup

### 2. Node.js Version Conflicts (MEDIUM IMPACT)
- **Issue**: Forces Node.js 20 LTS installation
- **Solution**: Check existing Node version first, consider using nvm instead

### 3. Directory Overwrite Risk (HIGH IMPACT)
- **Issue**: Scripts may overwrite existing projects
- **Solution**: Always run in isolated directories, backup important files

### 4. Git Repository Safety (HIGH IMPACT)
- **Issue**: Deploy script can corrupt existing repositories
- **Solution**: Verify git status before running deploy scripts

### 5. Hook Notification Frequency (LOW IMPACT)
- **Issue**: Hooks trigger on ALL Claude Code operations
- **Solution**: Configure selective matchers for production use

### Best Practices
1. **Test in isolation**: Use a separate directory for initial setup
2. **Backup important files**: Especially if testing in existing projects
3. **Check dependencies**: Verify Node.js compatibility first
4. **Manual deployment**: Consider manual steps for better control