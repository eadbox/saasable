module Saasable::Railties
  module Helpers
    def self.included klass
      klass.send(:include, InstanceMethods)
      klass.class_eval do
        helper_method :current_saas
      end
    end
  
    module InstanceMethods
      def current_saas
        @current_saas ||= request.env[:saasable][:current_saas]
      end
    end
  end
end