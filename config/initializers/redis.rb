#Redis connection
$redis = Redis.new(
	url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
	timeout: 5
)

#Test connection

begin
	#redis.ping
	Rails.logger.info "√ Redis connected successfully"
rescue Rails::CannotConnectError => e 
	Rails.logger.error "x Redis connection failed: #{e.message}"
end