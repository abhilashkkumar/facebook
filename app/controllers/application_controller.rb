class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  $users_freq = nil
end
