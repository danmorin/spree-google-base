module Spree
  Variant.class_eval do
    
    def google_base_id
      [product.id, id].join('-')
    end
    
    def google_base_group_id
      is_master? ? nil : ["product", product.id].join('-')
    end
    
    def google_base_name
      product.name
    end
    
    def google_base_description
      product.description_text
    end
    
    def google_base_condition
      'new'
    end
    
    def google_base_gender
      'Female'
    end
    
    def google_base_age_group
      "Adult"
    end
    
    def google_base_availability
      on_hand > 0 ? 'in stock' : 'out of stock'
    end
    
    def google_base_image
      if self.is_master?
        product.images.first
      else
        self.images.first
      end
    end
    
    def google_base_product_type
      return nil unless Spree::GoogleBase::Config[:enable_taxon_mapping]
      product_type = ''
      priority = -1000
      product.taxons.each do |taxon|
        if taxon.taxon_map && taxon.taxon_map.priority > priority
          priority = taxon.taxon_map.priority
          product_type = taxon.taxon_map.product_type
        end
      end
      product_type
    end
    
    def google_base_color
      option_value = color_option_value
      option_value.present? ? option_value.presentation : nil
    end
    
    def google_base_size
      option_value = size_option_value
      option_value.present? ? option_value.presentation : nil
    end
    
    def google_base_brand
      brand
    end
    
  end
end