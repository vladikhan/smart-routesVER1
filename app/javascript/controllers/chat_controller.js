import { Controller } from '@hotwired/stimulus'
import consumer from '../channels/consumer'

export default class extends Controller {
	static values = {
		roomId: Number,
		currentUserId: Number,
	}

	connect() {
		this.scrollToBottom()
		this.subscribeToChannel()
	}

	disconnect() {
		if (this.subscription) {
			this.subscription.unsubscribe()
		}
	}

	subscribeToChannel() {
		this.subscription = consumer.subscriptions.create(
			{
				channel: 'DmRoomChannel',
				room_id: this.roomIdValue,
			},
			{
				received: data => {
					this.appendMessage(data)
				},
			}
		)
	}

	appendMessage(data) {
		const messagesContainer = document.getElementById('messages-container')
		const isOwnMessage = data.user_id === this.currentUserIdValue

		const messageHTML = `
      <div class="mb-3 d-flex ${isOwnMessage ? 'justify-content-end' : 'justify-content-start'}">
        <div style="max-width: 70%;">
          ${
						!isOwnMessage
							? `
            <div class="d-flex align-items-center mb-1">
              <img src="${data.avatar}" class="rounded-circle me-2" width="24" height="24">
              <small class="text-muted">@${data.username}</small>
            </div>
          `
							: ''
					}
          
          <div class="${isOwnMessage ? 'bg-primary text-white' : 'bg-white'} rounded-3 p-3 shadow-sm">
            <p class="mb-0" style="white-space: pre-wrap; word-break: break-word;">${data.message}</p>
            <small class="${isOwnMessage ? 'text-white-50' : 'text-muted'}">${data.created_at}</small>
          </div>
        </div>
      </div>
    `

		messagesContainer.insertAdjacentHTML('beforeend', messageHTML)
		this.scrollToBottom()
	}

	scrollToBottom() {
		const end = document.getElementById('messages-end')
		if (end) {
			end.scrollIntoView({ behavior: 'smooth' })
		}
	}
}
