class Api::V1::VotesController < ApplicationController
  def create
    user_token = ( params[:user] =~ /\h{32,}/ ) ? params[:user] : nil
    date = date_convert_hyphenate params[:date]

    if user_token.nil? || date.nil?
      render nothing: true, status: 400
    end

    unless date.nil?
      user_id = User.where(token: user_token).first.id
      meal_to_find = Meal.where(date: date, period: params[:period])

      unless meal_to_find.count.blank?
        meal_id = meal_to_find.first.id
        voter = Voter.where(user_id: user_id, meal_id: meal_id).first_or_initialize
        voter.save
        render nothing: true, status: 201
      else
        render nothing: true, status: 400
      end
    end
  end

  def show
    data = Array.new
    user_token = ( params[:id] =~ /\h{32,}/ ) ? params[:id] : nil
    user = User.where(:token => user_token).first
    unless user.nil?
      user_id = user.id
      voted_meals = Voter.where(user_id: user_id)
      voted_meals.each do |voted_meal|
        p voted_meal
        the_meal = Meal.where(id: voted_meal.meal_id)
        meal_date = the_meal.first.date
        meal_period = the_meal.first.period
        data << {date: meal_date, period: meal_period}
      end
      render json: data, callback: params[:callback]
    else
      render text: '404 Not Found', status: 404
    end
  end

  def destroy
    user_token = ( params[:id] =~ /\h{32,}/ ) ? params[:id] : nil
    date = date_convert_hyphenate params[:date]
    user_id = User.where(:token => user_token).first.id
    meal_to_find = Meal.where(:date => date, :period => params[:period])
    unless meal_to_find.count.blank?
      meal_id = meal_to_find.first.id
      voter = Voter.where(:user_id => user_id, :meal_id => meal_id)
      p voter
      Voter.destroy(voter)
      render nothing: true, status: 204
    else
      render nothing: true, status: 404
    end
  end

  private
  def date_convert_hyphenate (date_to_convert)
    if date_to_convert =~ /[0-9]{8}/
      str = date_to_convert[0, 4] + '-' + date_to_convert[4, 2] + '-' + date_to_convert[6, 2] + '-'
      return str
    else
      return nil
    end
  end
end
