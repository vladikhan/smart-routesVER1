window.initMap = function () {}
import '@hotwired/turbo-rails'
import './channels'
import './controllers'
import './maps'
import './notifications'
import './notifications_poll'
require('@rails/activestorage').start()
require('@rails/ujs').start()

const application = Application.start()
application.debug = false
window.Stimulus = application

export { application }


