module Chapter5
  class RanksUpdater
    def update_all

      Rank.transaction do
        # 現在のランキング情報をリセット
        Rank.delete_all
        
        Development::UsedMemoryReport.instance.write('after Rank.delete_all')

        create_ranks
      end
    end


  # def create_ranks  リファクタリング前
  #
  #   #2 ユーザーごとにスコアの合計を計算する
  #   user_total_scores = User.all.map do |user|
  #     { user_id: user.id, total_score: user.user_scores.sum(&:score) }
  #   end

  #   #3 ユーザーごとのスコア合計の降順に並べ替え、そこからランキング情報を再作成する
  #   sorted_total_score_groups = user_total_scores.group_by { |score| score[:total_score]}
  #   .sort_by{ |score, _| score * -1 }.to_h.values

  #   #4
  #   sorted_total_score_groups.each.with_index(1) do |scores, index|
  #     scores.each do |total_score|
  #       Rank.create(user_id: total_score[:user_id], rank: index, score: total_score[:total_score])
  #     end
  #   end

  # end
  #
  
    # ユーザーごとのスコア合計を降順に並べ替え、そこからランキング情報を再作成する
    def create_ranks
      # RankOrderMaker.new.each_ranked_user do |user, rank|
      #   # ブロックのuser,rankはyeildの引数が渡される
      #   # ↓rank_order_maker.rbのyieldのところで実行される
      #   Rank.create(user_id: user.id, rank: rank, score: user.total_score)

      # ※1
      ranks = []
      RankOrderMaker.new.each_ranked_user do |user, rank|
        ranks << Rank.new(user_id: user.id, rank: rank, score: user.total_score)
      end

      Development::UsedMemoryReport.instance.write('after RankOrderMaker.new.each_ranked_user')

      Rank.import ranks

      Development::UsedMemoryReport.instance.write('after Rank.import')

    end
  end
end

# moduleを利用すると同じ名前のクラスをひとつのRailsのアプリケーションの中に複数存在させることが可能となる

# ※1
# ranksという配列を用意し、そこへRankOrderMakerから受け取ったランキング情報(userとrank)をもとにRankのインスタンスを作成しranksの配列へ格納
# activerecord-importgemによるimportメソッドを実行している。この時点でINSERTが1回実行されることになる