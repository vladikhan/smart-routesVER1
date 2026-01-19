import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
	static targets = ['button', 'count']
	static values = { userId: String }

	connect() {
		console.log('Follow controller connected!') // Если этого нет в консоли — контроллер не загружен
	}

	async toggle(event) {
		event.preventDefault()

		// Берем ID прямо из элемента, на котором висит контроллер
		const userId = this.userIdValue
		const isFollowing = this.buttonTarget.classList.contains('following')

		console.log(
			`Attempting to ${isFollowing ? 'unfollow' : 'follow'} user: ${userId}`
		)

		if (!userId) {
			console.error("User's ID  not found in data-follow-user-id-value!")
			return
		}

		const url = `/users/${userId}/follow`
		const method = isFollowing ? 'DELETE' : 'POST'

		try {
			const response = await fetch(url, {
				method: method,
				headers: {
					'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')
						.content,
					Accept: 'application/json',
					'Content-Type': 'application/json',
				},
			})

			if (!response.ok) throw new Error('Network response was not ok')

			const data = await response.json()
			if (data.success) {
				this.updateUI(data.following, data.followers_count)
			}
		} catch (error) {
			console.error('Error:', error)
		}
	}

	updateUI(isFollowing, count) {
		this.buttonTarget.classList.toggle('following', isFollowing)
		this.buttonTarget.classList.toggle('btn-primary', !isFollowing)
		this.buttonTarget.classList.toggle('btn-outline-secondary', isFollowing)

		this.buttonTarget.querySelector('span').textContent = isFollowing
			? 'フォロー解除'
			: 'フォローする'
		this.countTarget.textContent = count
	}
}
