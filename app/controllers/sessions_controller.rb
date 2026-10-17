class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to destination_for(user), notice: "Giriş başarılı."
    else
      flash.now[:alert] = "E-posta veya şifre hatalı."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Oturum kapatıldı.", status: :see_other
  end

  private

  def destination_for(user)
    user.manager? ? pending_approval_documents_path : approval_documents_path
  end
end
