class UserMailer < ActionMailer::Base
  default from: "ivong@themarshallproject.org"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password.subject
  #
  def reset_password(user)
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.login_token.subject
  #
  def login_token(host_with_port, user)
    @user = user
    @url = "#{host_with_port}#{process_login_token_path(user.login_token)}"
    mail(to: user.email, subject: 'Login link for Endrun')
  end
end
