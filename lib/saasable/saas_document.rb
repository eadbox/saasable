module Saasable::SaasDocument
  @saas_document = nil
  
  def self.included klass
    if @saas_document and @saas_document.name != klass.name
      raise Saasable::Errors::MultipleSaasDocuments, "you can only have one Saasable::SaasDocument"
    else
      @saas_document = klass
    end
    
    klass.class_eval do
      field :hosts, :type => Array
    end
  end
  
  def self.saas_document
    @saas_document
  end
end