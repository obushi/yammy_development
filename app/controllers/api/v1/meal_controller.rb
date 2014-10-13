class Api::V1::MealController < ApplicationController
  def load
    data = Hash.new
    unless integer_string? params[:p]
      render text: '400 Bad Request', status: 400
    else
      page = params[:p].to_i
      unless page == 0
        meal_count = ( params[:d] == nil ? Settings.history.init_load_day * 3 : params[:d].to_i * 3 )
        meals = Meal.order('date DESC').offset((page - 1) * meal_count).limit(meal_count)

        unless meals.blank?
          meals.each do |meal|
            data[ meal[:date] ] = {} if data[ meal['date'] ].blank?
            dishes_arr = create_dishes_arr meal.dish_energies

            if data[ meal['date'] ]['nutrition'].blank?
              data[ meal['date'] ]['nutrition'] = {
                energy:       0,
                salt:         0,
                protein:      0,
                carbohydrate: 0,
                fat:          0
              }
            end

            data[ meal['date'] ][ meal['period']] = {
              nutrition: {
                energy:       meal['energy'],
                salt:         meal['salt'],
                protein:      meal['protein'],
                carbohydrate: meal['carbohydrate'],
                fat:          meal['fat']
              },
              menu: dishes_arr
            }

            data[ meal['date'] ][ 'nutrition' ].each do |day_key, day_val|
              data[ meal['date'] ][ meal['period']][ :nutrition ].each do |meal_key, meal_val|
                if day_key == meal_key
                  p data[ meal['date'] ][ meal['period']]
                  data[ meal['date'] ]['nutrition'][day_key] += data[ meal['date'] ][ meal['period']][:nutrition][meal_key]
                end
              end
            end

            # 栄養成分のうち、saltのみFloatなので誤差を最後に丸める。 ex. 12.9999... => 13.0
            data[ meal['date'] ][ 'nutrition' ].each do |day_key, day_val|
              if day_key.to_s == 'salt'
                data[ meal['date'] ][ 'nutrition' ][day_key] = data[ meal['date'] ][ 'nutrition' ][day_key].round(3)
              end
            end
          end
          render json: data, callback: params[:callback]
        else
          render text: '404 Not Found', status: 404
        end
      else
        render text: '400 Bad Request', status: 400
      end
    end
  end

  def search
    data = Array.new
    keyword = params[:q].empty? ? nil : params[:q]
    unless keyword.nil?

      all_results = DishEnergy.where("name like '%" + keyword + "%'").order('meal_id DESC')
      one_year_results = all_results.where(meal: Meal.where(date: 1.year.ago..Date.today))

      one_year_results.each do |result|
        data << [{
          date:         Meal.where(id: result[:meal_id]).first[:date],
          period:       Meal.where(id: result[:meal_id]).first[:period],
          name:         result.name,
          kilo_calorie: result.kilo_calorie
        }]
      end
      unless one_year_results.blank?
        render json: data, callback: params[:callback]
      else
        render text: '404 Not Found', status: 404
      end
    else
      render text: '400 Bad Request', status: 400
    end
  end



  def date
    data = Hash.new
    date = date_convert_attach params[:d]

    if !date.nil? && Meal.where(date: date).count != 0
      # dateパラメータがデータベースに存在する日付の場合か調べて格納
      meals = Meal.where(date: date)
      meals.each do |meal|

        data[ meal[:date] ] = {} if data[ meal['date'] ].blank?
        dishes_arr = create_dishes_arr meal.dish_energies

        if data[ meal['date'] ]['nutrition'].blank?
          data[ meal['date'] ]['nutrition'] = {
            energy:       0,
            salt:         0,
            protein:      0,
            carbohydrate: 0,
            fat:          0
          }
        end

        data[ meal['date'] ][ meal['period']] = {
          nutrition: {
            energy:       meal['energy'],
            salt:         meal['salt'],
            protein:      meal['protein'],
            carbohydrate: meal['carbohydrate'],
            fat:          meal['fat']
          },
          menu: dishes_arr
        }

        data[ meal['date'] ][ 'nutrition' ].each do |day_key, day_val|
          data[ meal['date'] ][ meal['period']][ :nutrition ].each do |meal_key, meal_val|
            if day_key == meal_key
              data[ meal['date'] ]['nutrition'][day_key] += data[ meal['date'] ][ meal['period']][:nutrition][meal_key]
            end
          end
        end

        # 栄養成分のうち、saltのみFloatなので誤差を最後に丸める。 ex. 12.9999... => 13.0
        data[ meal['date'] ][ 'nutrition' ].each do |day_key, day_val|
          if day_key.to_s == 'salt'
            data[ meal['date'] ][ 'nutrition' ][day_key] = data[ meal['date'] ][ 'nutrition' ][day_key].round(3)
          end
        end
      end
      render json: data, callback: params[:callback]
    else
      render text: '404 Not Found', status: 404
    end
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

    ranking = Array.new
    if rank_num > sorted_count_arr.size
      rank_num = sorted_count_arr.size
    end
    rank_num.times do |i|
      hash = Hash.new { |h,k| h[k] = {} }
      rank = getRank sorted_count_arr[i], sorted_count_arr

      voted_count = sorted_count_arr[i][0]
        meal_id = sorted_count_arr[i][1]
        meal = Meal.where(id: meal_id).first
        menu = DishEnergy.where(meal_id: meal_id)

        menu_arr = Array.new
        menu.each do |dish|
          dish_hash = Hash.new
          dish_hash['name'] = dish.name
          dish_hash['kilo_calorie'] = dish.kilo_calorie
          menu_arr << dish_hash
        end

        nutrition_hash = Hash.new
        nutrition_hash['energy']  = meal.energy
        nutrition_hash['salt']    = meal.salt
        nutrition_hash['protein'] = meal.protein
        nutrition_hash['carbohydrate'] = meal.carbohydrate
        nutrition_hash['fat'] = meal.fat
        
        meal_data = Hash.new
        meal_data['id'] = meal_id
        meal_data['date'] = meal.date
        meal_data['period'] = meal.period
        meal_data['menu'] = menu_arr
        meal_data['nutrition'] = nutrition_hash

        hash['rank'] = rank
        hash['count'] = voted_count
        hash['meal'] = meal_data
        ranking << hash
    end
    render json: ranking, callback: params[:callback]
  end


  private
  def create_dishes_arr (dishes)
    dishes_arr = []
    dishes.each do |dish|
      dishes_arr.push({
        name:         dish['name'],
        kilo_calorie: dish['kilo_calorie']
      })
    end

    return dishes_arr
  end

  private
  def date_convert_attach (date_to_convert)
    if date_to_convert =~ /[0-9]{8}/
      str = date_to_convert[0, 4] + '-' + date_to_convert[4, 2] + '-' + date_to_convert[6, 2] + '-'
      return str
    else
      return nil
    end
  end

  # 期間の条件にマッチするMealモデルの配列を渡すと[0]に投票数を，[1]にMealオブジェクトのidを格納する
  private
  def getMealCountArr (meal_models)
    arr = Array.new
    meal_models.each do |meal|
      count = Voter.where(meal_id: meal.id).count
      id = meal.id
      arr << [count, id]
    end
    return arr
  end

  private
  def integer_string? (str)
    Integer(str)
    true
  rescue ArgumentError
    false
  end

  private
  def getRank meal, meal_arr
    return (meal_arr.select{|m| m[0] > meal[0]}.size) + 1
  end

end