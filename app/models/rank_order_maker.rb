# 順位を決める機能を担当
class RankOrderMaker

  # 各ユーザーを合計スコアの高い順に並び替えて順位を設定し、ブロック引数に設定された処理をユーザーごとに実行するメソッド
  def each_ranked_user
    # 変数の初期化
    # rankは順位を格納する変数で最初は1からはじめる 
    # previous_scoreはrankの変数を更新すべきかを判定するために使用 前回のスコア(previous_score)と比較する
    rank = 1
    previous_score = 0

    # 全ユーザーの中からスコアを獲得しているユーザーを選択し、合計スコアの高い順に並び替え
    users_sorted_by_score.each do |user|
      # 合計スコアが変わった場合は順位を更新
      rank += 1 if user.total_score < previous_score

      # app/models/ranks_updater.rb の create_ranksに書いた
      # Rank.create(user_id: user.id, rank: rank, score: user.total_score) を実行
      yield(user, rank)
      
      # previous_scoreを更新して、次の順位更新に備える
      previous_score = user.total_score
    end
  end

  private

  def users_sorted_by_score
    # selectで絞り込み,sort_byで降順に
    User.all
    .select { |user| user.total_score.nonzero? }
    .sort_by { |user| user.total_score * -1 }

    #total_score = Userクラスのインスタンスメソッド
  end
end

# nonzero? 自身がゼロの時 nil を返し、非ゼロの時 self を返す

# selectメソッドは条件式に一致した要素を取得するためのメソッド
# 今回の場合は0以外のuserを返している

# 配列オブジェクト.select { |変数| ブロック処理 }

# yieldを使うとメソッドを呼び出す側が任意のコードをブロック引数として渡し、メソッド内のyieldと書いたところで実行することが可能

# user.total_score
# userはuserクラスのオブジェクトのためtotal_scoreメソッドが使用できる