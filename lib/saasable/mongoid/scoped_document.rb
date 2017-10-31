# frozen_string_literal: true

module Saasable::Mongoid::ScopedDocument
  def self.included(klass)
    klass.extend ClassMethods
    klass.class_eval do
      # Fields
      field :saas_id, type: BSON::ObjectId, default: -> { Saasable::Mongoid::SaasDocument.active_saas._id }

      # Default scope
      default_scope -> { Saasable::Mongoid::SaasDocument.active_saas ? where(saas_id: Saasable::Mongoid::SaasDocument.active_saas._id) : all }

      # Indexes
      index(saas_id: 1)
      index({saas_id: 1, _id: 1}, unique: true)

      class << self
        alias_method_chain :index, :saasable
      end
    end
  end

  def saas=(a_saas)
    self.saas_id = a_saas._id
  end

  def saas
    @saas ||= Saasable::Mongoid::SaasDocument.saas_document.find(saas_id)
  end

  module ClassMethods
    def validates_uniqueness_of(*args)
      attributes = _merge_attributes(args)
      attributes[:scope] ||= []
      attributes[:scope] << :saas_id unless attributes[:scope].include?(:saas_id)

      validates_with(Mongoid::Validatable::UniquenessValidator, attributes)
    end

    def index_with_saasable(spec, options = {})
      index_without_saasable({saas_id: 1}.merge(spec), options)
    end
  end
end
