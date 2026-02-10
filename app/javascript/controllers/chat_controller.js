import { Controller } from '@hotwired/stimulus'
import consumer from '../channels/consumer'
// Если решишь ставить библиотеку эмодзи:
// import { EmojiButton } from '@joeattardi/emoji-button' 

export default class extends Controller {
  static targets = ["input", "roomItem", "searchInput", "chatInput"] // Добавили таргеты
  static values = {
    roomId: Number,
    currentUserId: Number,
  }

  connect() {
    this.scrollToBottom()
    this.subscribeToChannel()
    // this.initEmojiPicker() // Раскомментируй, если поставишь библиотеку
  }

  // --- ЛОГИКА ПОИСКА ---
  search() {
    const query = this.searchInputTarget.value.toLowerCase().trim()
    
    this.roomItemTargets.forEach(item => {
      // Ищем имя внутри элемента (добавь класс .chat-name в HTML)
      const name = item.querySelector('.chat-name').textContent.toLowerCase()
      item.style.display = name.includes(query) ? "flex" : "none"
    })
  }

  // --- ЛОГИКА ЭМОДЗИ (Простой вариант) ---
  openEmoji() {
    // В большинстве систем это вызовет нативную панель (простой путь)
    // Для серьезного пикера лучше использовать библиотеку
    console.log("Нажми Win+. или Cmd+Ctrl+Space")
  }

  // --- ТВОЯ ТЕКУЩАЯ ЛОГИКА ---
  subscribeToChannel() {
    this.subscription = consumer.subscriptions.create(
      { channel: 'DmRoomChannel', room_id: this.roomIdValue },
      { received: data => this.appendMessage(data) }
    )
  }

  appendMessage(data) {
    const messagesContainer = document.getElementById('messages-container')
    const isOwnMessage = data.user_id === this.currentUserIdValue

    // Твой текущий код генерации HTML...
    messagesContainer.insertAdjacentHTML('beforeend', messageHTML)
    this.scrollToBottom()
  }

  scrollToBottom() {
    const end = document.getElementById('messages-end')
    if (end) end.scrollIntoView({ behavior: 'smooth' })
  }
}