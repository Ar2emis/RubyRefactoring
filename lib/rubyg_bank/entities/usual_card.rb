class UsualCard < BaseCard
  WITHDRAW_PERCENT = 5
  PUT_PERCENT = 2
  SENDER_FIXED = 20
  START_BALANCE = 50

  def initialize(balance)
    super(balance)
  end

  def type
    I18n.t(:usual)
  end

  def self.create
    UsualCard.new(START_BALANCE)
  end

  private

  def withdraw_percent
    WITHDRAW_PERCENT
  end

  def put_percent
    PUT_PERCENT
  end

  def sender_fixed
    SENDER_FIXED
  end
end
