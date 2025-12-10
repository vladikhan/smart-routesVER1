// Notification System
class NotificationManager {
	constructor() {
		this.badge = document.getElementById('notificationBadge')
		this.bell = document.getElementById('notificationBell')
		this.panel = document.getElementById('notificationsPanel')
		this.updateInterval = 30000

		this.init()
	}

	init() {
		//Start polling for notifications
		this.startPolling()

		//Setup event listeners
		this.setupEventListeners()
	}

	startPolling() {
		//initial fetch
		this.fetchUnreadCount()

		//Poll every 30 seconds
		setInterval(() => {
			this.fetchUnreadCount()
		}, this.updateInterval)
	}

	async fetchUnreadCount() {
		try {
			const response = await response.json()
			this.updateBadge(data.count)
		} catch (error) {
			console.error('Error fetching notification count:', error)
		}
	}

	updateBadge(count) {
		if (count > 0) {
			if (this.badge) {
				//Update existing badge
				this.badge.textContent = count
				this.animateBadge()
			} else {
				//Create new badge
				this.createBadge(count)
			}
		} else {
			//remove badge if count is 0
			if (this.badge) {
				this.badge.remove()
				this.badge = null
			}
		}
	}

	createBadge(count) {
		const badge = document.createElement('span')
		badge.className = 'notification-badge'
		badge.id = 'notificationBadge'
		badge.textContent = count

		if (this.bell) {
			this.bell.appendChild(badge)
			this.badge = badge
			this.animateBadge()
		}
	}

	animateBadge() {
		if (this.badge) {
			this.badge.style.animation = 'none'
			setTimeout(() => {
				this.badge.style.animation = 'badgePulse 2s infinite'
			}, 10)
		}
	}

	setupEventListeners() {
		//Mark all as read button
		const markAllBtn = document.querySelector('.mark-all-read')
		if (markAllBtn) {
			markAllBtn.addEventListener('click', e => {
				e.preventDefault()
				this.markAllAsRead()
			})
		}
	}

	async markAllAsRead() {
		try {
			const response = await fetch('/notifications/mark_all_as_read', {
				method: 'PATCH',
				headers: {
					'Content-Type': 'application/json',
					Accept: 'application/json',
					'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')
						.content,
					'X-Requested-With': 'XMLHttpRequest',
				},
			})

			if (!response.ok) throw new Error('Failed to mark as read')

			const data = await response.json()

			// Update UI
			this.updateBadge(0)

			// Remove unread styling from notification items
			document.querySelectorAll('.notification-item.unread').forEach(item => {
				item.classList.remove('unread')
				const dot = item.querySelector('.unread-dot')
				if (dot) dot.remove()
			})

			// Show success message
			this.showToast('すべて既読にしました')
		} catch (error) {
			console.error('Error marking notifications as read:', error)
			this.showToast('エラーが発生しました', 'error')
		}
	}

	showToast(message, type = 'success') {
		const toast = document.createElement('div')
		toast.className = `notification-toast ${type}`
		toast.textContent = message
		toast.style.cssText = `
      position: fixed;
      top: 80px;
      right: 20px;
      background: ${type === 'success' ? '#4caf50' : '#f44336'};
      color: white;
      padding: 12px 24px;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.2);
      z-index: 10000;
      animation: slideInRight 0.3s ease-out;
    `

		document.body.appendChild(toast)

		setTimeout(() => {
			toast.style.animation = 'slideOutRight 0.3s ease-out'
			setTimeout(() => toast.remove(), 300)
		}, 3000)
	}
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
	if (document.getElementById('notificationBell')) {
		window.notificationManager = new NotificationManager()
	}
})

// Toggle notifications panel
window.toggleNotifications = function (event) {
	event.stopPropagation()
	const panel = document.getElementById('notificationsPanel')
	if (panel) {
		panel.classList.toggle('show')
	}
}

// Close panel when clicking outside
document.addEventListener('click', event => {
	const dropdown = document.querySelector('.notifications-dropdown')
	const panel = document.getElementById('notificationsPanel')

	if (dropdown && panel && !dropdown.contains(event.target)) {
		panel.classList.remove('show')
	}
})

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
`
document.head.appendChild(style)
