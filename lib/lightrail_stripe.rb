require "faraday"
require "openssl"
require "json"
require "securerandom"

require "lightrail_client"
require "stripe"

require "lightrail_stripe/version"

require "lightrail_stripe/wrappers/translator"
require "lightrail_stripe/wrappers/lightrail_charge"
require "lightrail_stripe/wrappers/lightrail_fund"
require "lightrail_stripe/wrappers/lightrail_value"
require "lightrail_stripe/wrappers/refund"

require "lightrail_stripe/hybrid_validator"
require "lightrail_stripe/hybrid_translator"

require "lightrail_stripe/stripe_lightrail_hybrid_charge"

module Lightrail
  class << self
    attr_accessor :api_base, :api_key
  end
  @api_base = 'https://api.lightrail.com/v1'
end
