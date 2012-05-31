module SpreeGoogleBase
  class Engine < Rails::Engine
    engine_name 'spree_google_base'

    config.autoload_paths += %W( #{config.root}/lib )

    initializer "spree.google_base.environment", :before => :load_config_initializers do |app|
      Spree::GoogleBase::Config = Spree::GoogleBaseConfiguration.new
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
    
    initializer "spree_google_base.attr_map" do |app|
      # See http://base.google.com/support/bin/answer.py?hl=en&answer=78170 for all other fields
      GOOGLE_BASE_ATTR_MAP = [
        ['g:id', 'id'],
        ['g:mpn', 'sku'],
        ['title', 'name'],
        ['description', 'google_base_description'],
        ['g:price', 'price'],
        ['g:condition', 'google_base_condition'],
        ['google_product_category', 'google_base_product_type'],
        ['g:brand', 'google_base_brand'],
        ['g:quantity','on_hand']
      ]
    end
  end
end
