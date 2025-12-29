Rails.application.config.session_store :cookie_store,
  key: '_smartroutes_session',
  domain: :all,
  same_site: :lax,
  secure: Rails.env.production?