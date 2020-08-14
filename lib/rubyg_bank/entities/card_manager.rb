class CardManager
  include ConsoleHelper

  def initialize(account)
    @account = account
  end

  def create_card
    (1..nil).each do
      put_message(:create_card_message)
      card_type = card_types[input]
      return @account.add_card(card_type.create) unless card_type.nil?

      put_message(:wrong_card_type_message)
    end
  end

  def destroy_card
    return put_message(:no_active_cards_message) if @account.cards.empty?

    (1..nil).each do
      index = choose_card(:destroy_card_message, @account.cards)
      index == EXIT_COMMAND ? break : index = parse_index(index)

      return confirm_card_destroying(@account.cards[index]) if index >= 0 && index < @account.cards.length

      put_message(:wrong_number_message)
    end
  end

  private

  def card_types
    { I18n.t(:usual) => UsualCard,
      I18n.t(:capitalist) => CapitalistCard,
      I18n.t(:virtual) => VirtualCard }
  end

  def confirm_card_destroying(card)
    put_message(:destroy_card_confirmation_message, card_number: card.number)
    @account.destroy_card(card) if input == YES_COMMAND
  end
end
