module Saasable::SaasDocument
  @saas_document = nil
  
  def self.included klass
    if @saas_document and @saas_document.name != klass.name
      raise Saasable::Errors::MultipleSaasDocuments, "you can only have one Saasable::SaasDocument"
    else
      @saas_document = klass
    end
    
    klass.send(:include, InstanceMethods)
    klass.class_eval do
      field :hosts, :type => Array
    end
  end
  
  def self.saas_document
    @saas_document
  end
  
  module InstanceMethods
    def activate!
      Saasable::ScopedDocument.scoped_documents.each do |klass|
        # Create a default scope without messing with the ones already in place.
        klass.default_scoping ||= {}
        klass.default_scoping[:where] ||= {:saas_id => nil}
        
        klass.default_scoping[:where][:saas_id] = self._id
        klass.class_eval "field :saas_id, :type => BSON::ObjectId, :default => BSON::ObjectId(\"#{self._id}\")"
      end
    end
  end
end