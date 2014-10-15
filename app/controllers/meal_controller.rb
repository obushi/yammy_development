class MealController < ApplicationController
  def daily
    if params[:date].nil?
      @meal_date = Date.today
    else
      @meal_date = ( params[:date] =~ /[0-9]{8}/ ? Date.parse(params[:date]) : Date.today )
    end
    @yesterday = @meal_date - 1
    @tomorrow = @meal_date + 1

    # dateパラメータがnil(/でアクセス)またはデータベースに存在する日付の場合
    def date_exists? date
      p date
      if Meal.where(date: date).count != 0
        return true
      else
        return false
      end
    end

    @param_date_exists = date_exists? @meal_date.to_s.delete("-") #params[:date]

    if date_exists? @meal_date.to_s.delete("-")
      meals = Hash.new
      @menu = Hash.new
      @meal_nutrition = Hash.new

      Settings.period_names_ja.each do |period_key, period_val|
        meals[period_key] = Hash.new
        if params[:date].nil?
          t = Time.now
          meals[period_key] = Meal.where(date: t.strftime("%Y-%m-%d"), :period => period_key)
        else
          input_date = Time.parse params[:date]
          meals[period_key] = Meal.where(date: input_date.strftime("%Y-%m-%d"), :period => period_key)
        end
        
        @menu[period_key] = Array.new
        DishEnergy.where(:meal_id => meals[period_key].first.id).each do |dish|
            @menu[period_key] << {"name" => dish.name, "kilo_calorie" => dish.kilo_calorie}
        end

        @meal_nutrition[period_key] = {
          energy:       meals[period_key].first.energy.to_i,
          protein:      meals[period_key].first.protein.to_i,
          fat:          meals[period_key].first.fat.to_i,
          carbohydrate: meals[period_key].first.carbohydrate.to_i,
          salt:         meals[period_key].first.salt.to_i
        }
      end

      @day_nutrition = {
        energy:       0,
        protein:      0,
        fat:          0,
        carbohydrate: 0,
        salt:         0
      }

      # 1日分の栄養を3食の栄養の総和で求める
      Settings.period_names_ja.each do |period_key, period_val|
        @day_nutrition.each do |day_key, day_val|
          @day_nutrition[day_key] += @meal_nutrition[period_key][day_key]
        end
      end
    end
  end

  def list
    all_dates = Array.new
    Meal.order('date DESC').limit(Settings.history.init_load_day * 3).each do |meal|
      all_dates << meal.date
    end
    @dates = all_dates.uniq
    @meals = Meal.order('date DESC').limit(Settings.history.init_load_day * 3)
  end

  def ranking
    if params[:n].nil?
      rank_num = Settings.ranking.default_load_num
    else
      rank_num = params[:n] =~ /[0-9]/ ? params[:n].to_i : Settings.ranking.default_load_num
    end
    meals_last_one_month = Meal.where(date: 4.month.ago..Date.today)

    # 過去一ヶ月の食事での投票数とmeal_idのペアの配列 like [count, id] ...
    meal_count_arr = getMealCountArr(meals_last_one_month)

    # [count, id]の配列だが，countについて降順でソートしたもの
    sorted_count_arr = meal_count_arr.sort.reject{|meal| meal[0] == 0}.reverse

    @ranking = Array.new
      sorted_count_arr.each do |count_and_id|
        ranking = Hash.new { |h,k| h[k] = {} }
        rank = getRank count_and_id, sorted_count_arr
        votes_count = count_and_id[0]
        meal_id = count_and_id[1]
        meal = Meal.where(id: meal_id).first
        dish_names = Array.new
        DishEnergy.where(meal_id: meal.id).each do |dish|
          dish_names << dish.name
        end
        # p dish_names

        # Main Dishは名前に「ご飯」「パン」以外でもっともカロリーが高いものとする
        unless DishEnergy.where(meal_id: meal_id).empty?
          max_energy = DishEnergy.where(meal_id: meal_id).where.not(name: ['食パン', 'ご飯', '食パン', '牛乳　']).maximum('kilo_calorie')
          max_energy_name = DishEnergy.where(meal_id: meal_id, kilo_calorie: max_energy).first.name
        end

        meal_info = Hash.new { |h,k| h[k] = {} }
        meal_info['rank']                 = rank
        meal_info['count']                = votes_count
        meal_info['date']                 = meal.date
        meal_info['period']               = transrateMealName meal.period
        meal_info['main_dish_name']       = max_energy_name

        ranking['meal_info'] = meal_info
        ranking['meal_menu'] = dish_names

        @ranking << ranking
        p @ranking
      end
  end

  # 期間の条件にマッチするMealモデルの配列を渡すと[0]に投票数を，[1]にMealオブジェクトのidを格納する
  private
  def getMealCountArr meal_models
    arr = Array.new
    meal_models.each do |meal|
      count = Voter.where(meal_id: meal.id).count
      id = meal.id
      arr << [count, id]
    end
    return arr
  end

  private
  def getRank meal, meal_arr
    return (meal_arr.select{|m| m[0] > meal[0]}.size) + 1
  end

  # 英語から日本語に変換"breakfast" => "朝"
  private
  def transrateMealName english_name
    case english_name
      when "breakfast"
        return "朝"
      when "lunch"
        return "昼"
      when "dinner"
        return "夜"
      else
        return ""
    end
  end
end
