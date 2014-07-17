class Saasable::Middleware
  def initialize app
    @app = app

    # Loads all models so we know how to apply the scopes on Rails
    Rails::Mongoid.load_models(Rails.application) if defined?(Rails::Mongoid)
  end

  def call env
    return @app.call(env) if env['PATH_INFO'].start_with?('/assets')

    env[:saasable] = {:current_saas => saas_for_host(env['SERVER_NAME'])}
    env[:saasable][:current_saas].activate! if env[:saasable][:current_saas]

    @app.call(env).tap do
      env[:saasable][:current_saas].deactivate! if env[:saasable][:current_saas]
    end
  end

  private
  def saas_for_host hostname
    Saasable::Mongoid::SaasDocument.saas_document.find_by_host!(hostname)
  rescue Saasable::Errors::SaasNotFound
    nil # Saas not found is treated by the Rails Helper
  end
end
