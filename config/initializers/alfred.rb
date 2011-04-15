ENV['TZ'] = 'utc'

::ActiveSupport::Dependencies.autoload_paths << Rails.root.join("app", "models", "common")
::ActiveSupport::Dependencies.autoload_paths << Rails.root.join("app", "models", "ecosystems")
::ActiveSupport::Dependencies.autoload_paths << Rails.root.join("app", "models", "posts")
::ActiveSupport::Dependencies.autoload_paths << Rails.root.join("app", "models", "projects")

require 'lib/utils'
