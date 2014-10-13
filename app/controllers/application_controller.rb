class ApplicationController < ActionController::Base
  before_filter :check_cookie
  protect_from_forgery with: :null_session

  def check_cookie
    @first_visit = nil
    if cookies[:user_token].nil?
      set_cookie
    else
      if User.where(:token => cookies[:user_token]).count == 0
        set_cookie
      else
        update_last_access cookies[:user_token]
      end
    end
  end

  def set_cookie
    token = SecureRandom.hex(32)
    cookies[:user_token] = { :value => token, :expires => 7.days.from_now }
    user = User.new
    user.token = token
    user.last_access = Time.now
    user.save
  end

  def update_last_access cookie
    @first_visit = false
    user = User.where(:token => cookie)
    user.first.update_attribute(:last_access, Time.now)
  end
end