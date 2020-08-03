class UsualCard < BaseCard
  def initialize(balance)
    super(balance)
  end

  def type
    I18n.t(:usual)
  end

  def self.create
    UsualCard.new(start_balance)
  end

  def self.start_balance
    50
  end

  private

  def withdraw_percent
    5
  end

  def put_percent
    2
  end

  def sender_fixed
    20
  end
end
