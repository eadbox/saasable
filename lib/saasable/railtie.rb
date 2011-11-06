require "saasable/railties"

class Saasable::Railtie < Rails::Railtie
  config.app_middleware.use Saasable::Middleware
  
  initializer "include helpers" do
    ActionController::Base.send :include, Saasable::Railties::Helpers
  end
end