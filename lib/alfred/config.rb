require 'yaml'

module Config

  extend self

  attr_reader :config

  def [](key)
    @config[key]
  end

  def load
    @config = YAML.load_file('config.yml')
  end

  def write
    File.open('config.yml', 'w') { |f| YAML.dump(@config, f) }
  end

  def allowed?(nick)
    config['allowed'].include?(nick)
  end

  def allow!(nick)
    @config['allowed'] << nick
    write
  end

  def twitter_credentials
    "#{config['twitter']['login']}:#{config['twitter']['password']}"
  end
end