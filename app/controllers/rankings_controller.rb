class RankingsController < ApplicationController
     def want
        @rankings = Want.group(:item_id).order('count_id desc').limit(10).count(:id) 
        @rankings.transform_keys!{ |key| Item.find(key) }
     end

    def have
        @rankings = Have.group(:item_id).order('count_id desc').limit(10).count(:id) 
        @rankings.transform_keys!{ |key| Item.find(key) }
    end
end
