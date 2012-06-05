class Spree::Admin::TaxonMapController < Spree::Admin::BaseController

  def index
    @taxons = Spree::Taxon.includes(:taxon_map).order(:id).all
    @taxons.each do |taxon|
      if !taxon.taxon_map
        taxon_map = Spree::TaxonMap.new(:product_type => '', :taxon_id => taxon.id, :priority => 0)
        taxon_map.save
        taxon.taxon_map = taxon_map
      end
    end
  end

  def create
    taxon_maps = Spree::TaxonMap.all
    params[:taxon_map].each do |id, values|
      id = id.to_i
      taxon_map = taxon_maps.detect { |tm| tm.id == id }
      next unless taxon_map.present?
      taxon_map.update_attributes(values)
    end
    flash[:notice] = "Google Base taxons mapping saved successfully."
    redirect_to admin_taxon_map_index_url
  end
end
