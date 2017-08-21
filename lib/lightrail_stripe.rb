require "dotenv/load"
require "faraday"
require "openssl"
require "json"
require "securerandom"

require "stripe"

require "lightrail_stripe/version"

require "lightrail_stripe/constants"
require "lightrail_stripe/errors"
require "lightrail_stripe/validator"
require "lightrail_stripe/translator"
require "lightrail_stripe/connection"

require "lightrail_stripe/lightrail_object"
require "lightrail_stripe/ping"
require "lightrail_stripe/lightrail_value"
require "lightrail_stripe/lightrail_charge"
require "lightrail_stripe/lightrail_fund"
require "lightrail_stripe/refund"

require "lightrail_stripe/stripe_lightrail_hybrid_charge"

module Lightrail
  class << self
    attr_accessor :api_base, :api_key
  end
  @api_base = 'https://api.lightrail.com/v1'
end
