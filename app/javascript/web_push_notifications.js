// Web Push Notifications
class WebPushNotifications {
  constructor() {
    this.permission = Notification.permission;
    this.init();
  }

  init() {
    // Check if browser supports notifications
    if (!('Notification' in window)) {
      console.log('This browser does not support notifications');
      return;
    }

    // Add notification permission button to header
    this.addPermissionButton();

    // If already granted, we're ready
    if (this.permission === 'granted') {
      console.log('✓ Notifications permission granted');
      this.hidePermissionButton();
    }
  }

  addPermissionButton() {
    // Check if user is logged in
    const bell = document.getElementById('notificationBell');
    if (!bell) return;

    // Only show if not granted
    if (this.permission !== 'granted' && this.permission !== 'denied') {
      const button = document.createElement('button');
      button.id = 'enableNotificationsBtn';
      button.className = 'enable-notifications-btn';
      button.innerHTML = '🔔 通知を有効化';
      button.onclick = () => this.requestPermission();
      
      bell.parentElement.insertBefore(button, bell);
    }
  }

  hidePermissionButton() {
    const btn = document.getElementById('enableNotificationsBtn');
    if (btn) btn.remove();
  }

  async requestPermission() {
    try {
      const permission = await Notification.requestPermission();
      this.permission = permission;

      if (permission === 'granted') {
        this.showToast('✓ 通知が有効になりました', 'success');
        this.hidePermissionButton();
        
        // Show test notification
        this.showNotification({
          title: 'Smart Routes',
          body: '通知が正常に設定されました！',
          icon: '🎉'
        });
      } else {
        this.showToast('通知が拒否されました', 'error');
      }
    } catch (error) {
      console.error('Error requesting notification permission:', error);
    }
  }

  showNotification({ title, body, icon, data = {} }) {
    if (this.permission !== 'granted') {
      console.log('Notifications not permitted');
      return;
    }

    // Check if page is visible
    if (document.visibilityState === 'visible') {
      // User is on the page, just show in-app notification
      return;
    }

    // Show browser notification
    const notification = new Notification(title, {
      body: body,
      icon: '/favicon.ico', // Use your app icon
      badge: '/favicon.ico',
      tag: data.id || 'notification',
      requireInteraction: false,
      data: data
    });

    notification.onclick = () => {
      window.focus();
      if (data.url) {
        window.location.href = data.url;
      }
      notification.close();
    };

    // Auto close after 5 seconds
    setTimeout(() => notification.close(), 5000);
  }

  showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `notification-toast ${type}`;
    toast.textContent = message;
    toast.style.cssText = `
      position: fixed;
      top: 90px;
      right: 20px;
      background: ${type === 'success' ? '#4caf50' : type === 'error' ? '#f44336' : '#2196f3'};
      color: white;
      padding: 16px 24px;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
      z-index: 10000;
      font-weight: 600;
      animation: slideInRight 0.3s ease-out;
    `;
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
      toast.style.animation = 'slideOutRight 0.3s ease-out';
      setTimeout(() => toast.remove(), 300);
    }, 3000);
  }
}

// Initialize on page load
let webPushNotifications;
document.addEventListener('DOMContentLoaded', () => {
  webPushNotifications = new WebPushNotifications();
});

export { webPushNotifications };
