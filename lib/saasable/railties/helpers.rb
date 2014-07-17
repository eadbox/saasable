module Saasable::Railties
  module Helpers
    def self.included klass
      klass.extend ClassMethods
      klass.send(:include, InstanceMethods)
      klass.class_eval do
        helper_method :current_saas
        
        before_filter :_redirect_if_saas_not_found unless Rails.env.development?
        saas_not_found_redirect_to "/404.html"

        private
        def _skip_saasable
          current_saas.deactivate! if current_saas
        end
      end
    end

    module ClassMethods
      def saas_not_found_redirect_to path_or_url
        self.class_eval <<-METHOD, __FILE__, __LINE__ + 1
          private
            def _redirect_if_saas_not_found
              unless current_saas
                redirect_to "#{path_or_url}"
              end
            end
        METHOD
      end

      def skip_saasable options
        skip_before_filter :_redirect_if_saas_not_found, options
        before_filter :_skip_saasable, options
      end
    end

    module InstanceMethods
      def current_saas
        @current_saas ||= request.env[:saasable][:current_saas]
      end
    end
  end
end
