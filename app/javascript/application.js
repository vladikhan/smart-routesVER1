window.initMap = function () {}
import '@hotwired/turbo-rails'
import './channels'
import './controllers'
import './maps'
import './notifications'
require('@rails/activestorage').start()
require('@rails/ujs').start()
require('turbolinks').start()

const application = Application.start()
application.debug = false
window.Stimulus = application

export { application }
