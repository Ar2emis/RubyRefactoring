# RSpec.describe Account do
RSpec.describe Console do
  subject(:console) { described_class.new }

  let(:test_filename) { 'spec/fixtures/account.yml' }

  COMMON_PHRASES = {
    create_first_account: "There is no active accounts, do you want to be the first?[y/n]\n",
    destroy_account: "Are you sure you want to destroy account?[y/n]\n",
    if_you_want_to_delete: 'If you want to delete:',
    choose_card: 'Choose the card for putting:',
    choose_card_withdrawing: 'Choose the card for withdrawing:',
    input_amount: 'Input the amount of money you want to put on your card',
    withdraw_amount: 'Input the amount of money you want to withdraw'
  }.freeze

  HELLO_PHRASES = [
    'Hello, we are RubyG bank!',
    '- If you want to create account - press `create`',
    '- If you want to load account - press `load`',
    '- If you want to exit - press `exit`'
  ].freeze

  ASK_PHRASES = {
    name: 'Enter your name',
    login: 'Enter your login',
    password: 'Enter your password',
    age: 'Enter your age'
  }.freeze

  # rubocop:disable Layout/LineLength

  CREATE_CARD_PHRASES = [
    'You could create one of 3 card types',
    '- Usual card. 2% tax on card INCOME. 20$ tax on SENDING money from this card. 5% tax on WITHDRAWING money. For creation this card - press `usual`',
    '- Capitalist card. 10$ tax on card INCOME. 10% tax on SENDING money from this card. 4$ tax on WITHDRAWING money. For creation this card - press `capitalist`',
    '- Virtual card. 1$ tax on card INCOME. 1$ tax on SENDING money from this card. 12% tax on WITHDRAWING money. For creation this card - press `virtual`',
    '- For exit - press `exit`'
  ].freeze

  # rubocop:enable Layout/LineLength

  ACCOUNT_VALIDATION_PHRASES = {
    name: {
      first_letter: 'Your name must not be empty and starts with first upcase letter'
    },
    login: {
      present: 'Login must present',
      longer: 'Login must be longer then 4 symbols',
      shorter: 'Login must be shorter then 20 symbols',
      exists: 'Such account is already exists'
    },
    password: {
      present: 'Password must present',
      longer: 'Password must be longer then 6 symbols',
      shorter: 'Password must be shorter then 30 symbols'
    },
    age: {
      length: 'Your Age must be greeter then 23 and lower then 90'
    }
  }.freeze

  ERROR_PHRASES = {
    user_not_exists: 'There is no account with given credentials',
    wrong_command: 'Wrong command. Try again!',
    no_active_cards: "There is no active cards!\n",
    wrong_card_type: "Wrong card type. Try again!\n",
    wrong_number: "You entered wrong number!\n",
    correct_amount: 'You must input correct amount of money',
    tax_higher: 'Your tax is higher than input amount'
  }.freeze

  MAIN_OPERATIONS_TEXTS = [
    'If you want to:',
    '- show all cards - press SC',
    '- create card - press CC',
    '- destroy card - press DC',
    '- put money on card - press PM',
    '- withdraw money on card - press WM',
    '- send money to another card  - press SM',
    '- destroy account - press `DA`',
    '- exit from account - press `exit`'
  ].freeze

  CARDS = {
    usual: {
      type: 'usual',
      balance: 50.00
    },
    capitalist: {
      type: 'capitalist',
      balance: 100.00
    },
    virtual: {
      type: 'virtual',
      balance: 150.00
    }
  }.freeze

  describe '#console' do
    context 'when correct method calling' do
      before do
        allow(console).to receive(:puts)
      end

      after do
        console.console
      end

      it 'create account if input is create' do
        allow(console).to receive_message_chain(:gets, :chomp) { 'create' }
        expect(console).to receive(:create)
      end

      it 'load account if input is load' do
        allow(console).to receive_message_chain(:gets, :chomp) { 'load' }
        expect(console).to receive(:load)
      end

      it 'leave app if input is exit or some another word' do
        allow(console).to receive_message_chain(:gets, :chomp) { 'another' }
        expect(console).to receive(:exit)
      end
    end

    context 'with correct outout' do
      it 'puts authorization message' do
        allow(console).to receive_message_chain(:gets, :chomp) { 'test' }
        allow(console).to receive(:exit)
        expect(console).to receive(:puts).with(I18n.t(:authorization_message))
        console.console
      end
    end
  end

  describe '#create' do
    let(:success_name_input) { 'Denis' }
    let(:success_age_input) { '72' }
    let(:success_login_input) { 'Denis' }
    let(:success_password_input) { 'Denis1993' }
    let(:success_inputs) { [success_name_input, success_age_input, success_login_input, success_password_input] }
    let(:account_manager) { AccountManager.new }

    context 'with success result' do
      before do
        stub_const('DatabaseManager::STORAGE_FILE', test_filename)
        console.instance_variable_set(:@account_manager, account_manager)
        allow(account_manager).to receive_message_chain(:gets, :chomp).and_return(*success_inputs)
        allow(account_manager).to receive(:puts)
        allow(console).to receive(:main_menu)
        allow(Account).to receive(:accounts).and_return([])
      end

      after do
        File.delete(test_filename) if File.exist?(test_filename)
      end

      it 'with correct output' do
        ASK_PHRASES.each_value { |phrase| expect(account_manager).to receive(:puts).with(phrase) }
        ACCOUNT_VALIDATION_PHRASES.values.map(&:values).each do |phrase|
          expect(account_manager).not_to receive(:puts).with(phrase)
        end
        console.create
      end

      it 'write to file Account instance' do
        stub_const('DatabaseManager::STORAGE_FILE', test_filename)
        console.create
        expect(File.exist?(test_filename)).to be true
        accounts = YAML.load_file(test_filename)
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
        accounts.map { |account| expect(account).to be_a Account }
      end
    end

    context 'with errors' do
      before do
        all_inputs = current_inputs + success_inputs
        allow(Account).to receive(:save_account)
        console.instance_variable_set(:@account_manager, account_manager)
        allow(account_manager).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(console).to receive(:main_menu)
        allow(Account).to receive(:accounts).and_return([])
      end

      context 'with name errors' do
        context 'without small letter' do
          let(:error_input) { 'some_test_name' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:name][:first_letter] }
          let(:current_inputs) { [error_input, success_age_input, success_login_input, success_password_input] }

          it { expect { console.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with login errors' do
        let(:current_inputs) { [success_name_input, success_age_input, error_input, success_password_input] }

        context 'when present' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:present] }

          it { expect { console.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 3 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:longer] }

          it { expect { console.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 21 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:shorter] }

          it { expect { console.create }.to output(/#{error}/).to_stdout }
        end

        context 'when exists' do
          let(:error_input) { 'Denis1345' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:exists] }

          before do
            allow(Account).to receive(:accounts) { [instance_double('Account', login: error_input)] }
          end

          it { expect { console.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with age errors' do
        let(:current_inputs) { [success_name_input, error_input, success_login_input, success_password_input] }
        let(:error) { ACCOUNT_VALIDATION_PHRASES[:age][:length] }

        context 'with length minimum' do
          let(:error_input) { '22' }

          it { expect { console.create }.to output(/#{error}/).to_stdout }
        end

        context 'with length maximum' do
          let(:error_input) { '91' }

          it { expect { console.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with password errors' do
        let(:current_inputs) { [success_name_input, success_age_input, success_login_input, error_input] }

        context 'when absent' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:present] }

          it { expect { console.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 5 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:longer] }

          it { expect { console.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 31 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:shorter] }

          it { expect { console.create }.to output(/#{error}/).to_stdout }
        end
      end
    end
  end

  describe '#load' do
    context 'without active accounts' do
      it do
        expect(Account).to receive(:accounts).and_return([])
        expect(console).to receive(:create_the_first_account).and_return([])
        console.load
      end
    end

    context 'with active accounts' do
      let(:account_manager) { AccountManager.new }
      let(:login) { 'Johnny' }
      let(:password) { 'johnny1' }

      before do
        console.instance_variable_set(:@account_manager, account_manager)
        allow(account_manager).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(Account).to receive(:accounts) { [instance_double('Account', login: login, password: password)] }
      end

      context 'with correct output' do
        let(:all_inputs) { [login, password] }

        it do
          expect(console).to receive(:main_menu)
          [ASK_PHRASES[:login], ASK_PHRASES[:password]].each do |phrase|
            expect(account_manager).to receive(:puts).with(phrase)
          end
          console.load
        end
      end

      context 'when account exists' do
        let(:all_inputs) { [login, password] }

        it do
          expect(console).to receive(:main_menu)
          expect { console.load }.not_to output(/#{ERROR_PHRASES[:user_not_exists]}/).to_stdout
        end
      end

      context "when account doesn't exist" do
        let(:all_inputs) { ['test', 'test', login, password] }

        it do
          expect(console).to receive(:main_menu)
          expect { console.load }.to output(/#{ERROR_PHRASES[:user_not_exists]}/).to_stdout
        end
      end
    end
  end

  describe '#create_the_first_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }

    it 'with correct output' do
      expect(console).to receive_message_chain(:gets, :chomp) {}
      expect(console).to receive(:console)
      expect { console.create_the_first_account }.to output(COMMON_PHRASES[:create_first_account]).to_stdout
    end

    it 'calls create if user inputs is y' do
      allow(console).to receive(:puts)
      expect(console).to receive_message_chain(:gets, :chomp) { success_input }
      expect(console).to receive(:create)
      console.create_the_first_account
    end

    it 'calls console if user inputs is not y' do
      allow(console).to receive(:puts)
      expect(console).to receive_message_chain(:gets, :chomp) { cancel_input }
      expect(console).to receive(:console)
      console.create_the_first_account
    end
  end

  describe '#main_menu' do
    let(:name) { 'John' }
    let(:commands) do
      {
        'SC' => :show_cards,
        'CC' => :create_card,
        'DC' => :destroy_card,
        'PM' => :put_money,
        'WM' => :withdraw_money,
        'SM' => :send_money,
        'DA' => :destroy_account,
        'exit' => :exit
      }
    end

    context 'with correct outout' do
      it do
        allow(console).to receive(:show_cards)
        allow(console).to receive(:exit)
        allow(console).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
        console.instance_variable_set(:@current_account, instance_double('Account', name: name))
        expect { console.main_menu }.to output(/Welcome, #{name}/).to_stdout
        MAIN_OPERATIONS_TEXTS.each do |text|
          allow(console).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
          expect { console.main_menu }.to output(/#{text}/).to_stdout
        end
      end
    end

    context 'when commands used' do
      let(:undefined_command) { 'undefined' }

      it 'calls specific methods on predefined commands' do
        allow(console).to receive(:puts)
        console.instance_variable_set(:@current_account, instance_double('Account', name: name))
        allow(console).to receive(:exit)

        commands.each do |command, method_name|
          expect(console).to receive(method_name)
          allow(console).to receive_message_chain(:gets, :chomp).and_return(command, 'exit')
          console.main_menu
        end
      end

      it 'outputs incorrect message on undefined command' do
        console.instance_variable_set(:@current_account, instance_double('Account', name: name))
        expect(console).to receive(:exit)
        allow(console).to receive_message_chain(:gets, :chomp).and_return(undefined_command, 'exit')
        expect { console.main_menu }.to output(/#{ERROR_PHRASES[:wrong_command]}/).to_stdout
      end
    end
  end

  describe '#destroy_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }
    let(:correct_login) { 'test' }
    let(:fake_login) { 'test1' }
    let(:fake_login2) { 'test2' }
    let(:correct_account) { instance_double('Account', login: correct_login) }
    let(:fake_account) { instance_double('Account', login: fake_login) }
    let(:fake_account2) { instance_double('Account', login: fake_login2) }
    let(:accounts) { [correct_account, fake_account, fake_account2] }
    let(:account_manager) { AccountManager.new }

    before do
      console.instance_variable_set(:@account_manager, account_manager)
      allow(console).to receive(:exit)
    end

    after do
      File.delete(test_filename) if File.exist?(test_filename)
    end

    it 'with correct output' do
      expect(account_manager).to receive_message_chain(:gets, :chomp) {}
      expect { console.destroy_account }.to output(COMMON_PHRASES[:destroy_account]).to_stdout
    end

    context 'when deleting' do
      before do
        allow(account_manager).to receive(:puts)
      end

      it 'deletes account if user inputs is y' do
        expect(account_manager).to receive_message_chain(:gets, :chomp) { success_input }
        expect(Account).to receive(:load_accounts) { accounts }
        stub_const('DatabaseManager::STORAGE_FILE', test_filename)
        console.instance_variable_set(:@current_account, Account.new(login: correct_login, password: '',
                                                                     name: '', age: 0))

        console.destroy_account

        expect(File.exist?(test_filename)).to be true
        file_accounts = YAML.load_file(test_filename)
        expect(file_accounts).to be_a Array
        expect(file_accounts.size).to be 2
      end

      it "doesn't delete account" do
        expect(account_manager).to receive_message_chain(:gets, :chomp) { cancel_input }

        console.destroy_account

        expect(File.exist?(test_filename)).to be false
      end
    end
  end

  describe '#show_cards' do
    let(:cards) { [CapitalistCard.create, VirtualCard.create] }

    it 'display cards if there are any' do
      console.instance_variable_set(:@current_account, instance_double('Account', cards: cards))
      cards.each { |card| expect(console).to receive(:puts).with(I18n.t(:card, number: card.number, type: card.type)) }
      console.show_cards
    end

    it 'outputs error if there are no active cards' do
      console.instance_variable_set(:@current_account, instance_double('Account', cards: []))
      expect(console).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])
      console.show_cards
    end
  end

  describe '#create_card' do
    let(:account) { Account.new(name: '', age: 0, login: '', password: '') }
    let(:card_manager) { CardManager.new(account) }

    before do
      console.instance_variable_set(:@card_manager, card_manager)
    end

    context 'with correct output' do
      it do
        expect(card_manager).to receive(:puts).with(I18n.t(:create_card_message))
        console.instance_variable_set(:@current_account, account)
        allow(Account).to receive(:accounts).and_return([])
        allow(Account).to receive(:save_account)
        expect(card_manager).to receive_message_chain(:gets, :chomp) { 'usual' }

        console.create_card
      end
    end

    context 'when correct card choose' do
      before do
        allow(Account).to receive(:accounts) { [account] }
        stub_const('DatabaseManager::STORAGE_FILE', test_filename)
        console.instance_variable_set(:@current_account, account)
        allow(card_manager).to receive(:puts)
      end

      after do
        File.delete(test_filename) if File.exist?(test_filename)
      end

      CARDS.each do |card_type, card_info|
        it "create card with #{card_type} type" do
          expect(card_manager).to receive_message_chain(:gets, :chomp) { card_info[:type] }

          console.create_card

          expect(File.exist?(test_filename)).to be true
          file_accounts = YAML.load_file(test_filename)
          expect(file_accounts.first.cards.first.type).to eq card_info[:type]
          expect(file_accounts.first.cards.first.balance).to eq card_info[:balance]
          expect(file_accounts.first.cards.first.number.length).to be 16
        end
      end
    end

    context 'when incorrect card choose' do
      it do
        console.instance_variable_set(:@current_account, account)
        allow(Account).to receive(:save_account)
        allow(Account).to receive(:accounts).and_return([])
        allow(card_manager).to receive_message_chain(:gets, :chomp).and_return('test', 'usual')

        expect { console.create_card }.to output(/#{ERROR_PHRASES[:wrong_card_type]}/).to_stdout
      end
    end
  end

  describe '#destroy_card' do
    let(:account) { Account.new(name: '', age: 0, login: '', password: '') }
    let(:card_manager) { CardManager.new(account) }

    before do
      console.instance_variable_set(:@card_manager, card_manager)
    end

    context 'without cards' do
      it 'shows message about not active cards' do
        expect { console.destroy_card }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { UsualCard.create }
      let(:card_two) { VirtualCard.create }
      let(:fake_cards) { [card_one, card_two] }

      before do
        account.cards = fake_cards
        console.instance_variable_set(:@current_account, account)
      end

      context 'with correct output' do
        it do
          allow(card_manager).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { console.destroy_card }.to output(/#{COMMON_PHRASES[:if_you_want_to_delete]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /#{I18n.t(:indexed_card, number: card.number, type: card.type, index: i + 1)}/
            expect { console.destroy_card }.to output(message).to_stdout
          end
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(card_manager).to receive(:puts)
          expect(card_manager).to receive_message_chain(:gets, :chomp) { 'exit' }
          console.destroy_card
        end
      end

      context 'with incorrect input of card number' do
        it do
          allow(card_manager).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { console.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(card_manager).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { console.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:accept_for_deleting) { 'y' }
        let(:reject_for_deleting) { 'asdf' }
        let(:deletable_card_number) { 1 }

        before do
          stub_const('DatabaseManager::STORAGE_FILE', test_filename)
          allow(Account).to receive(:accounts) { [account] }
          allow(card_manager).to receive(:puts)
        end

        after do
          File.delete(test_filename) if File.exist?(test_filename)
        end

        it 'accept deleting' do
          commands = [deletable_card_number, accept_for_deleting]
          allow(card_manager).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { console.destroy_card }.to change { account.cards.size }.by(-1)

          expect(File.exist?(test_filename)).to be true
          file_accounts = YAML.load_file(test_filename)
          expect(file_accounts.first.cards).not_to include(card_one)
        end

        it 'decline deleting' do
          commands = [deletable_card_number, reject_for_deleting]
          allow(card_manager).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { console.destroy_card }.not_to change(account.cards, :size)
        end
      end
    end
  end

  describe '#put_money' do
    let(:account) { Account.new(name: '', age: 0, login: '', password: '') }
    let(:transaction_manager) { TransactionManager.new(account) }

    before do
      console.instance_variable_set(:@transaction_manager, transaction_manager)
    end

    context 'without cards' do
      it 'shows message about not active cards' do
        expect { console.put_money }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { instance_double(BaseCard) }
      let(:card_two) { instance_double(BaseCard) }
      let(:fake_cards) { [card_one, card_two] }

      before do
        allow(card_one).to receive(:number).and_return(1)
        allow(card_one).to receive(:type).and_return('test')
        allow(card_two).to receive(:number).and_return(2)
        allow(card_two).to receive(:type).and_return('test2')
        account.cards = fake_cards
      end

      context 'with correct outout' do
        it do
          allow(transaction_manager).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { console.put_money }.to output(/#{COMMON_PHRASES[:choose_card]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /#{I18n.t(:indexed_card, number: card.number, type: card.type, index: i + 1)}/
            expect { console.put_money }.to output(message).to_stdout
          end
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(transaction_manager).to receive(:puts)
          expect(transaction_manager).to receive_message_chain(:gets, :chomp) { 'exit' }
          console.put_money
        end
      end

      context 'with incorrect input of card number' do
        it do
          allow(transaction_manager).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { console.put_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(transaction_manager).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { console.put_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) { CapitalistCard.create }
        let(:card_two) { CapitalistCard.create }
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }

        before do
          allow(transaction_manager).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { console.put_money }.to output(/#{COMMON_PHRASES[:input_amount]}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { console.put_money }.to output(/#{ERROR_PHRASES[:correct_amount]}/).to_stdout
          end
        end

        context 'with amount greater then 0' do
          context 'with tax greater than amount' do
            let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

            it do
              expect { console.put_money }.to output(/#{ERROR_PHRASES[:tax_higher]}/).to_stdout
            end
          end

          context 'with tax lower than amount' do
            let(:custom_cards) do
              [
                { card: UsualCard.new(default_balance), tax: correct_money_amount_greater_than_tax * 0.02 },
                { card: CapitalistCard.new(default_balance), tax: 10 },
                { card: VirtualCard.new(default_balance), tax: 1 }
              ]
            end

            let(:commands) { [chosen_card_number, correct_money_amount_greater_than_tax] }

            after do
              File.delete(test_filename) if File.exist?(test_filename)
            end

            it do
              custom_cards.each do |custom_card|
                card = custom_card[:card]
                allow(transaction_manager).to receive_message_chain(:gets, :chomp).and_return(*commands)
                allow(Account).to receive(:accounts) { [account] }
                account.cards = [card]
                stub_const('DatabaseManager::STORAGE_FILE', test_filename)
                new_balance = default_balance + correct_money_amount_greater_than_tax - custom_card[:tax]
                message = I18n.t(:puted_money_message, amount: correct_money_amount_greater_than_tax,
                                                       number: card.number, balance: new_balance,
                                                       tax: custom_card[:tax])

                expect { console.put_money }.to output(
                  /#{message}/
                ).to_stdout

                expect(File.exist?(test_filename)).to be true
                file_accounts = YAML.load_file(test_filename)
                expect(file_accounts.first.cards.first.balance).to eq(new_balance)
              end
            end
          end
        end
      end
    end
  end

  describe '#withdraw_money' do
    let(:account) { Account.new(name: '', age: 0, login: '', password: '') }
    let(:transaction_manager) { TransactionManager.new(account) }

    before do
      console.instance_variable_set(:@transaction_manager, transaction_manager)
    end

    context 'without cards' do
      it 'shows message about not active cards' do
        expect { console.withdraw_money }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { instance_double(BaseCard) }
      let(:card_two) { instance_double(BaseCard) }
      let(:fake_cards) { [card_one, card_two] }

      before do
        allow(card_one).to receive(:number).and_return(1)
        allow(card_one).to receive(:type).and_return('test')
        allow(card_two).to receive(:number).and_return(2)
        allow(card_two).to receive(:type).and_return('test2')
        account.cards = fake_cards
      end

      context 'with correct output' do
        it do
          allow(transaction_manager).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { console.withdraw_money }.to output(/#{COMMON_PHRASES[:choose_card_withdrawing]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /#{I18n.t(:indexed_card, number: card.number, type: card.type, index: i + 1)}/
            expect { console.withdraw_money }.to output(message).to_stdout
          end
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(transaction_manager).to receive(:puts)
          console.instance_variable_set(:@current_account, console)
          expect(transaction_manager).to receive_message_chain(:gets, :chomp) { 'exit' }
          console.withdraw_money
        end
      end

      context 'with incorrect input of card number' do
        it do
          allow(transaction_manager).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { console.withdraw_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(transaction_manager).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { console.withdraw_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) { CapitalistCard.create }
        let(:card_two) { CapitalistCard.create }
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }

        before do
          allow(transaction_manager).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { console.withdraw_money }.to output(/#{COMMON_PHRASES[:withdraw_amount]}/).to_stdout
          end
        end
      end
    end
  end

  describe '#accounts' do
    it 'returns all accounts' do
      allow(Account).to receive(:accounts).and_return([])
      expect(console.accounts).to be_a(Array)
      expect(console.accounts).to eq []
    end
  end

  describe '#send_money' do
    let(:account) { Account.new(name: '', age: 0, login: '', password: '') }
    let(:transaction_manager) { TransactionManager.new(account) }

    before do
      console.instance_variable_set(:@transaction_manager, transaction_manager)
    end

    context 'without cards' do
      it 'shows message about not active cards' do
        expect { console.send_money }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with incorrect input of card number' do
      let(:card_one) { CapitalistCard.create }
      let(:card_two) { CapitalistCard.create }
      let(:fake_cards) { [card_one] }

      before do
        account.cards = fake_cards
      end

      it do
        allow(transaction_manager).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1)
        expect { console.send_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
      end

      it do
        allow(transaction_manager).to receive_message_chain(:gets, :chomp).and_return(-1)
        expect { console.send_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
      end
    end

    context 'with incorrect input of recipient card number' do
      let(:card_one) { CapitalistCard.create }
      let(:fake_cards) { [card_one] }
      let(:incorrect_card_number) { '1' * (BaseCard::NUMBER_LENGTH - 1) }

      before do
        account.cards = fake_cards
      end

      it do
        allow(transaction_manager).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length,
                                                                                      incorrect_card_number)
        expect { console.send_money }.to output(/#{I18n.t(:invalid_card_number_message)}/).to_stdout
      end
    end
  end
end
