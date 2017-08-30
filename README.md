# Lightrail Stripe Integration Gem (alpha)

Lightrail is a modern platform for digital account credits, gift cards, promotions, and points (to learn more, visit [Lightrail](https://www.lightrail.com/)). The Lightrail Stripe gem provides a client library for developers to easily use Lightrail alongside [Stripe](https://stripe.com/).

If you are looking for specific use cases or other languages, check out [related projects](https://github.com/Giftbit/lightrail-stripe-ruby#related-projects). For a complete list of all Lightrail libraries and integrations, check out the [Lightrail Integration page](https://github.com/Giftbit/Lightrail-API-Docs/blob/usecases/Integrations.md).

## Features

- Simple order checkout which supports Lightrail gift card redemption alongside a Stripe payment.

## Usage

### Order Checkout Using `StripeLightrailHybridCharge`

`StripeLightrailHybridCharge` is a class designed to resemble the interface of a Stripe `Charge` class which transparently splits the transaction between Lightrail and Stripe. The Lightrail parameter could be one of the following:

- `code`, specifying a gift card by its code, or
- `cardId`, specifying a gift card by its card ID

The Stripe parameter could be:

- `source`, indicating a Stripe token, or
- `customer`, indicating a Stripe customer ID

Here is a simple example:

```ruby
LightrailClient.apiKey = '<your lightrail API key>';
Stripe.apiKey = '<your stripe API key>';

hybrid_charge_params = {
  amount: 1000,
  currency: 'USD',
  code: '<GIFT CODE>',
  source: '<STRIPE TOKEN>',
}

hybrid_charge = LightrailClient::StripeLightrailHybridCharge.create(hybrid_charge_params);
```

If you don't pass any Lightrail parameters, the entire transaction will be charged to Stripe. Similarly, if you don't provide any Stripe parameters, the library will attempt to charge the entire transaction to Lightrail. If the value of the gift card is not enough to cover the entire transaction amount and no Stripe payment method is included, you will receive a `BadParameterError` asking you to provide a Stripe parameter.

When both a Lightrail and a Stripe parameter are provided, the library will try to split the payment, in such a way that Lightrail contributes to the payment as much as possible. This usually means:

- If the Lightrail value is sufficient, the entire transaction will be charged to the gift card.
- If the transaction amount is larger than the Lightrail value, the remainder will be charged to Stripe.

## Related Projects

- [Lightrail-Stripe Java Integration](https://github.com/Giftbit/lightrail-stripe-java)
- [Lightrail Java Client](https://github.com/Giftbit/lightrail-client-java)

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
