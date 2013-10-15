module Saasable::Mongoid::ScopedDocument
  @scoped_documents = []

  def self.included klass
    @scoped_documents << klass unless @scoped_documents.include? klass

    klass.extend ClassMethods
    klass.class_eval do
      # Fields
      field :saas_id, :type => BSON::ObjectId
      
      # Indexes
      index :saas_id
      index [[:saad_id, 1], [:_id, 1]]
    end
  end

  def self.scoped_documents
    @scoped_documents
  end

  def saas= a_saas
    self.saas_id = a_saas._id
  end

  def saas
    @saas ||= Saasable::Mongoid::SaasDocument.saas_document.find(self.saas_id)
  end

  module ClassMethods
    def validates_uniqueness_of(*args)
      attributes = _merge_attributes(args)
      attributes[:scope] ||= []
      attributes[:scope] << :saas_id unless attributes[:scope].include?(:saas_id)

      validates_with(Mongoid::Validations::UniquenessValidator, attributes)
    end
  end
end
