import React, { useState, useEffect } from 'react'
import { notificationsApi } from '../utils/supabase'
import { testNotifications, getNotificationStatus, handlePushNotification } from '../utils/notifications'

function NotificationsComponent({ userId }) {
  const [notifications, setNotifications] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [notificationStatus, setNotificationStatus] = useState({})

  useEffect(() => {
    loadNotifications()
    checkNotificationStatus()
    
    // Subscribe to real-time notifications
    const subscription = notificationsApi.subscribeToNotifications(
      userId,
      (payload) => {
        console.log('New notification received:', payload)
        const newNotification = payload.new
        setNotifications(prev => [newNotification, ...prev])
        
        // Show push notification
        handlePushNotification(newNotification)
      }
    )

    return () => {
      subscription.unsubscribe()
    }
  }, [userId])

  const loadNotifications = async () => {
    try {
      setLoading(true)
      const data = await notificationsApi.getNotifications(userId)
      setNotifications(data)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const checkNotificationStatus = () => {
    const status = getNotificationStatus()
    setNotificationStatus(status)
  }

  const handleMarkAsRead = async (notificationId) => {
    try {
      await notificationsApi.markAsRead(notificationId)
      setNotifications(prev => 
        prev.map(n => 
          n.id === notificationId ? { ...n, read: true } : n
        )
      )
    } catch (err) {
      setError(err.message)
    }
  }

  const handleMarkAllAsRead = async () => {
    try {
      await notificationsApi.markAllAsRead(userId)
      setNotifications(prev => 
        prev.map(n => ({ ...n, read: true }))
      )
    } catch (err) {
      setError(err.message)
    }
  }

  const handleTestNotification = async () => {
    try {
      // Test browser notifications
      const browserTest = await testNotifications()
      if (!browserTest) {
        setError('Browser notification test failed')
        return
      }

      // Send test notification through Supabase
      await notificationsApi.createTestNotification(userId)
    } catch (err) {
      setError(err.message)
    }
  }

  const formatTime = (timestamp) => {
    return new Date(timestamp).toLocaleString()
  }

  const getEventTypeIcon = (eventType) => {
    switch (eventType) {
      case 'completion': return '✅'
      case 'notification': return '🔔'
      case 'error': return '❌'
      case 'test': return '🧪'
      default: return '📱'
    }
  }

  const unreadCount = notifications.filter(n => !n.read).length

  return (
    <div>
      {/* Notification Status */}
      <div className="card">
        <h2>Notification Status</h2>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
          <div className={`status ${notificationStatus.supported ? 'status-success' : 'status-error'}`}>
            {notificationStatus.supported ? '✅ Push notifications supported' : '❌ Push notifications not supported'}
          </div>
          <div className={`status ${notificationStatus.permission === 'granted' ? 'status-success' : 'status-warning'}`}>
            {notificationStatus.permission === 'granted' ? '✅ Permission granted' : '⚠️ Permission needed'}
          </div>
          <div className={`status ${notificationStatus.serviceWorkerReady ? 'status-success' : 'status-warning'}`}>
            {notificationStatus.serviceWorkerReady ? '✅ Service worker ready' : '⚠️ Service worker not ready'}
          </div>
        </div>
        
        <div style={{ marginTop: '1rem', display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
          <button 
            className="btn btn-primary" 
            onClick={handleTestNotification}
          >
            🧪 Test Notifications
          </button>
          <button 
            className="btn btn-secondary" 
            onClick={checkNotificationStatus}
          >
            🔄 Refresh Status
          </button>
        </div>
      </div>

      {/* Notifications List */}
      <div className="card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
          <h2>
            Notifications
            {unreadCount > 0 && (
              <span className="status status-info" style={{ marginLeft: '0.5rem' }}>
                {unreadCount} unread
              </span>
            )}
          </h2>
          {unreadCount > 0 && (
            <button 
              className="btn btn-secondary" 
              onClick={handleMarkAllAsRead}
            >
              Mark All Read
            </button>
          )}
        </div>

        {error && (
          <div className="error-message">
            {error}
          </div>
        )}

        {loading ? (
          <div style={{ textAlign: 'center', padding: '2rem' }}>
            <div className="spinner"></div>
            Loading notifications...
          </div>
        ) : notifications.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '2rem', color: '#64748b' }}>
            <p>No notifications yet.</p>
            <p>Try running a Claude Code command to test the system!</p>
          </div>
        ) : (
          <div className="notifications-list">
            {notifications.map((notification) => (
              <div 
                key={notification.id} 
                className={`notification-item ${!notification.read ? 'unread' : ''}`}
              >
                <div className="notification-header">
                  <h3 className="notification-title">
                    {getEventTypeIcon(notification.event_type)} {notification.title}
                  </h3>
                  <span className="notification-time">
                    {formatTime(notification.created_at)}
                  </span>
                </div>
                <p className="notification-message">{notification.message}</p>
                {!notification.read && (
                  <button 
                    className="btn btn-secondary"
                    style={{ marginTop: '0.5rem', fontSize: '0.875rem', padding: '0.25rem 0.75rem' }}
                    onClick={() => handleMarkAsRead(notification.id)}
                  >
                    Mark as Read
                  </button>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

export default NotificationsComponent