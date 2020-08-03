class VirtualCard < BaseCard
  def initialize(balance)
    super(balance)
  end

  def type
    I18n.t(:virtual)
  end

  def self.create
    VirtualCard.new(start_balance)
  end

  def self.start_balance
    150
  end

  private

  def withdraw_percent
    88
  end

  def put_fixed
    1
  end

  def sender_fixed
    1
  end
end
