import consumer from './consumer'

document.addEventListener('turbo:load', () => {
	const messagesContainer = document.getElementById('messages')

	// Проверяем, что мы именно на странице чата
	if (messagesContainer) {
		const roomId = messagesContainer.dataset.roomId
		const currentUserId = document.body.dataset.userId

		// Подписываемся на канал конкретной комнаты
		consumer.subscriptions.create(
			{ channel: 'DmRoomChannel', room_id: roomId },
			{
				connected() {
					console.log(`Connected to DM Room ${roomId}`)
				},

				disconnected() {
					console.log('Disconnected from DM Room')
				},

				received(data) {
					// Если сообщение пришло от другого пользователя
					if (data.sender_id != currentUserId) {
						messagesContainer.insertAdjacentHTML('beforeend', data.message_html)

						// Плавный скролл вниз
						messagesContainer.scrollTo({
							top: messagesContainer.scrollHeight,
							behavior: 'smooth',
						})
					}
				},
			}
		)
	}
})
