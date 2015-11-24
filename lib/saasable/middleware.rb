class Saasable::Middleware
  def initialize app
    @app = app
  end

  def call env
    return @app.call(env) if env['PATH_INFO'].start_with?('/assets')

    saas = saas_for_host(env['SERVER_NAME'])
    saas.activate! if saas

    @app.call(env).tap { saas.deactivate! if saas }
  end

  private
  def saas_for_host hostname
    Saasable::Mongoid::SaasDocument.saas_document.find_by_host!(hostname)
  rescue Saasable::Errors::SaasNotFound
    nil # Saas not found is treated by the Rails Helper
  end
end
