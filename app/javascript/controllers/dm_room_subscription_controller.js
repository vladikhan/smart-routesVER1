import { Controller } from '@hotwired/stimulus'
import { createConsumer } from '@rails/actioncable'

export default class extends Controller {
	static targets = ['messages']
	static values = { roomId: Number, currentUserId: Number }

	connect() {
		// Подписываемся на канал
		this.channel = createConsumer().subscriptions.create(
			{ channel: 'DmRoomChannel', room_id: this.roomIdValue },
			{
				received: data => this.#insertMessageAndScroll(data),
			}
		)
		console.log(`Subscribed to the DM room with the ID ${this.roomIdValue}.`)
	}

	disconnect() {
		console.log('Unsubscribed from the DM room')
		this.channel.unsubscribe()
	}

	#insertMessageAndScroll(data) {
		// Проверяем, не мы ли отправили это сообщение (чтобы не дублировать, если вставляем через AJAX)
		const isCurrentUser = this.currentUserIdValue === data.user_id

		// Вставляем HTML сообщения в список (data.html мы должны передать из бродкаста)
		this.messagesTarget.insertAdjacentHTML('beforeend', data.html)

		// Прокручиваем вниз
		this.messagesTarget.scrollTo(0, this.messagesTarget.scrollHeight)
	}
}
