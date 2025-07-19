import React, { useState, useEffect } from 'react'
import { supabase } from './utils/supabase'
import AuthComponent from './components/Auth'
import NotificationsComponent from './components/Notifications'
import { setupPushNotifications } from './utils/notifications'

function App() {
  const [session, setSession] = useState(null)
  const [loading, setLoading] = useState(true)
  const [notificationsEnabled, setNotificationsEnabled] = useState(false)

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      setLoading(false)
    })

    // Listen for auth changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session)
    })

    return () => subscription.unsubscribe()
  }, [])

  useEffect(() => {
    // Set up push notifications when user is authenticated
    if (session?.user) {
      setupPushNotifications()
        .then(() => {
          setNotificationsEnabled(true)
        })
        .catch((error) => {
          console.error('Failed to setup push notifications:', error)
        })
    }
  }, [session])

  if (loading) {
    return (
      <div className="container">
        <div className="card">
          <div style={{ textAlign: 'center', padding: '2rem' }}>
            <div className="spinner"></div>
            Loading...
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="container">
      <header className="header">
        <h1>📱 ClaudeToGo</h1>
        <p>Never miss a Claude Code task completion again</p>
      </header>

      {!session ? (
        <AuthComponent />
      ) : (
        <>
          <div className="card">
            <h2>Welcome!</h2>
            <p>You're logged in as: <strong>{session.user.email}</strong></p>
            <p>Your User ID: <code>{session.user.id}</code></p>
            
            {notificationsEnabled ? (
              <div className="status status-success" style={{ marginTop: '1rem' }}>
                ✅ Push notifications are enabled
              </div>
            ) : (
              <div className="status status-warning" style={{ marginTop: '1rem' }}>
                ⚠️ Push notifications not enabled
              </div>
            )}
            
            <div style={{ marginTop: '1rem' }}>
              <button 
                className="btn btn-secondary"
                onClick={() => supabase.auth.signOut()}
              >
                Sign Out
              </button>
            </div>
          </div>

          <div className="card">
            <h2>Setup Instructions</h2>
            <ol style={{ paddingLeft: '1.5rem' }}>
              <li>Copy your User ID above</li>
              <li>Set it as an environment variable: <code>export CLAUDE_USER_ID="{session.user.id}"</code></li>
              <li>Configure Claude Code hooks as described in the README</li>
              <li>Start a Claude Code task to test notifications</li>
            </ol>
          </div>

          <NotificationsComponent userId={session.user.id} />
        </>
      )}
    </div>
  )
}

export default App