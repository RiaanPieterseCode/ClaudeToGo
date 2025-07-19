import React, { useState } from 'react'
import { supabase } from '../utils/supabase'

function AuthComponent() {
  const [loading, setLoading] = useState(false)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [isSignUp, setIsSignUp] = useState(false)
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')

  const handleAuth = async (e) => {
    e.preventDefault()
    setLoading(true)
    setError('')
    setMessage('')

    try {
      if (isSignUp) {
        const { error } = await supabase.auth.signUp({
          email,
          password,
        })
        if (error) throw error
        setMessage('Check your email for the confirmation link!')
      } else {
        const { error } = await supabase.auth.signInWithPassword({
          email,
          password,
        })
        if (error) throw error
      }
    } catch (error) {
      setError(error.message)
    } finally {
      setLoading(false)
    }
  }

  const handleGoogleAuth = async () => {
    setLoading(true)
    setError('')
    
    try {
      const { error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: window.location.origin
        }
      })
      if (error) throw error
    } catch (error) {
      setError(error.message)
      setLoading(false)
    }
  }

  const handleGitHubAuth = async () => {
    setLoading(true)
    setError('')
    
    try {
      const { error } = await supabase.auth.signInWithOAuth({
        provider: 'github',
        options: {
          redirectTo: window.location.origin
        }
      })
      if (error) throw error
    } catch (error) {
      setError(error.message)
      setLoading(false)
    }
  }

  return (
    <div className="card">
      <h2>{isSignUp ? 'Create Account' : 'Sign In'}</h2>
      <p style={{ marginBottom: '1.5rem', color: '#64748b' }}>
        {isSignUp 
          ? 'Create an account to receive ClaudeToGo notifications'
          : 'Sign in to manage your ClaudeToGo notifications'
        }
      </p>

      {error && (
        <div className="error-message">
          {error}
        </div>
      )}

      {message && (
        <div className="success-message">
          {message}
        </div>
      )}

      <form onSubmit={handleAuth}>
        <div className="form-group">
          <label className="form-label" htmlFor="email">
            Email
          </label>
          <input
            id="email"
            className="form-input"
            type="email"
            placeholder="your@email.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
        </div>

        <div className="form-group">
          <label className="form-label" htmlFor="password">
            Password
          </label>
          <input
            id="password"
            className="form-input"
            type="password"
            placeholder="Your password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </div>

        <button
          type="submit"
          className="btn btn-primary"
          disabled={loading}
          style={{ width: '100%', marginBottom: '1rem' }}
        >
          {loading ? (
            <>
              <span className="spinner"></span>
              {isSignUp ? 'Creating Account...' : 'Signing In...'}
            </>
          ) : (
            isSignUp ? 'Create Account' : 'Sign In'
          )}
        </button>
      </form>

      <div style={{ textAlign: 'center', margin: '1rem 0', color: '#64748b' }}>
        or
      </div>

      <div style={{ display: 'flex', gap: '0.5rem', marginBottom: '1.5rem' }}>
        <button
          type="button"
          className="btn btn-secondary"
          onClick={handleGoogleAuth}
          disabled={loading}
          style={{ flex: 1 }}
        >
          Google
        </button>
        <button
          type="button"
          className="btn btn-secondary"
          onClick={handleGitHubAuth}
          disabled={loading}
          style={{ flex: 1 }}
        >
          GitHub
        </button>
      </div>

      <div style={{ textAlign: 'center' }}>
        <button
          type="button"
          className="btn"
          onClick={() => setIsSignUp(!isSignUp)}
          style={{ background: 'none', color: '#2563eb', textDecoration: 'underline' }}
        >
          {isSignUp 
            ? 'Already have an account? Sign in'
            : "Don't have an account? Sign up"
          }
        </button>
      </div>

      <div style={{ marginTop: '2rem', padding: '1rem', backgroundColor: '#f1f5f9', borderRadius: '0.5rem' }}>
        <h3 style={{ fontSize: '1rem', marginBottom: '0.5rem' }}>Why do I need an account?</h3>
        <ul style={{ paddingLeft: '1.5rem', fontSize: '0.875rem', color: '#64748b' }}>
          <li>Secure delivery of notifications to your devices</li>
          <li>Personal notification history and preferences</li>
          <li>Multiple device support</li>
          <li>Privacy protection (only you see your notifications)</li>
        </ul>
      </div>
    </div>
  )
}

export default AuthComponent