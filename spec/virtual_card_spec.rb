RSpec.describe VirtualCard do
  subject(:card) { described_class.create }

  let(:amount) { 10 }

  describe '#type' do
    it 'returns card type' do
      expect(card.type).to eq I18n.t(:virtual)
    end
  end

  describe '.create' do
    it 'returns instance with default balance' do
      new_card = described_class.create
      expect(new_card).to be_a(described_class)
      expect(new_card.balance).to eq described_class.start_balance
    end
  end

  describe '#withdraw' do
    it 'withdraws money from card with tax' do
      card.withdraw(amount)
      expect(card.balance).to eq described_class.start_balance - amount - card.withdraw_tax(amount)
    end
  end

  describe '#send' do
    let(:card_to) { described_class.create }

    it 'sends money from one card to another with tax' do
      card.send(card_to, amount)
      expect(card.balance).to eq described_class.start_balance - amount - card.sender_tax(amount)
      expect(card_to.balance).to eq described_class.start_balance + amount - card_to.sender_tax(amount)
    end
  end
end
