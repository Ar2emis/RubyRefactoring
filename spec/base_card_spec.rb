RSpec.describe BaseCard do
  subject(:card) { described_class.new(start_balance) }

  let(:start_balance) { 1000 }
  let(:amount) { 100 }

  describe '#type' do
    it 'raises NotImplementedError' do
      expect { card.type }.to raise_error(NotImplementedError)
    end
  end

  describe '.create' do
    it 'raises NotImplementedError' do
      expect { described_class.create }.to raise_error(NotImplementedError)
    end
  end

  describe '#withdraw' do
    it 'withdraws money from card' do
      card.withdraw(100)
      expect(card.balance).to eq start_balance - amount
    end
  end

  describe '#send' do
    let(:card_to) { described_class.new(start_balance) }

    it 'sends money from one card to another' do
      card.send(card_to, amount)
      expect(card.balance).to eq start_balance - amount
      expect(card_to.balance).to eq start_balance + amount
    end
  end
end
