require File.expand_path('../presenter', __FILE__)

module Posts
  class Show < ::Layouts::Application
    include Posts::Helpers
  end
end
