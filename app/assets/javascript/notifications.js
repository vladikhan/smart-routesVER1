class NotificationManager {
	constructor() {
		this.badge = document.getElementById('notificationBadge')
		this.bell = document.getElementById('notificationBell')
		this.panel = document.getElementById('notificationsPanel')
		this.updateInterval = 30000 // 30 seconds

		this.init()
	}

	init() {
		// Start polling for notifications
		this.startPolling()

		// Setup event listeners
		this.setupEventListeners()
	}

	startPolling() {
		// Initial fetch
		this.fetchUnreadCount()

		// Poll every 30 seconds
		setInterval(async () => {
			const response = await fetch('/notifications/unread_count')
			const data = await response.json()
			const badge = document.querySelector('.unread-badge-header')

			if (data.count > 0) {
				if (badge) {
					badge.innerText = data.count
				} else {
					// Если баджа нет, можно его создать или обновить иконку колокольчика
				}
			}
		}, 30000) // Проверка каждые 30 секунд
	}

	async fetchUnreadCount() {
		try {
			// ⭐ ИСПРАВЛЕНО: Добавлен fetch() и credentials: 'include'
			const response = await fetch('/notifications/unread_count', {
				method: 'GET',
				credentials: 'include', // 🔥 КРИТИЧНО! Отправляет cookies/session
				headers: {
					Accept: 'application/json',
					'Content-Type': 'application/json',
					'X-Requested-With': 'XMLHttpRequest',
				},
			})

			// Проверяем статус ответа
			if (!response.ok) {
				// Если 401 Unauthorized - пользователь не залогинен
				if (response.status === 401) {
					console.warn('⚠️ User not authenticated. Hiding notification badge.')
					this.updateBadge(0) // Скрываем badge
					return
				}
				throw new Error(`HTTP ${response.status}: ${response.statusText}`)
			}

			const data = await response.json()

			// Debug логирование (можно удалить потом)
			console.log('✅ Notifications fetched:', data)

			this.updateBadge(data.count)
		} catch (error) {
			console.error('❌ Error fetching notification count:', error)
			// Не показываем badge при ошибке
			this.updateBadge(0)
		}
	}

	updateBadge(count) {
		if (count > 0) {
			if (this.badge) {
				// Update existing badge
				this.badge.textContent = count
				this.animateBadge()
			} else {
				// Create new badge
				this.createBadge(count)
			}
		} else {
			// Remove badge if count is 0
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
		// Mark all as read button
		const markAllBtn = document.querySelector('.mark-all-read')
		if (markAllBtn) {
			markAllBtn.addEventListener('click', e => {
				e.preventDefault()
				this.markAllAsRead()
			})
		}

		// ⭐ НОВОЕ: Обработчик для индивидуальных уведомлений
		this.setupNotificationClickHandlers()
	}

	// ⭐ НОВОЕ: Обработка кликов по отдельным уведомлениям
	setupNotificationClickHandlers() {
		document
			.querySelectorAll('.notification-item[data-notification-id]')
			.forEach(item => {
				item.addEventListener('click', async e => {
					const notificationId = item.dataset.notificationId
					const redirectUrl = item.dataset.redirectUrl

					// Помечаем как прочитанное
					await this.markAsRead(notificationId)

					// Переходим по ссылке
					if (redirectUrl) {
						window.location.href = redirectUrl
					}
				})
			})
	}

	// ⭐ НОВОЕ: Пометить одно уведомление как прочитанное
	async markAsRead(notificationId) {
		try {
			const response = await fetch(
				`/notifications/${notificationId}/mark_as_read`,
				{
					method: 'PATCH',
					credentials: 'include', // 🔥 КРИТИЧНО!
					headers: {
						'Content-Type': 'application/json',
						Accept: 'application/json',
						'X-CSRF-Token': this.getCsrfToken(),
						'X-Requested-With': 'XMLHttpRequest',
					},
				},
			)

			if (!response.ok) throw new Error('Failed to mark as read')

			// Обновляем счётчик
			this.fetchUnreadCount()
		} catch (error) {
			console.error('❌ Error marking notification as read:', error)
		}
	}

	async markAllAsRead() {
		try {
			const response = await fetch('/notifications/mark_all_as_read', {
				method: 'PATCH',
				credentials: 'include', // 🔥 КРИТИЧНО! Отправляет cookies
				headers: {
					'Content-Type': 'application/json',
					Accept: 'application/json',
					'X-CSRF-Token': this.getCsrfToken(),
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
			console.error('❌ Error marking notifications as read:', error)
			this.showToast('エラーが発生しました', 'error')
		}
	}

	getCsrfToken() {
		const token = document.querySelector('meta[name="csrf-token"]')
		return token ? token.content : ''
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

	@keyframes badgePulse {
		0%, 100% {
			transform: scale(1);
		}
		50% {
			transform: scale(1.1);
		}
	}
`
document.head.appendChild(style)
