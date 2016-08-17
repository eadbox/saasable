module Saasable::Errors
  class MultipleSaasDocuments < StandardError; end
  class NoSaasDocuments < StandardError; end
  class SaasNotFound < StandardError; end
end
