// Push notifications utility functions

/**
 * Check if push notifications are supported
 */
export function isPushNotificationSupported() {
  return 'serviceWorker' in navigator && 'PushManager' in window
}

/**
 * Check current notification permission status
 */
export function getNotificationPermission() {
  if (!('Notification' in window)) {
    return 'unsupported'
  }
  return Notification.permission
}

/**
 * Request notification permission from user
 */
export async function requestNotificationPermission() {
  if (!('Notification' in window)) {
    throw new Error('Notifications are not supported')
  }

  const permission = await Notification.requestPermission()
  return permission
}

/**
 * Setup push notifications for the PWA
 */
export async function setupPushNotifications() {
  // Check if push notifications are supported
  if (!isPushNotificationSupported()) {
    throw new Error('Push notifications are not supported')
  }

  // Request permission if not already granted
  const permission = await requestNotificationPermission()
  if (permission !== 'granted') {
    throw new Error('Notification permission denied')
  }

  // Register service worker if not already registered
  let registration
  if ('serviceWorker' in navigator) {
    registration = await navigator.serviceWorker.ready
  }

  if (!registration) {
    throw new Error('Service worker not available')
  }

  console.log('Push notifications setup complete')
  return registration
}

/**
 * Show a local notification (for testing)
 */
export function showLocalNotification(title, options = {}) {
  if (getNotificationPermission() !== 'granted') {
    console.warn('Cannot show notification: permission not granted')
    return
  }

  const defaultOptions = {
    icon: '/pwa-192x192.png',
    badge: '/pwa-192x192.png',
    tag: 'claude-notification',
    renotify: true,
    ...options
  }

  return new Notification(title, defaultOptions)
}

/**
 * Handle incoming push notifications
 */
export function handlePushNotification(payload) {
  const { title, message, event_type } = payload

  // Determine notification options based on event type
  let options = {
    body: message,
    icon: '/pwa-192x192.png',
    badge: '/pwa-192x192.png',
    tag: `claude-${event_type}`,
    renotify: true,
    requireInteraction: event_type === 'notification', // Require interaction for input requests
  }

  // Customize based on event type
  switch (event_type) {
    case 'completion':
      options.icon = '/pwa-192x192.png'
      break
    case 'notification':
      options.icon = '/pwa-192x192.png'
      options.actions = [
        {
          action: 'view',
          title: 'View Terminal'
        }
      ]
      break
    case 'error':
      options.icon = '/pwa-192x192.png'
      break
  }

  return showLocalNotification(title, options)
}

/**
 * Test notification functionality
 */
export async function testNotifications() {
  try {
    await setupPushNotifications()
    
    showLocalNotification('Test Notification', {
      body: 'This is a test notification from ClaudeToGo',
      tag: 'test'
    })
    
    return true
  } catch (error) {
    console.error('Test notification failed:', error)
    return false
  }
}

/**
 * Get notification settings/status
 */
export function getNotificationStatus() {
  return {
    supported: isPushNotificationSupported(),
    permission: getNotificationPermission(),
    serviceWorkerReady: 'serviceWorker' in navigator
  }
}