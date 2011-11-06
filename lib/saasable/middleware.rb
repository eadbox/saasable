class Saasable::Middleware
  def initialize app
    @app = app
  end
  
  def call env
    # Loads all models so we know how to apply the scopes on Rails
    Rails::Mongoid.load_models(Rails.application) if defined?(Rails::Mongoid)
    
    env[:saasable] = {:current_saas => saas_for_host(env["SERVER_NAME"])}
    env[:saasable][:current_saas].activate!
        
    @app.call env
  end
  
  private
    def saas_for_host hostname
      Saasable::SaasDocument.saas_document.find_by_host!(hostname)
    end
end