class TooSmallAmountError < StandardError
  def initialize
    super(I18n.t(:too_small_amount_error))
  end
end
