module DatabaseManager
  STORAGE_FILE = 'accounts.yml'.freeze

  def save_accounts(accounts)
    File.open(STORAGE_FILE, 'w') { |file| file.write(accounts.to_yaml) }
  end

  def save_account(new_account)
    accounts = load_accounts.reject { |account| account.login == new_account.login }
    save_accounts(accounts << new_account)
  end

  def delete_account(account_to_delete)
    accounts = load_accounts.reject { |account| account.login == account_to_delete.login }
    save_accounts(accounts)
  end

  def initialize_db
    save_accounts([])
    []
  end

  def load_accounts
    File.exist?(STORAGE_FILE) ? YAML.load_file(STORAGE_FILE) : initialize_db
  end
end
