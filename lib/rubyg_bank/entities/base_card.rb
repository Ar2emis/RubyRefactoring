class BaseCard
  attr_reader :number
  attr_accessor :balance

  NUMBER_LENGTH = 16

  def initialize(balance)
    @balance = balance
    @number = generate_card_number
  end

  def type
    raise NotImplementedError
  end

  def self.create
    raise NotImplementedError
  end

  def withdraw(amount)
    full_amount = amount + withdraw_tax(amount)
    raise NotEnoughMoneyError if @balance < full_amount

    @balance -= full_amount
  end

  def put(amount)
    tax = put_tax(amount)
    raise TooSmallAmountError if amount < tax

    @balance += amount - tax
  end

  def send(card, amount)
    full_amount = amount + sender_tax(amount)
    raise NotEnoughMoneyError if @balance < full_amount

    card.put(amount)
    @balance -= full_amount
  end

  def withdraw_tax(amount)
    tax(amount, withdraw_percent, withdraw_fixed)
  end

  def put_tax(amount)
    tax(amount, put_percent, put_fixed)
  end

  def sender_tax(amount)
    tax(amount, sender_percent, sender_fixed)
  end

  private

  def withdraw_percent
    0
  end

  def withdraw_fixed
    0
  end

  def put_percent
    0
  end

  def put_fixed
    0
  end

  def sender_percent
    0
  end

  def sender_fixed
    0
  end

  def generate_card_number
    Array.new(NUMBER_LENGTH) { rand(10) }.join
  end

  def tax(amount, percent, fixed)
    amount * percent / 100.0 + fixed
  end
end
