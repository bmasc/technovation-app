Rails.application.configure do
   config.webpacker.check_yarn_integrity = false  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = !ENV["USE_DOTENV"].present?

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = !ENV["USE_DOTENV"].present?

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = ENV["USE_DOTENV"].present?
  config.action_controller.perform_caching = !ENV["USE_DOTENV"].present?

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.public_file_server.headers = {
    "Cache-Control" => "public, s-maxage=31536000, maxage=15552000",
    "Expires" => "#{1.year.from_now.to_formatted_s(:rfc822)}"
  }

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = Uglifier.new(harmony: true)

  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = ENV.fetch("FORCE_SSL") { "true" } === "true"

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "technovation_app_#{Rails.env}"
  config.action_mailer.delivery_job = "ActionMailer::MailDeliveryJob"
  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.action_mailer.default_url_options = { host: ENV.fetch("HOST_DOMAIN") }

  protocol = ENV.fetch("FORCE_SSL") { "true" } === "true" ? "https://" : "http://"

  config.action_mailer.asset_host = "#{protocol}#{ENV.fetch("HOST_DOMAIN")}"
  config.action_controller.asset_host = "#{protocol}#{ENV.fetch('HOST_DOMAIN')}"

  config.cache_store = :mem_cache_store, ENV.fetch("MEMCACHEDCLOUD_SERVERS").split(','), {
    username: ENV.fetch("MEMCACHEDCLOUD_USERNAME"),
    password: ENV.fetch("MEMCACHEDCLOUD_PASSWORD"),
    namespace: "Technovation",
    expires_in: 1.day,
    compress: true,
  }
end
