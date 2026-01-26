function updateBadge() {
	fetch('/notifications/unread_count')
		.then(response => response.json())
		.then(data => {
			// Ищем ВСЕ элементы, которые могут быть баджами (на мобилке и десктопе)
			const badges = document.querySelectorAll('.notification-badge')

			badges.forEach(badge => {
				if (data.count > 0) {
					badge.innerText = data.count
					badge.classList.remove('d-none') // Убираем скрытие (Bootstrap класс)
					badge.style.display = 'block' // На всякий случай
				} else {
					badge.style.display = 'none'
				}
			})
		})
}
// Запускаем проверку каждые 30 секунд
// (Слишком часто нельзя, чтобы не нагружать сервер в японской компании!)
document.addEventListener('turbo:load', () => {
	// Очистим старый интервал, чтобы они не дублировались при переходах
	if (window.notificationInterval) clearInterval(window.notificationInterval)

	// Запускаем новый
	updateNotificationBadge() // Один раз сразу при загрузке
	window.notificationInterval = setInterval(updateNotificationBadge, 30000)
})
