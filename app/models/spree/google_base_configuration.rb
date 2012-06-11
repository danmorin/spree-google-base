module Spree
  class GoogleBaseConfiguration < Preferences::Configuration
    preference :title, :string, :default => ''
    preference :store_name, :string, :default => ''
    preference :public_domain, :string
    preference :description, :text, :default => ''
    preference :ftp_username, :string, :default => ''
    preference :ftp_password, :password, :default => ''
    preference :enable_taxon_mapping, :boolean, :default => false
    preference :campaign_source, :string, :default => 'google product search'
    preference :campaign_medium, :string, :default => 'organic'
    preference :campaign_term, :string, :default => ''
    preference :campaign_content, :string, :default => ''
    preference :campaign_name, :string, :default => 'google product search'
  end
end
