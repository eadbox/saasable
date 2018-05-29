# frozen_string_literal: true

module Saasable::Railties
  module Helpers
    def self.included(klass)
      klass.extend ClassMethods
      klass.send(:include, InstanceMethods)
      klass.class_eval do
        helper_method :current_saas

        before_action :_redirect_if_saas_not_found unless Rails.env.development?
        saas_not_found_redirect_to '/404.html'

        private

        def _redirect_if_saas_not_found; end

        def _skip_saasable
          current_saas&.deactivate!
        end
      end
    end

    module ClassMethods
      def saas_not_found_redirect_to(path_or_url)
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          private
            def _redirect_if_saas_not_found
              unless current_saas
                respond_to do |format|
                  format.html { redirect_to "#{path_or_url}" }
                  format.any { head :not_found }
                end
              end
            end
        METHOD
      end

      def skip_saasable(options)
        skip_before_action :_redirect_if_saas_not_found, options.merge(raise: false)
        before_action :_skip_saasable, options
      end
    end

    module InstanceMethods
      def current_saas
        Saasable::Mongoid::SaasDocument.active_saas
      end
    end
  end
end
