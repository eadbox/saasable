module Saasable::Mongoid::ScopedDocument
  def self.included klass
    klass.extend ClassMethods
    klass.class_eval do
      # Fields
      field :saas_id, type: BSON::ObjectId, default: -> { Saasable::Mongoid::SaasDocument.active_saas }

      # Default scope
      default_scope lambda do
        Saasable::Mongoid::SaasDocument.active_saas ? where(saas_id: Saasable::Mongoid::SaasDocument.active_saas) : all
      end

      # Indexes
      index(saas_id: 1)
      index(saad_id: 1, _id: 1)

      class << self
        alias_method_chain :index, :saasable
      end
    end
  end

  def saas= a_saas
    self.saas_id = a_saas._id
  end

  def saas
    @saas ||= Saasable::Mongoid::SaasDocument.saas_document.find(saas_id) if saas_id
  end

  module ClassMethods
    def validates_uniqueness_of(*args)
      attributes = _merge_attributes(args)
      attributes[:scope] ||= []
      attributes[:scope] << :saas_id unless attributes[:scope].include?(:saas_id)

      validates_with(Mongoid::Validatable::UniquenessValidator, attributes)
    end

    def index_with_saasable(spec, options = {})
      index_without_saasable(spec, options.merge(unique: false))
      index_without_saasable({saas_id: 1}.merge(spec), options) unless spec.include?(:saas_id)
    end
  end
end
