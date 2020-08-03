class CapitalistCard < BaseCard
  def initialize(balance)
    super(balance)
  end

  def type
    I18n.t(:capitalist)
  end

  def self.create
    CapitalistCard.new(start_balance)
  end

  def self.start_balance
    100
  end

  private

  def withdraw_percent
    4
  end

  def put_fixed
    10
  end

  def sender_percent
    10
  end
end
