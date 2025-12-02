document.addEventListener('DOMContentLoaded', function () {
	const defaultLat = 35.6804 // Tokyo
	const defaultLng = 139.769

	const map = L.map('map').setView([defaultLat, defaultLng], 12)

	L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
		maxZoom: 19,
	}).addTo(map)

	// Search place using Nominatim
	window.searchLocation = async function () {
		const query = document.getElementById('search-input').value
		if (!query) return

		const url = `https://nominatim.openstreetmap.org/search?format=json&q=${query}`

		const res = await fetch(url)
		const data = await res.json()

		if (data.length > 0) {
			const lat = data[0].lat
			const lon = data[0].lon

			map.setView([lat, lon], 14)

			L.marker([lat, lon]).addTo(map).bindPopup(`<b>${query}</b>`).openPopup()
		} else {
			alert('場所が見つかりませんでした')
		}
	}
})
