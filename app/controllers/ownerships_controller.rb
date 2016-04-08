class OwnershipsController < ApplicationController
  before_action :logged_in_user

  def create
    if params[:asin]
      @item = Item.find_or_initialize_by(asin: params[:asin])
    else
      @item = Item.find(params[:item_id])
    end
    
    @user = Item.find(params[:item_id])
      current_user.want(@item)
    
    @user = Item.find(params[:item_id])
      current_user.have(@item)
      

    # itemsテーブルに存在しない場合はAmazonのデータを登録する。
    if @item.new_record?
      begin
        # TODO 商品情報の取得 Amazon::Ecs.item_lookupを用いてください
        response = Amazon::Ecs.item_lookup(ARGV[0], { response_group: 'Large', :country => 'jp' })

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

    # TODO ユーザにwant or haveを設定する
    # params[:type]の値にHaveボタンが押された時には「Have」,
    # Wantボタンが押された時には「Want」が設定されています。
    
  end

  def destroy
    @item = Item.find(params[:item_id])
    
    @user = Item.find(params[:item_id]).want
    current_user.unwant(@item)
    
    @user = Item.find(params[:item_id]).have
    current_user.unhave(@item)
    
    # TODO 紐付けの解除。 
    # params[:type]の値にHave itボタンが押された時には「Have」,
    # Want itボタンが押された時には「Want」が設定されています。
  end
  
# itemをwantする。
	def want(item)
		wants.find_or_created_by(item_id: :item.id)
	end

# itemをwantしている場合true、wantしていない場合falseを返す。
	def want?(item)
		want.include?(item)	
	end

# itemのwantを解除する。
	def unwant(item)
		wants.find_by(item_id: item.id).destroy
	end

# itemをhaveする。
	def have(item)
		haves.find_or_created_by(item_id: :item.id)
	end
		
# itemをhaveしている場合true、haveしていない場合falseを返す。
	def have?(item)
		haves.include?(item)
	end

# itemのhaveを解除する。
	def unhave(item)
    haves.find_by(item_id: item.id).destroy
	end
end
