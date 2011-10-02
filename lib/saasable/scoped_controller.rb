module Saasable::ScopedController
  def self.included klass
    klass.send(:include, InstanceMethods)
    klass.class_eval do
      before_filter :fetch_current_saas
      before_filter :scope_models_by_saas
      
      helper_method :current_saas
    end
  end
  
  module InstanceMethods
    def current_saas
      @current_saas
    end

    private
      def fetch_current_saas
        if Saasable::SaasDocument.saas_document.nil?
          if Rails.env.production?
            raise Saasable::Errors::NoSaasDocuments, "you need to set one Saasable::SaasDocument"
          else
            return @current_saas = nil
          end
        end
        
        possible_saas = Saasable::SaasDocument.saas_document.where(:hosts => request.host)
        if possible_saas.empty?
          raise Saasable::Errors::SaasNotFound, "no #{Saasable::SaasDocument.saas_document.name} found for the host: \"#{request.host}\""
        elsif possible_saas.count > 1
          raise Saasable::Errors::MultipleSaasFound, "more then 1 #{Saasable::SaasDocument.saas_document.name} found for the host: \"#{request.host}\""
        else
          @current_saas = possible_saas.first
        end
      end

      def scope_models_by_saas
        Saasable::ScopedDocument.scoped_documents.each do |klass|
          # Create a default scope without messing with the ones already in place.
          klass.default_scoping ||= {}
          klass.default_scoping[:where] ||= {:saas_id => nil}
          
          if @current_saas
            klass.default_scoping[:where][:saas_id] = @current_saas._id
            klass.class_eval "field :saas_id, :type => BSON::ObjectId, :default => BSON::ObjectId(\"#{@current_saas._id}\")"
          end
        end
      end
  end
end