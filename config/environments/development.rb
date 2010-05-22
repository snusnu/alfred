Alfred::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # config.middleware.use Rack::Bug,
  #   :ip_masks   => [IPAddr.new("127.0.0.1")],
  #   :secret_key => "epT5uCIchlsHCeR9dloOeAPG66PtHd9K8l0q9avitiaA/KUrY7DE52hD4yWY+8z1",
  #   :password   => "rack-bug-secret"

  # require 'rack/bug/panels/mustache_panel'
  # config.middleware.use Rack::Bug::MustachePanel

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  # config.action_mailer.raise_delivery_errors = false
end
