RSpec.describe Account do
  subject(:account) { described_class.new(login: login, password: password, name: name, age: age) }

  let(:login) { 'tarapunka' }
  let(:password) { 'shiza123' }
  let(:name) { 'Akakiy' }
  let(:age) { 82 }

  describe '.accounts' do
    it 'returns all accounts' do
      allow(described_class).to receive(:load_accounts).and_return([])
      accounts = described_class.accounts
      expect(accounts).to be_a(Array)
      expect(accounts).to be_empty
    end
  end

  context 'with transactions' do
    let(:card) { CapitalistCard.create }
    let(:amount) { 10 }

    before do
      allow(described_class).to receive(:save_account)
    end

    describe '#withdraw' do
      it 'withdraws money from card and saves' do
        expect(card).to receive(:withdraw)
        expect(account).to receive(:save)
        account.withdraw(card, amount)
      end
    end

    describe '#send' do
      let(:card_to) { UsualCard.create }
      let(:account_to) { described_class.new(login: login, password: password, name: name, age: age) }
      let(:login) { 'Shtepsel' }
      let(:password) { 'shiza123' }
      let(:name) { 'Terentiy' }
      let(:age) { 78 }

      before do
        account_to.cards = [card_to]
        allow(described_class).to receive(:accounts).and_return([account_to])
      end

      it 'sends money from one card to another' do
        expect(card).to receive(:send).with(card_to, amount)
        account.send(card, card_to, amount)
      end
    end
  end
end
