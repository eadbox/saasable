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
        unless Saasable::SaasDocument.saas_document.nil?
          @current_saas = Saasable::SaasDocument.saas_document.where(:hosts => request.host).first
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