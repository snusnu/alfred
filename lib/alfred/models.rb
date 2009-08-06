require 'dm-core'
require 'dm-types'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-is-taggable'

require 'models/person'
require 'models/post'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'mysql://localhost/alfred')