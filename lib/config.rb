require 'yaml'

module Config

  extend self

  attr_reader :config

  def [](key)
    @config[key]
  end

  def load_config(file)
    @config = YAML.load_file(file)
  end

  def write_config
    File.open('config.yml', 'w') { |f| YAML.dump(@config, f) }
  end

  def allowed?(nick)
    config['allowed'].include?(nick)
  end

  def allow!(nick)
    @config['allowed'] << nick
    write_config
  end

  def twitter_bot_login
    "#{config['twitter']['bot_login']}"
  end

  def twitter_bot_credentials
    "#{config['twitter']['bot_login']}:#{config['twitter']['bot_password']}"
  end

  def twitter_owner_login
    "#{config['twitter']['bot_login']}"
  end

  def twitter_owner_credentials
    "#{config['twitter']['owner_login']}:#{config['twitter']['owner_password']}"
  end

  def service_url
    "http://#{config['service']['host']}:#{config['service']['port']}"
  end

end
