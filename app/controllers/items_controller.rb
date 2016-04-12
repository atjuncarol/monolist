class ItemsController < ApplicationController
  before_action :logged_in_user , except: [:show]
  before_action :set_item, only: [:show]

  def new
    if params[:q]
      response = Amazon::Ecs.item_search(params[:q] , 
                                  :search_index => 'All' , 
                                  :response_group => 'Medium' , 
                                  :country => 'jp')
        @amazon_items = response.items
      
    end
  end

  def show
     @item = Item.find(params[:id])
     # binding.pry
     
    # itemsテーブルに存在しない場合はAmazonのデータを登録する。
    if @item.new_record?
      begin
    # TODO 商品情報の取得 Amazon::Ecs.item_lookupを用いてください
        response = Amazon::Ecs.item_lookup(params[:asin], { response_group: 'Large', :country => 'jp' })
      rescue Amazon::RequestError => e
        return render :js => "alert('#{e.message}')"
      end

      amazon_item       = response.items.first
      @item.title        = amazon_item.get('ItemAttributes/Title')
      @item.small_image  = amazon_item.get("SmallImage/URL")
      @item.medium_image = amazon_item.get("MediumImage/URL")
      @item.large_image  = amazon_item.get("LargeImage/URL")
      @item.detail_page_url = amazon_item.get("DetailPageURL")
      @item.raw_info        = amazon_item.get_hash
      @item.save!
    end
  end
  
  private
  def set_item
    @item = Item.find(params[:id])
  end
end
