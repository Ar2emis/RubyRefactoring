class Account
  extend DatabaseManager
  attr_accessor :login, :password, :name, :age, :cards

  def initialize(login:, password:, name:, age:)
    @login = login
    @password = password
    @name = name
    @age = age
    @cards = []
  end

  def save
    Account.save_account(self)
    self
  end

  def self.accounts
    load_accounts
  end

  def add_card(card)
    @cards << card
    save
  end

  def destroy_card(card_to_delete)
    @cards = @cards.reject { |card| card.number == card_to_delete.number }
    save
  end

  def destroy
    Account.delete_account(self)
  end

  def withdraw(card, amount)
    card.withdraw(amount)
    save
  end

  def put(card, amount)
    card.put(amount)
    save
  end

  def send(card_from, card_to, amount)
    card_from.send(card_to, amount)
    recepient = Account.accounts.detect { |account| account.cards.map(&:number).include?(card_to.number) }
    save
    recepient.save
  end
end
