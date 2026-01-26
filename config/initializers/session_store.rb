Rails.application.config.session_store :cache_store,
                                       key: '_smartroutes_session',
                                       domain: :all,
                                       expire_after: 14.days
