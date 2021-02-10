class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  private

  ##
  # Semplificazione in sviluppo di un possibile utente
  # come se avessimo installato un devise.
  # Da qua pundit e kono hanno i loro metodi/helper per avere l'informazione dell'utente: pundit_user e kono_user
  def current_user
    User.first || User.create(username: 'mario', surname: 'rossi',email:"example@tld.it")
  end

end
