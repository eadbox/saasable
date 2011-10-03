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
        @current_saas = Saasable::SaasDocument.find_by_host!(request.host)
      end

      def scope_models_by_saas
        @current_saas.activate!
      end
  end
end