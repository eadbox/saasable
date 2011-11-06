module Saasable::Mongoid::SaasDocument
  @saas_document = nil
  
  def self.included klass
    if @saas_document and @saas_document.name != klass.name
      raise Saasable::Errors::MultipleSaasDocuments, "you can only have one Saasable::SaasDocument"
    else
      @saas_document = klass
    end
    
    klass.extend ClassMethods
    klass.send(:include, InstanceMethods)
    klass.class_eval do
      # Fields
      field :hosts, :type => Array
      
      # Validations
      validates_uniqueness_of :hosts
    end
  end
  
  def self.saas_document
    @saas_document
  end
  
  module InstanceMethods
    def activate!
      Saasable::Mongoid::ScopedDocument.scoped_documents.each do |klass|
        # Create a default scope without messing with the ones already in place.
        klass.default_scoping ||= {}
        klass.default_scoping[:where] ||= {:saas_id => nil}
        
        klass.default_scoping[:where][:saas_id] = self._id
        klass.class_eval "field :saas_id, :type => BSON::ObjectId, :default => BSON::ObjectId(\"#{self._id}\")"
      end
    end
  end
  
  module ClassMethods
    def find_by_host! a_host
      if Saasable::Mongoid::SaasDocument.saas_document.nil?
        if Rails.env.production?
          raise Saasable::Errors::NoSaasDocuments, "you need to set one Saasable::SaasDocument"
        else
          return nil
        end
      end
      
      possible_saas = Saasable::Mongoid::SaasDocument.saas_document.where(:hosts => a_host)
      if possible_saas.empty?
        raise Saasable::Errors::SaasNotFound, "no #{Saasable::Mongoid::SaasDocument.saas_document.name} found for the host: \"#{a_host}\""
      elsif possible_saas.count > 1
        raise Saasable::Errors::MultipleSaasFound, "more then 1 #{Saasable::Mongoid::SaasDocument.saas_document.name} found for the host: \"#{a_host}\""
      else
        return possible_saas.first
      end
    end
  end
end