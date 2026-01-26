import { Controller } from '@hotwired/turbo-rails'

export default class extends Controller {
	static targets = ['input', 'submitBtn', 'charCount']

	connect() {
		this.autoResize()
	}

	autoResize() {
		this.inputTarget.style.height = 'auto'
		this.inputTarget.style.height = this.inputTarget.scrollHeight + 'px'

		// Character count & validation
		const length = this.inputTarget.value.length
		this.charCountTarget.textContent = length
		this.submitBtnTarget.disabled = length === 0
	}

	submitOnEnter(event) {
		if (event.key === 'Enter' && !event.shiftKey) {
			event.preventDefault()
			this.element.requestSubmit()
		}
	}

	success() {
		this.inputTarget.value = ''
		this.autoResize()
	}
}
