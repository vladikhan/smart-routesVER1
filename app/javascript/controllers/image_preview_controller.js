import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
	// Определяем цель, куда будем вставлять превью, чтобы не искать по ID во всем документе
	static targets = ['container']

	preview(event) {
		const files = event.target.files

		// Ищем или создаем отдельный ряд для новых превью, чтобы не затирать существующие фото
		let previewRow = document.getElementById('new-images-preview-row')

		if (!previewRow) {
			previewRow = document.createElement('div')
			previewRow.id = 'new-images-preview-row'
			previewRow.className = 'row g-3 mt-2 border-top pt-3'
			// Вставляем после уже существующих фото
			document.getElementById('image-preview-container').appendChild(previewRow)
		}

		// Очищаем только НОВЫЕ превью перед повторным выбором
		previewRow.innerHTML =
			'<div class="col-12"><small class="text-primary fw-bold">選択された新しい画像:</small></div>'

		Array.from(files).forEach((file, index) => {
			if (index >= 10) return

			const reader = new FileReader()
			reader.onload = e => {
				const col = document.createElement('div')
				col.className = 'col-6 col-md-3'

				col.innerHTML = `
          <div class="position-relative shadow-sm rounded overflow-hidden">
            <img src="${e.target.result}" 
                 class="img-fluid" 
                 style="height: 120px; width: 100%; object-fit: cover; opacity: 0.9;">
            <span class="badge bg-primary position-absolute bottom-0 end-0 m-1">
              New ${index + 1}
            </span>
          </div>
        `
				previewRow.appendChild(col)
			}
			reader.readAsDataURL(file)
		})
	}
}
