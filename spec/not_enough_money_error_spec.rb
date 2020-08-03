RSpec.describe NotEnoughMoneyError do
  subject(:error) { described_class.new }

  describe 'creation' do
    it 'is initialized with i18n message' do
      expect(error.message).to eq I18n.t(:not_enough_money_error)
    end
  end
end
