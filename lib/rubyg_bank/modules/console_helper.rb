module ConsoleHelper
  YES_COMMAND = I18n.t(:yes_command).freeze
  EXIT_COMMAND = I18n.t(:exit_command).freeze

  def put_message(message_symbol, **args)
    puts(I18n.t(message_symbol, **args))
  end

  def input
    gets.chomp
  end

  def put_errors(*errors)
    errors.each { |error| put_message(error) }
  end

  def choose_card(message_symbol, cards)
    put_message(message_symbol)
    show_indexed_cards(cards)
    put_message(:exit_message)
    input
  end

  def parse_index(card_index)
    card_index.to_i - 1
  end

  def show_indexed_cards(cards)
    cards.each_with_index do |card, index|
      put_message(:indexed_card, number: card.number, type: card.type, index: index + 1)
    end
  end
end
