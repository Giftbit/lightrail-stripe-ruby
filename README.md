# Lightrail Stripe Integration Gem (alpha)

Lightrail is a modern platform for digital account credits, gift cards, promotions, and points (to learn more, visit [Lightrail](https://www.lightrail.com/)). The Lightrail Stripe gem provides a client library for developers to easily use Lightrail alongside [Stripe](https://stripe.com/).

If you are looking for specific use cases or other languages, check out [related projects](https://github.com/Giftbit/lightrail-stripe-ruby#related-projects). For a complete list of all Lightrail libraries and integrations, check out the [Lightrail Integration page](https://github.com/Giftbit/Lightrail-API-Docs/blob/usecases/Integrations.md).

## Features

- Simple order checkout which supports Lightrail gift card redemption alongside a Stripe payment
- Convenient wrappers for making common calls to the Lightrail API using a similar interface to Stripe

This gem depends on the [Lightrail Client Gem](https://github.com/Giftbit/lightrail-client-ruby) for communicating with the Lightrail API. It offers convenient wrappers for common API calls for those who are already using [Stripe's Ruby gem](https://github.com/stripe/stripe-ruby) and are familiar with that interface: `Lightrail::LightrailCharge.create`,  `Lightrail::Refund.create`, etc. These calls will return class instance objects instead of hashes, with convenience methods and properties that can be accessed with dot notation (for a more detailed example, see the [balance check](#balance-check) code in the following section):

```ruby
gift_value = Lightrail::LightrailValue.retrieve(<CARD ID>)
gift_value.total_available #=> 3500
```

## Related Projects

- [Lightrail Client Gem](https://github.com/Giftbit/lightrail-client-ruby)
- [Lightrail-Stripe Java Integration](https://github.com/Giftbit/lightrail-stripe-java)
- [Lightrail Java Client](https://github.com/Giftbit/lightrail-client-java)

## Usage

Before using any parts of the library, you need to set up your Lightrail API key, and if you have not already done so, you will also need to set up your Stripe API key:

```ruby
Lightrail.api_key = '<your lightrail API key>'
Stripe.api_key = '<your stripe API key>
```

*A note on sample code snippets: for reasons of legibility, the output for most calls has been simplified. Attributes of response objects that are not relevant here have been omitted.*

### Order Checkout Using `StripeLightrailSplitTenderCharge`

`StripeLightrailSplitTenderCharge` is a class designed to resemble the interface of a Stripe `Charge` class which transparently splits the transaction between Lightrail and Stripe. The Lightrail parameter could be one of the following:

- `code`, specifying a gift card by its code, or
- `cardId`, specifying a gift card by its card ID

The Stripe parameter could be:

- `source`, indicating a Stripe token, or
- `customer`, indicating a Stripe customer ID

Here is a simple example:

```ruby
split_tender_charge_params = {
  amount: 1000,
  currency: 'USD',
  code: '<GIFT CODE>',
  source: '<STRIPE TOKEN>',
}

split_tender_charge = LightrailClient::StripeLightrailSplitTenderCharge.create(split_tender_charge_params);
```

If you don't pass any Lightrail parameters, the entire transaction will be charged to Stripe. Similarly, if you don't provide any Stripe parameters, the library will attempt to charge the entire transaction to Lightrail. If the value of the gift card is not enough to cover the entire transaction amount and no Stripe payment method is included, you will receive a `BadParameterError` asking you to provide a Stripe parameter.

When both a Lightrail and a Stripe parameter are provided, the library will try to split the payment, in such a way that Lightrail contributes to the payment as much as possible. This usually means:

- If the Lightrail value is sufficient, the entire transaction will be charged to the gift card.
- If the transaction amount is larger than the Lightrail value, the remainder will be charged to Stripe.

## Managing Lightrail Cards
### Balance Check

Using the `Lightrail::LightrailValue` class, call `.retrieve_by_card` or `.retrieve_by_code`.

```ruby
gift_balance_details = Lightrail::LightrailValue.retrieve_by_card("<GIFT CARD ID>")
# or use the fullCode:
# gift_balance_details = Lightrail::LightrailValue.retrieve_by_code("<GIFT CODE>")

#=>  <Lightrail::LightrailValue:0x007fe24b16f500
         @principal=
            {
            'currentValue' => 3000,
            'state' => 'ACTIVE',
            'expires' => nil,
            'startDate' => nil,
            'programId' => 'program-123456',
            'valueStoreId' => 'value-123456'},
         @attached=[{'currentValue' => 500,
            'state' => 'ACTIVE',
            #...},
          {'currentValue' => 250,
            'state' => 'EXPIRED',
            #...}],
         @currency="USD",
         @cardType="GIFT_CARD",
         @balanceDate="2017-05-29T13:37:02.756Z",
         @cardId="card-123456>

gift_total_value = gift_balance_details.total_available
#=>  3500
```

### Charging a Gift Card

Use`Lightrail::LightrailCharge.create` to charge a gift card. The minimum required parameters are either the `fullCode` or `cardId`, the `currency`, and the `amount` of the transaction (a positive integer in the smallest currency unit, e.g., 500 cents is 5 USD):

```ruby
gift_charge = Lightrail::LightrailCharge.create({
                                      amount: 1850,
                                      currency: 'USD',
                                      code: '<GIFT CODE>'
                                    })
#=> <Lightrail::LightrailCharge:0x007fdb62206e68
       @value=-1850,
       @userSuppliedId="17223eff",
       @transactionType="DRAWDOWN",
       @currency="USD",
       @transactionId="transaction-cd245",
       #...>
```

**A note on idempotency:** All calls to create or act on transactions (refund, void, capture) can optionally take a `userSuppliedId` parameter. The `userSuppliedId` is a client-side identifier (unique string) which is used to ensure idempotency (for more details, see the  [API documentation](https://www.lightrail.com/docs/)). If you do not provide a `userSuppliedId`, the gem will create one for you for any calls that require one.

```ruby
gift_charge = Lightrail::LightrailCharge.create({
                                      amount: 1850,
                                      currency: 'USD',
                                      code: '<GIFT CODE>',
                                      userSuppliedId: 'order-13jg9s0era9023-u9a-0ea'
                                    })
```

Note that Lightrail does not support currency exchange and the currency provided in this method must match the currency of the gift card.

For more details on the parameters that you can pass in for a charge request and the response that you will get back, see the [Lightrail API documentation](https://www.lightrail.com/docs/).

### Authorize-Capture Flow

You can create a pending charge for a Lightrail gift card the same way you would with Stripe for a credit card — simply by adding `capture: false` to your charge parameters. The pending charge object returned from this method call will also have convenience methods to directly `#capture!` or `#cancel!` that charge:

```ruby
gift_charge = Lightrail::LightrailCharge.create({
                                      amount: 1850,
                                      currency: 'USD',
                                      code: '<GIFT CODE>',
                                      capture: false,
                                    })
# later on
gift_charge.capture!
#=> <Lightrail::LightrailCharge:0x007fdb633531d0
       @value=-1850,
       @userSuppliedId="17223eff",
       @dateCreated="2017-05-29T13:37:02.756Z",
       @transactionType="DRAWDOWN",
       @transactionAccessMethod="RAWCODE",
       @cardId="<GIFT CARD ID>",
       @currency="USD",
       @transactionId="transaction-cd245",
       @parentTransactionId="transaction-b9d4444">

# or
gift_charge.cancel!
#=> <Lightrail::LightrailCharge:0x007fdb62854018
       @value=-1850,
       @userSuppliedId="17223eff",
       @dateCreated="2017-05-29T13:37:02.756Z",
       @transactionType="PENDING_VOID",
       @transactionAccessMethod="RAWCODE",
       @cardId="<GIFT CARD ID>",
       @currency="USD",
       @transactionId="transaction-0ce6f05",
       @parentTransactionId="transaction-b9d4444">
```

Note that `#capture!` and `#cancel!` will each return a **new transaction** and will not modify the instance they are called on. These new transactions will have their own `transactionId`. If you need to record the transaction ID of the captured or canceled charge, you can get it from the object returned by these methods (a new instance of `LightrailCharge`).

### Refunding a Charge

You can undo a charge by using the `Lightrail::Refund` class and passing in transaction instance you wish to refund. This will create a new `refund` transaction which will return the charged amount back to the card. The return object will be an instance of `Lightrail::Refund`. If you need the transaction ID of the refund transaction, you can find it on this object.

```ruby
gift_charge = Lightrail::LightrailCharge.create(<CHARGE PARAMS>)

# later on
Lightrail::Refund.create(gift_charge)
#=> <Lightrail::Refund:0x007fdb62854018
       @value=1850,
       @userSuppliedId="873b08ab",
       @dateCreated="2017-05-29T13:37:02.756Z",
       @transactionType="DRAWDOWN_REFUND",
       @transactionAccessMethod="CARDID",
       @cardId="<GIFT CARD ID>",
       @currency="USD",
       @transactionId="transaction-0f2a67",
       @parentTransactionId="transaction-2271e3">
```

Note that this does not necessarily mean that the refunded amount is available for a re-charge. In the edge case where the funds for the original charge came from a promotion which has now expired, refunding will return those funds back to the now-expired value store and therefore the value will not be available for re-charge. To learn more about using value stores for temporary promotions, see the [Lightrail API docs](https://github.com/Giftbit/Lightrail-API-Docs/blob/master/use-cases/promotions.md).

### Funding a Gift Card

To add funds to a gift card, you can use the `Lightrail::LightrailFund` class. Note that the Lightrail API does not permit funding a gift card by its `code` and the only way to fund a card is by providing its `cardId`:

```ruby
gift_fund = Lightrail::LightrailFund.create({
                                      amount: 500,
                                      currency: 'USD',
                                      cardId: '<GIFT CARD ID>',
                                    })

#=> <Lightrail::LightrailFund:0x007fb7b18b96b8
       @value=500,
       @userSuppliedId="4f86a1be",
       @dateCreated="2017-05-29T13:37:02.756Z",
       @transactionType="FUND",
       @transactionAccessMethod="CARDID",
       @cardId="<GIFT CARD ID>",
       @currency="USD",
       @transactionId="transaction-240eca6">
```


## Installation

This gem is in alpha mode and is not yet available on RubyGems. You can use it in your project by adding this line to your application's Gemfile:

```ruby
gem 'lightrail_stripe', :git => 'https://github.com/Giftbit/lightrail-stripe-ruby.git'
```

And then execute:

```
$ bundle
```

Note that this gem depends on the [Lightrail Client Gem](https://github.com/Giftbit/lightrail-client-ruby), which is also in alpha mode and may be added in a similar way:

```ruby
gem 'lightrail_client', :git => 'https://github.com/Giftbit/lightrail-client-ruby.git'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Giftbit/lightrail-stripe-ruby.

## Development

After checking out the repo, run `bin/setup` to install dependencies, then run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
