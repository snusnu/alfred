require 'dm-core'
require 'dm-migrations'
require 'dm-types'
require 'dm-serializer'
require 'dm-constraints'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-is-remixable'
require 'dm-is-self_referential'
require 'dm-is-localizable'
require 'dm-transactions'
require 'dm-aggregates'
require 'dm-pager'

require 'json'
require 'restclient'
require 'md5'

require 'lib/utc_support'
require 'models/commit'
require 'models/conversation'
require 'models/conversation_message'
require 'models/ecosystem'
require 'models/ecosystem_member'
require 'models/ecosystem_project'
require 'models/ecosystem_role'
require 'models/involvement'
require 'models/involvement_kind'
require 'models/irc_channel'
require 'models/language'
require 'models/person'
require 'models/post'
require 'models/post_tag'
require 'models/post_type'
require 'models/project'
require 'models/project_category'
require 'models/project_channel'
require 'models/project_tag'
require 'models/role'
require 'models/tag'
require 'models/user'
require 'models/vote'

require 'lib/utils'
require 'lib/config'
require 'lib/github'

Config.load_config(File.dirname(__FILE__) + '/config.yml')

DataMapper.setup(:default, Config['database'])

DataMapper::Model.descendants.each do |model|
  model.relationships.each_value { |r| r.child_key }
end
