class AccountManager
  include ConsoleHelper

  def create_account
    loop do
      account = Account.new(name: name_input, age: age_input, login: login_input, password: password_input)
      validator = AccountValidator.new(account)
      return account.save if validator.valid?

      put_errors(validator.errors)
    end
  end

  def load_account
    loop do
      login = login_input
      password = password_input
      account = Account.accounts.detect { |acc| acc.login == login && acc.password == password }
      return account unless account.nil?

      put_errors(:invalid_credentials_message)
    end
  end

  def destroy_account(account)
    put_message(:destroy_account_message)
    return unless input == YES_COMMAND

    account.destroy
  end

  private

  def name_input
    put_message(:name_message)
    input
  end

  def age_input
    put_message(:age_message)
    input.to_i
  end

  def login_input
    put_message(:login_message)
    input
  end

  def password_input
    put_message(:password_message)
    input
  end
end
