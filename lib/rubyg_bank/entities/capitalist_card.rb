class CapitalistCard < BaseCard
  WITHDRAW_PERCENT = 4
  PUT_FIXED = 10
  SENDER_PERCENT = 10
  START_BALANCE = 100

  def initialize(balance)
    super(balance)
  end

  def type
    I18n.t(:capitalist)
  end

  def self.create
    CapitalistCard.new(START_BALANCE)
  end

  def self.start_balance
    100
  end

  private

  def withdraw_percent
    WITHDRAW_PERCENT
  end

  def put_fixed
    PUT_FIXED
  end

  def sender_percent
    SENDER_PERCENT
  end
end
