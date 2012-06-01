module Spree
  Product.class_eval do
    scope :google_base_scope, proc { active.on_hand.includes([{:variants => [:product, :images, {:option_values => :option_type}]}, :master, :taxons, :images]) }
    
    def google_base_description
      description
    end
    
    def google_base_condition
      'new'
    end

    def google_base_image_link
      images.first.attachment.url(:product)
    end

    def google_base_product_type
      return nil unless Spree::GoogleBase::Config[:enable_taxon_mapping]
      product_type = ''
      priority = -1000
      self.taxons.each do |taxon|
        if taxon.taxon_map && taxon.taxon_map.priority > priority
          priority = taxon.taxon_map.priority
          product_type = taxon.taxon_map.product_type
        end
      end
      product_type
    end
  end
end
