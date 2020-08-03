class NotEnoughMoneyError < StandardError
  def initialize
    super(I18n.t(:not_enough_money_error))
  end
end
