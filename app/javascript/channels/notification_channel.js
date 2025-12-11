import consumer from './consumer'

const notificationChannel = consumer.subscriptions.create(
	'NotificationChannel',
	{
		connected() {
			console.log('🔔 Connected to NotificationChannel')
			this.updateBadgeFromServer()
		},

		disconnected() {
			console.log('🔴 Disconnected from NotificationChannel')
		},

		received(data) {
			console.log('📬 Received notification:', data)

			const notification = data.notification

			// Update badge count
			this.updateBadge(data.unread_count)

			// Add notification to dropdown list
			this.addNotificationToList(notification)

			// Show in-app toast
			this.showToast(notification)

			// Play sound
			this.playNotificationSound()

			// Show browser notification if tab not visible
			if (document.visibilityState !== 'visible') {
				this.showBrowserNotification(notification)
			}
		},

		updateBadgeFromServer() {
			fetch('/notifications/unread_count', {
				headers: { Accept: 'application/json' },
			})
				.then(response => response.json())
				.then(data => this.updateBadge(data.count))
				.catch(error => console.error('Error fetching unread count:', error))
		},

		updateBadge(count) {
			const badge = document.getElementById('notificationBadge')
			const bell = document.getElementById('notificationBell')

			if (count > 0) {
				if (badge) {
					badge.textContent = count
					badge.classList.add('pulse')
					setTimeout(() => badge.classList.remove('pulse'), 1000)
				} else if (bell) {
					const newBadge = document.createElement('span')
					newBadge.className = 'notification-badge pulse'
					newBadge.id = 'notificationBadge'
					newBadge.textContent = count
					bell.appendChild(newBadge)
				}
			} else {
				if (badge) {
					badge.classList.add('fade-out')
					setTimeout(() => badge.remove(), 300)
				}
			}
		},

		addNotificationToList(notification) {
			const list = document.getElementById('notificationsList')
			if (!list) return

			// Remove "no notifications" message
			const noNotifications = list.querySelector('.no-notifications')
			if (noNotifications) noNotifications.remove()

			// Create notification element
			const notifElement = document.createElement('div')
			notifElement.className = 'notification-item unread slide-in'
			notifElement.dataset.notificationId = notification.id
			notifElement.onclick = e =>
				this.handleNotificationClick(notification.id, e)

			const avatarHtml = notification.actor.avatar_url
				? `<img src="${notification.actor.avatar_url}" class="notification-avatar" alt="${notification.actor.username}">`
				: `<div class="notification-avatar-placeholder">${notification.actor.username[0].toUpperCase()}</div>`

			notifElement.innerHTML = `
      ${avatarHtml}
      <div class="notification-content">
        <div class="notification-message">${notification.message}</div>
        <div class="notification-time">たった今</div>
      </div>
      <div class="unread-indicator"></div>
    `

			// Insert at top
			const firstItem = list.querySelector('.notification-item')
			if (firstItem) {
				list.insertBefore(notifElement, firstItem)
			} else {
				list.appendChild(notifElement)
			}

			// Keep only latest 10 notifications
			const items = list.querySelectorAll('.notification-item')
			if (items.length > 10) {
				items[items.length - 1].remove()
			}
		},

		showToast(notification) {
			const toast = document.createElement('div')
			toast.className = 'notification-toast slide-in-right'

			const avatarHtml = notification.actor.avatar_url
				? `<img src="${notification.actor.avatar_url}" class="toast-avatar" alt="${notification.actor.username}">`
				: `<div class="toast-avatar-placeholder">${notification.actor.username[0]}</div>`

			toast.innerHTML = `
      <div class="toast-content">
        ${avatarHtml}
        <div class="toast-text">
          <div class="toast-icon">${notification.icon}</div>
          <div class="toast-message">${notification.message}</div>
          <div class="toast-hint">クリックして詳細を見る</div>
        </div>
      </div>
    `

			toast.onclick = () => {
				this.handleNotificationClick(notification.id)
				toast.remove()
			}

			document.body.appendChild(toast)

			// Auto remove after 5 seconds
			setTimeout(() => {
				toast.classList.add('slide-out-right')
				setTimeout(() => toast.remove(), 300)
			}, 5000)
		},

		showBrowserNotification(notification) {
			if (Notification.permission === 'granted') {
				const browserNotif = new Notification('Smart Routes', {
					body: notification.message,
					icon: '/favicon.ico',
					badge: '/favicon.ico',
					tag: `notification-${notification.id}`,
					requireInteraction: false,
					data: { url: notification.target_url, id: notification.id },
				})

				browserNotif.onclick = () => {
					window.focus()
					this.handleNotificationClick(notification.id)
					browserNotif.close()
				}

				setTimeout(() => browserNotif.close(), 5000)
			}
		},

		async handleNotificationClick(notificationId, event = null) {
			if (event) event.preventDefault()

			try {
				const response = await fetch(
					`/notifications/${notificationId}/mark_as_read`,
					{
						method: 'PATCH',
						headers: {
							'Content-Type': 'application/json',
							'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')
								.content,
							Accept: 'application/json',
						},
					}
				)

				const data = await response.json()

				if (data.success) {
					// Update UI
					const item = document.querySelector(
						`[data-notification-id="${notificationId}"]`
					)
					if (item) {
						item.classList.remove('unread')
						item.classList.add('read')
						const indicator = item.querySelector('.unread-indicator')
						if (indicator) indicator.remove()
					}

					// Update badge
					this.updateBadge(data.unread_count)

					// Redirect
					if (data.redirect_url) {
						setTimeout(() => (window.location.href = data.redirect_url), 200)
					}
				}
			} catch (error) {
				console.error('Error marking notification as read:', error)
			}
		},

		playNotificationSound() {
			try {
				const audio = new Audio(
					'data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBTGH0fPTgjMGHm7A7+OZSA0PVanp8KxdGAU+l9v0yHQpBSh+zPDalDwIEl+16+2nVxELRKXh88JmIAgygdL01Hk='
				)
				audio.volume = 0.2
				audio.play().catch(() => {})
			} catch (e) {}
		},
	}
)

// Global function to mark all as read
window.markAllNotificationsAsRead = async function () {
	try {
		const response = await fetch('/notifications/mark_all_as_read', {
			method: 'PATCH',
			headers: {
				'Content-Type': 'application/json',
				'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')
					.content,
				Accept: 'application/json',
			},
		})

		const data = await response.json()

		if (data.success) {
			// Remove all unread styling
			document.querySelectorAll('.notification-item.unread').forEach(item => {
				item.classList.remove('unread')
				item.classList.add('read')
				const indicator = item.querySelector('.unread-indicator')
				if (indicator) indicator.remove()
			})

			// Update badge
			notificationChannel.updateBadge(0)

			// Show success message
			showSuccessToast('すべて既読にしました')

			// Hide "mark all" button
			const markAllBtn = document.querySelector('.mark-all-read')
			if (markAllBtn) markAllBtn.style.display = 'none'
		}
	} catch (error) {
		console.error('Error:', error)
		showErrorToast('エラーが発生しました')
	}
}

function showSuccessToast(message) {
	const toast = document.createElement('div')
	toast.className = 'simple-toast success'
	toast.textContent = '✓ ' + message
	document.body.appendChild(toast)
	setTimeout(() => toast.remove(), 3000)
}

function showErrorToast(message) {
	const toast = document.createElement('div')
	toast.className = 'simple-toast error'
	toast.textContent = '✗ ' + message
	document.body.appendChild(toast)
	setTimeout(() => toast.remove(), 3000)
}

export default notificationChannel
