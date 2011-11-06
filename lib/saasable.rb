module Saasable
  # Errors
  autoload :Errors, "saasable/errors"
  
  # Middleware
  autoload :Middleware, "saasable/middleware"
  
  # Documents
  autoload :SaasDocument, "saasable/saas_document"
  autoload :ScopedDocument, "saasable/scoped_document"
end

# Railtie
require "saasable/railtie" if defined?(Rails)