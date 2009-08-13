require 'dm-core'
require 'dm-types'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-is-self_referential'

require 'models/utc_support'
require 'models/person'
require 'models/post_type'
require 'models/post'
require 'models/post_tag'
require 'models/tag'
require 'models/vote'

require 'config'

Config.load_config(File.dirname(__FILE__) + '/config.yml')

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, Config['database'])

DataMapper::Model.descendants.each do |model|
  model.relationships.each_value { |relationship| relationship.child_key }
end
