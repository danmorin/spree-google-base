require 'net/ftp'

module SpreeGoogleBase
  class FeedBuilder
    include Spree::Core::Engine.routes.url_helpers
    
    attr_reader :store, :domain, :scope, :title, :output
    
    def self.generate_and_transfer
      builders = if defined?(Spree::Store)
        Spree::Store.map do |store|
          self.new(:store => store)
        end
      else
        [self.new]
      end
      
      builders.each do |builder|
        builder.generate_and_transfer_store
      end
    end
    
    def initialize(opts = {})
      raise "Please pass a the public address as second argument, or configure :public_path in Spree::GoogleBase::Config" unless opts[:store].present? or (opts[:path].present? or Spree::GoogleBase::Config[:public_domain])

      @store = opts[:store] if opts[:store].present?
      @scope = @store ? Spree::Product.by_store(@store).google_base_scope.scoped : Spree::Product.google_base_scope.scoped
      @title = @store ? @store.name : Spree::GoogleBase::Config[:store_name]
      
      @domain = @store ? @store.domains.match(/[\w\.]+/).to_s : opts[:path]
      @domain ||= Spree::GoogleBase::Config[:public_domain]
      
      @output = ''
    end
    
    def generate_and_transfer_store
      puts "Generating XML"
      generate_xml
      
      puts "Transfering XML"
      transfer_xml
      
      puts "Cleaning Up XML"
      cleanup_xml
    end
    
    def path
      "#{::Rails.root}/tmp/google_base_v#{@store.try(:code)}_#{Rails.env}.xml"
    end
    
    def generate_xml
      results =
"<?xml version=\"1.0\"?>
<rss version=\"2.0\" xmlns:g=\"http://base.google.com/ns/1.0\">
  #{build_xml}
</rss>"
      
      File.open(path, "w") do |io|
        io.puts(results)
      end
    end
    
    def transfer_xml
      raise "Please configure your Google Base :ftp_username and :ftp_password by configuring Spree::GoogleBase::Config" unless
        Spree::GoogleBase::Config[:ftp_username] and Spree::GoogleBase::Config[:ftp_password]
      
      ftp = Net::FTP.new('uploads.google.com')
      ftp.passive = true
      ftp.login(Spree::GoogleBase::Config[:ftp_username], Spree::GoogleBase::Config[:ftp_password])
      ftp.put(path, "google_base_#{Rails.env}.xml")
      ftp.quit
    end
    
    def cleanup_xml
      File.delete(path)
    end
    
    # def build_product(xml, product)
    #   xml.item do
    #     xml.tag!('link', product_url(product.permalink, :host => domain))
    #     if product.images.any?
    #       image_url = product.images[0].attachment.url(:large)
    #       image_url = "http://#{domain}#{image_url}" unless image_url[0..3] == 'http'
    #       xml.tag!('g:image_link', image_url)
    #     end
    #     
    #     SpreeGoogleBase::Engine::GOOGLE_BASE_ATTR_MAP.each do |k, v|
    #       next unless product.respond_to?(v)
    #       value = product.send(v)
    #       xml.tag!(k, value.to_s) if value.present?
    #     end
    #   end
    # end
    
    def build_item(xml, product)
      variants = product.variants.size > 0 ? product.variants : [product.master]
      variants.each do |variant|
        next if variant.on_hand <= 0
        xml.item do
          xml.tag!('link', product_url(product.permalink, {:host => domain}.merge(url_tracking_params)))
          SpreeGoogleBase::Engine::GOOGLE_BASE_ATTR_MAP.each do |k, v|
            next unless variant.respond_to?(v)
            value = variant.send(v)
            xml.tag!(k, value.to_s) if value.present?
          end
          build_images(xml, variant)
          build_tax(xml, variant)
          build_ship(xml, variant)
        end
      end
    end
    
    def url_tracking_params
      params = {}
      
      params[:utm_source]   = Spree::GoogleBase::Config[:campaign_source]   if Spree::GoogleBase::Config[:campaign_source].present?
      params[:utm_medium]   = Spree::GoogleBase::Config[:campaign_medium]   if Spree::GoogleBase::Config[:campaign_medium].present?
      params[:utm_term]     = Spree::GoogleBase::Config[:campaign_term]     if Spree::GoogleBase::Config[:campaign_term].present?
      params[:utm_content]  = Spree::GoogleBase::Config[:campaign_content]  if Spree::GoogleBase::Config[:campaign_content].present?
      params[:utm_campaign] = Spree::GoogleBase::Config[:campaign_name]     if Spree::GoogleBase::Config[:campaign_name].present?

      params
    end
    
    def build_images(xml, variant)
      images = variant.is_master? ? variant.product.images : variant.images
      images.each_with_index do |image, index|
        image_url = image.attachment.url(:large)
        image_url = "http://#{domain}#{image_url}" unless image_url[0..3] == 'http'
        if index == 0
          xml.tag!('g:image_link', image_url)
        else
          xml.tag!('g:additional_image_link', image_url)
        end
      end
    end
    
    # <g:tax>
    #    <g:country>US</g:country>
    #    <g:region>MA</g:region>
    #    <g:rate>5.00</g:rate>
    #    <g:tax_ship>y</g:tax_ship>
    # </g:tax>
    def build_tax(xml, variant)
      boutique = variant.product.boutique
      boutique.tax_rates.each do |tax_rate|
        next unless tax_rate.zone && tax_rate.zone.members.size > 0
        zone_member = tax_rate.zone.members.first
        next unless zone_member.zoneable_type == "Spree::State"
        state = zone_member.zoneable
        
        xml.tag!('g:tax') do
          xml.tag!('g:country', 'US')
          xml.tag!('g:region', state.abbr)
          xml.tag!('g:rate', tax_rate.amount * 100.0)
        end
      end
    end
    
    # <g:shipping>
    #    <g:country>US</g:country>
    #    <g:region>MA</g:region>
    #    <g:service>Ground</g:service>
    #    <g:price>6.49 USD</g:price>
    # </g:shipping>
    def build_ship(xml, variant)
      amount = variant.price > 100 ? "0.0 USD" : "9.21 USD"
      xml.tag!('g:shipping') do
        xml.tag!('g:country', 'US')
        xml.tag!('g:service', 'Ground')
        xml.tag!('g:price', amount)
      end
    end
    
    def build_meta(xml)
      xml.title @title
      xml.link @domain
    end
    
    def build_xml
      xml = Builder::XmlMarkup.new(:target => output, :indent => 2, :margin => 1)
      xml.channel do
        build_meta(xml)
        
        puts "Total Products: #{scope.count}"
        
        scope.find_each do |product|
          # build_product(xml, product)
          build_item(xml, product)
          print "."
        end
        
        puts "\n Done"
      end
      
      xml
    end
    
  end
end
