require 'dm-core'
require 'dm-types'
require 'dm-timestamps'
require 'dm-validations'

require 'models/person'
require 'models/post'
require 'models/post_tag'
require 'models/tag'

require 'config'

Config.load('config/service.yml')

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, Config['database'])
