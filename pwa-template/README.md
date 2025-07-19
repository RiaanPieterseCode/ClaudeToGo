# ClaudeToGo PWA

This is the Progressive Web App template for ClaudeToGo - receiving mobile notifications from Claude Code.

## Quick Setup

1. **Copy this template to your project directory**
   ```bash
   cp -r pwa-template/* your-project-directory/
   cd your-project-directory
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase credentials
   ```

4. **Run locally**
   ```bash
   npm run dev
   ```

5. **Build for production**
   ```bash
   npm run build
   ```

## Environment Variables

Create a `.env` file with:

```bash
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-public-key-here
```

## Deployment to Netlify

1. Push your code to GitHub
2. Connect your repository to Netlify
3. Set build command: `npm run build`
4. Set publish directory: `dist`
5. Add environment variables in Netlify dashboard

## Features

- ✅ Progressive Web App with offline support
- 🔔 Push notifications
- 🔐 Supabase authentication
- 📱 Mobile-first responsive design
- ⚡ Real-time updates
- 🔄 Auto-refresh capabilities

## File Structure

```
src/
├── components/
│   ├── Auth.jsx           # Authentication component
│   └── Notifications.jsx  # Notifications display
├── utils/
│   ├── supabase.js       # Supabase client setup
│   └── notifications.js  # Push notifications utils
├── App.jsx               # Main app component
├── main.jsx             # React entry point
└── index.css            # Styles
```

## Customization

- Edit `src/App.jsx` to modify the main interface
- Modify `src/index.css` to change styling
- Update `public/manifest.json` for PWA settings
- Replace icons in `public/` folder

## Testing

Test notifications locally:
1. Open the PWA in your browser
2. Allow notifications when prompted
3. Click "Test Notifications" button
4. Check that notifications appear

## Troubleshooting

- Ensure HTTPS is enabled (Netlify provides this automatically)
- Check browser console for errors
- Verify Supabase credentials are correct
- Test on multiple devices/browsers