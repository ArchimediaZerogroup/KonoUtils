class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  private

  ##
  # Semplificazione in sviluppo di un possibile utente
  def current_user
    User.first || User.create(username: 'mario', surname: 'rossi',email:"example@tld.it")
  end

end
