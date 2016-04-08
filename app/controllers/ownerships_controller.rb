class OwnershipsController < ApplicationController
  before_action :logged_in_user

  def create
    if params[:asin]
      @item = Item.find_or_initialize_by(asin: params[:asin])
    else
      @item = Item.find(params[:item_id])
    end
    
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

    if item.params[:type]== "Have"
      current_user.have(@item)
    end
  
    if item.params[:type] == "Want"
      current_user.want(@item)
    end

    # TODO ユーザにwant or haveを設定する
    # params[:type]の値にHaveボタンが押された時には「Have」,
    # Wantボタンが押された時には「Want」が設定されています。
    
    def current_user
    @current_user ||= User.find_by(id: session[:user_id])
    end
    
    
    
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
  
end
