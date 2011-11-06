module Saasable
  # Errors
  autoload :Errors, "saasable/errors"
  
  # Middleware
  autoload :Middleware, "saasable/middleware"
  
  # Mongoid
  autoload :Mongoid, "saasable/mongoid"
end

# Railtie
require "saasable/railtie" if defined?(Rails)