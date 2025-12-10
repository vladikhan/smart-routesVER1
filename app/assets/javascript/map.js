// Nominatim search for Google Maps
window.searchLocation = async function () {
	const query = document.getElementById('search-input').value
	if (!query) return

	const url = `https://nominatim.openstreetmap.org/search?format=json&q=${query}`

	const res = await fetch(url)
	const data = await res.json()

	if (data.length === 0) {
		alert('場所が見つかりませんでした')
		return
	}

	const lat = parseFloat(data[0].lat)
	const lon = parseFloat(data[0].lon)

	// Center map
	window.gMap.setCenter({ lat: lat, lng: lon })
	window.gMap.setZoom(14)

	// Add marker
	new google.maps.Marker({
		position: { lat: lat, lng: lon },
		map: window.gMap,
		title: query,
	})
}
