module Saasable::ScopedDocument
  @scoped_documents = []
  
  def self.included klass
    @scoped_documents << klass unless @scoped_documents.include? klass
    
    klass.class_eval do
      field :saas_id, :type => BSON::ObjectId
    end
  end
  
  def self.scoped_documents
    @scoped_documents
  end
end