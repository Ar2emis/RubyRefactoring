class VirtualCard < BaseCard
  WITHDRAW_PERCENT = 88
  PUT_FIXED = 1
  SENDER_FIXED = 1
  START_BALANCE = 150

  def initialize(balance)
    super(balance)
  end

  def type
    I18n.t(:virtual)
  end

  def self.create
    VirtualCard.new(START_BALANCE)
  end

  private

  def withdraw_percent
    WITHDRAW_PERCENT
  end

  def put_fixed
    PUT_FIXED
  end

  def sender_fixed
    SENDER_FIXED
  end
end
