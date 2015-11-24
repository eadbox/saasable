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
      field :hosts, type: Array, default: []

      # Validations
      validates_uniqueness_of :hosts

      # Indexes
      index({hosts: 1})
    end

    klass.instance_variable_set("@_after_activate_chain", [])
    klass.instance_variable_set("@_after_deactivate_chain", [])
  end

  def self.saas_document
    @saas_document
  end

  def self.active_saas
    @saas_document.active_saas
  end

  module InstanceMethods
    def activate!
      Thread.current[:saasable_active_saas] = self
      self.class.instance_variable_get("@_after_activate_chain").each { |method_name| send(method_name) }
    end

    def deactivate!
      self.class.deactivate_all!
    end
  end

  module ClassMethods
    def deactivate_all!
      last_active_saas, Thread.current[:saasable_active_saas] = active_saas, nil
      @_after_deactivate_chain.each { |method_name| last_active_saas.send(method_name) }
    end

    def find_by_host! a_host
      if Saasable::Mongoid::SaasDocument.saas_document.nil?
        raise Saasable::Errors::NoSaasDocuments, "you need to set one Saasable::SaasDocument"
      end

      possible_saas = Saasable::Mongoid::SaasDocument.saas_document.where(hosts: a_host.gsub(/^www\./, '')).to_a
      if possible_saas.empty?
        raise Saasable::Errors::SaasNotFound, "no #{Saasable::Mongoid::SaasDocument.saas_document.name} found for the host: \"#{a_host}\""
      elsif possible_saas.count > 1
        raise Saasable::Errors::MultipleSaasFound, "more then 1 #{Saasable::Mongoid::SaasDocument.saas_document.name} found for the host: \"#{a_host}\""
      else
        return possible_saas.first
      end
    end

    def active_saas
      Thread.current[:saasable_active_saas]
    end

    def after_activate *method_names
      @_after_activate_chain += method_names
    end

    def after_deactivate *method_names
      @_after_deactivate_chain += method_names
    end

    def remove_after_activate *method_names
      @_after_activate_chain -= method_names
    end

    def remove_after_deactivate *method_names
      @_after_deactivate_chain -= method_names
    end
  end
end
