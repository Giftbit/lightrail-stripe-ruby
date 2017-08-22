require "bundler/setup"
require "lightrail_stripe"
require "pry"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    Lightrail.api_key = ENV['LIGHTRAIL_API_KEY']
  end

  # Ensure card balance will go back to same state after test suite runs
  config.before(:suite) do
    balance_response = Lightrail::LightrailValue.retrieve_by_code(ENV['LIGHTRAIL_TEST_CODE'])
    if (balance_response.is_a? Lightrail::LightrailValue)
      $LIGHTRAIL_CARD_BALANCE_BEFORE_TESTS = balance_response.principal['currentValue']
    else
      fail "balance_response was not an instance of Lightrail::LightrailValue"
    end
    puts "Card balance before tests: #{$LIGHTRAIL_CARD_BALANCE_BEFORE_TESTS}"
  end

  config.after(:suite) do
    balance_response = Lightrail::LightrailValue.retrieve_by_code(ENV['LIGHTRAIL_TEST_CODE'])
    if (balance_response.is_a? Lightrail::LightrailValue)
      balance_after_tests = balance_response.principal['currentValue']
    else
      fail "balance_response was not an instance of Lightrail::LightrailValue"
    end

    difference = $LIGHTRAIL_CARD_BALANCE_BEFORE_TESTS - balance_after_tests

    if difference != 0
      fund_object_to_restore_balance = {
          cardId: ENV['LIGHTRAIL_TEST_CARD_ID'],
          amount: difference,
          currency: ENV['TEST_CURRENCY'],
          userSuppliedId: 'restoring-balance-after-tests-' + SecureRandom::uuid
      }

      Lightrail::LightrailFund.create(fund_object_to_restore_balance)

      confirmation_new_balance = Lightrail::LightrailValue.retrieve_by_code(ENV['LIGHTRAIL_TEST_CODE']).principal['currentValue']
      puts "Card balance restored after tests: #{confirmation_new_balance}"
    else
      puts "Card balance not changed by tests: #{balance_after_tests}"
    end

    $LIGHTRAIL_CARD_BALANCE_BEFORE_TESTS = nil
  end

end
