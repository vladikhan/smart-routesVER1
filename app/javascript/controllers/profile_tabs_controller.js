import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
	static targets = ['btn', 'content']

	switch(event) {
		const targetId = event.currentTarget.dataset.tab

		// 1. Управляем кнопками
		this.btnTargets.forEach(btn => {
			btn.classList.toggle('active', btn === event.currentTarget)
		})

		// 2. Управляем контентом
		this.contentTargets.forEach(content => {
			const isTarget = content.id === `${targetId}-tab`
			content.classList.toggle('active', isTarget)
			content.style.display = isTarget ? 'block' : 'none'
		})

		console.log(`Switched to tab: ${targetId}`)
	}
}
