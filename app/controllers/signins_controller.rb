class SigninsController < ApplicationController
  def new
    @signin = Account.new
  end

  def create
    @signin = Account.find_by(email: signin_params.fetch(:email))

    if !!@signin && !!@signin.authenticate(signin_params.fetch(:password))
      SignIn.(@signin, self)
    else
      @signin = Account.new
      flash[:error] = t('controllers.signins.create.error')
      render :new
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_path, success: t('controllers.signins.destroy.success')
  end

  private
  def signin_params
    params.require(:account).permit(:email, :password)
  end
end
