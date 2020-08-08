class TransactionManager
  include ConsoleHelper

  def initialize(account)
    @account = account
  end

  def withdraw_money
    return put_message(:no_active_cards_message) if @account.cards.empty?

    index = choose_card(:withdraw_money_message, @account.cards)
    return if index == EXIT_COMMAND

    index = parse_index(index)
    card_index_valid?(index) ? withdraw_from_card(@account.cards[index]) : put_message(:wrong_number_message)
  rescue NotEnoughMoneyError => e
    put_errors(e)
  end

  def put_money
    return put_message(:no_active_cards_message) if @account.cards.empty?

    index = choose_card(:put_money_message, @account.cards)
    return if index == EXIT_COMMAND

    index = parse_index(index)
    card_index_valid?(index) ? put_money_to_card(@account.cards[index]) : put_message(:wrong_number_message)
  rescue TooSmallAmountError => e
    put_errors(e)
  end

  def send_money
    return put_message(:no_active_cards_message) if @account.cards.empty?

    index = choose_card(:send_money_message, @account.cards)
    exit if index == EXIT_COMMAND
    index = parse_index(index)

    return put_message(:wrong_number_message) unless card_index_valid?(index)

    send_money_from_card(@account.cards[index])
  end

  private

  def send_money_from_card(card)
    card_send_to = recepient_card
    return if card_send_to.nil?

    loop { break if money_sended?(card, card_send_to) }
  end

  def withdraw_from_card(card)
    amount = amount_input(:withdraw_amount_message)
    return put_message(:invalid_amount_message) unless amount.positive?

    @account.withdraw(card, amount)
    put_message(:withdrawed_money_message, amount: amount, number: card.number,
                                           balance: card.balance, tax: card.withdraw_tax(amount))
  end

  def put_money_to_card(card)
    amount = amount_input(:put_amount_message)
    return put_message(:invalid_amount_message) unless amount.positive?

    @account.put(card, amount)
    put_message(:puted_money_message, amount: amount, number: card.number,
                                      balance: card.balance, tax: card.put_tax(amount))
  end

  def money_sended?(card_from, card_to)
    amount = amount_input(:withdraw_amount_message)
    return put_message(:invalid_amount_message) unless amount.positive?

    @account.send(card_from, card_to, amount)
    put_message(:sended_money_message, amount: amount, recepient_card: card_to.number, put_tax: card_to.put_tax(amount),
                                       sender_card: card_from.number, send_tax: card_from.sender_tax(amount))
    true
  rescue NotEnoughMoneyError, TooSmallAmountError => e
    put_errors(e)
  end

  def card_index_valid?(card_index)
    card_index >= 0 && card_index < @account.cards.length
  end

  def recepient_card
    card_number = card_number_input
    return put_message(:invalid_card_number_message) unless card_number.length == BaseCard::NUMBER_LENGTH

    recepient_card = Account.accounts.map(&:cards).flatten.detect { |card| card.number == card_number }
    receipent_card.nil? ? put_message(:no_card_with_number_message, number: recepient_card_number) : recepient_card
  end

  def amount_input(message_symbol)
    put_message(message_symbol)
    input.to_i
  end

  def card_number_input
    put_message(:card_number_message)
    input
  end
end
