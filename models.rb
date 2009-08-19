require 'dm-core'
require 'dm-types'
#require 'dm-constraints'
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

require 'lib/utils'
require 'lib/config'

Config.load_config(File.dirname(__FILE__) + '/config.yml')

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, Config['database'])