// Notification Channel
const notificationChannel = consumer.subscriptions.create(
	'NotificationChannel',
	{
		connected() {
			console.log('✓ Connected to NotificationChannel')
		},

		disconnected() {
			console.log('✗ Disconnected from NotificationChannel')
		},

		received(data) {
			console.log('📬 Received notification:', data)

			// Update notification badge
			this.updateBadge(data.unread_count)

			// Add notification to dropdown
			this.addNotificationToList(data.notification)

			// Show toast notification
			this.showToast(data.notification)

			// Play notification sound (optional)
			this.playNotificationSound()
		},

		updateBadge(count) {
			const badge = document.getElementById('notificationBadge')
			const bell = document.getElementById('notificationBell')

			if (count > 0) {
				if (badge) {
					badge.textContent = count
					badge.style.animation = 'none'
					setTimeout(
						() => (badge.style.animation = 'badgePulse 2s infinite'),
						10
					)
				} else if (bell) {
					const newBadge = document.createElement('span')
					newBadge.className = 'notification-badge'
					newBadge.id = 'notificationBadge'
					newBadge.textContent = count
					bell.appendChild(newBadge)
				}
			} else {
				if (badge) badge.remove()
			}
		},

		addNotificationToList(notification) {
			const list = document.getElementById('notificationsList')
			if (!list) return

			// Check if "no notifications" message exists
			const noNotifications = list.querySelector('.no-notifications')
			if (noNotifications) {
				noNotifications.remove()
			}

			// Create notification element
			const notifElement = document.createElement('a')
			notifElement.href = 'javascript:void(0)'
			notifElement.className = 'notification-item unread'
			notifElement.onclick = e => markAsReadAndRedirect(notification.id, e)
			notifElement.dataset.notificationId = notification.id

			notifElement.innerHTML = `
      <div class="notification-icon">${notification.icon}</div>
      <div class="notification-content">
        <div class="notification-message">${notification.message}</div>
        <div class="notification-time">たった今</div>
      </div>
      <div class="unread-dot"></div>
    `

			// Insert at the top of the list
			const firstItem = list.querySelector('.notification-item')
			if (firstItem) {
				list.insertBefore(notifElement, firstItem)
			} else {
				list.appendChild(notifElement)
			}

			// Limit to 8 notifications in dropdown
			const items = list.querySelectorAll('.notification-item')
			if (items.length > 8) {
				items[items.length - 1].remove()
			}
		},

		showToast(notification) {
			const toast = document.createElement('div')
			toast.className = 'notification-toast'
			toast.innerHTML = `
      <div style="display: flex; align-items: center; gap: 12px;">
        <div style="font-size: 32px;">${notification.icon}</div>
        <div>
          <div style="font-weight: 700; margin-bottom: 4px;">${notification.message}</div>
          <div style="font-size: 12px; opacity: 0.9;">クリックして詳細を見る</div>
        </div>
      </div>
    `

			toast.style.cssText = `
      position: fixed;
      top: 90px;
      right: 20px;
      background: white;
      color: #1a1a1a;
      padding: 16px 20px;
      border-radius: 12px;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
      z-index: 10000;
      min-width: 300px;
      animation: slideInRight 0.4s cubic-bezier(0.4, 0, 0.2, 1);
      cursor: pointer;
      border-left: 4px solid #0288d1;
    `

			toast.onclick = () => {
				window.location.href = `/notifications/${notification.id}/mark_as_read`
			}

			document.body.appendChild(toast)

			setTimeout(() => {
				toast.style.animation =
					'slideOutRight 0.4s cubic-bezier(0.4, 0, 0.2, 1)'
				setTimeout(() => toast.remove(), 400)
			}, 5000)
		},

		playNotificationSound() {
			// Optional: Play notification sound
			// You can use a free sound from https://notificationsounds.com/
			try {
				const audio = new Audio(
					'data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBTGH0fPTgjMGHm7A7+OZSA0PVanp8KxdGAU+l9v0yHQpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01HkpBQ=='
				)
				audio.volume = 0.3
				audio.play().catch(() => {})
			} catch (e) {}
		},
	}
)

// Toast animations
const style = document.createElement('style')
style.textContent = `
  @keyframes slideInRight {
    from {
      transform: translateX(400px);
      opacity: 0;
    }
    to {
      transform: translateX(0);
      opacity: 1;
    }
  }

  @keyframes slideOutRight {
    from {
      transform: translateX(0);
      opacity: 1;
    }
    to {
      transform: translateX(400px);
      opacity: 0;
    }
  }

  .notification-toast {
    transition: transform 0.3s ease;
  }

  .notification-toast:hover {
    transform: scale(1.02);
    box-shadow: 0 12px 32px rgba(0, 0, 0, 0.25) !important;
  }
`
document.head.appendChild(style)

export default notificationChannel
