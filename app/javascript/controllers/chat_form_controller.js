// app/javascript/controllers/chat_form_controller.js
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
	static targets = ['input', 'submit']

	send(event) {
		event.preventDefault()

		const form = event.target
		const formData = new FormData(form)

		fetch(form.action, {
			method: 'POST',
			body: formData,
			headers: {
				'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
			},
		}).then(response => {
			if (response.ok) {
				form.reset()
				this.inputTarget.value = ''
				this.removeImage()
			}
		})
	}

	submitOnEnter(event) {
		if (event.key === 'Enter' && !event.shiftKey) {
			event.preventDefault()
			this.submitTarget.click()
		}
	}

	handleImage(event) {
		const file = event.target.files[0]
		if (file) {
			const reader = new FileReader()
			reader.onload = e => {
				const preview = document.getElementById('image-preview')
				const img = document.getElementById('preview-img')
				img.src = e.target.result
				preview.style.display = 'block'
			}
			reader.readAsDataURL(file)
		}
	}

	removeImage() {
		const preview = document.getElementById('image-preview')
		preview.style.display = 'none'
		document.querySelector('input[type="file"]').value = ''
	}
}
