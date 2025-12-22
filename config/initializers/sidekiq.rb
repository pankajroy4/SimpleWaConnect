redis_config = if Rails.env.development? || Rails.env.test?
    {
      url: "redis://127.0.0.1:6379/0",
    }
  else
    {
      url: "redis://127.0.0.1:6379/7",
      password: Rails.application.credentials.redis_pwd,
    }
  end

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end