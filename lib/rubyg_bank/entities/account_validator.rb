class AccountValidator
  attr_reader :errors

  def initialize(account)
    @account = account
    @errors = []
  end

  def valid?
    validate_name
    validate_age
    validate_login
    validate_password
    @errors.empty?
  end

  private

  def validate_name
    @errors << :invalid_name_message if @account.name.empty? || @account.name[0].upcase != @account.name[0]
  end

  def validate_age
    @errors << :invalid_age_message unless @account.age.between?(23, 90)
  end

  def validate_login
    @errors << :empty_login_message if @account.login.empty?
    @errors << :short_login_message if @account.login.length < 4
    @errors << :long_login_message if @account.login.length > 20
    @errors << :account_already_exist_message if account_exist?(@account.login)
  end

  def validate_password
    @errors << :empty_password_message if @account.password.empty?
    @errors << :short_password_message if @account.password.length < 6
    @errors << :long_password_message if @account.password.length > 30
  end

  def account_exist?(login)
    Account.accounts.map(&:login).include?(login)
  end
end
