require "faraday"
require "openssl"
require "json"
require "securerandom"

require "lightrail_client"
require "stripe"

require "lightrail_stripe/version"

require "lightrail_stripe/translator"
require "lightrail_stripe/split_tender_validator"

require "lightrail_stripe/wrappers/lightrail_charge"
require "lightrail_stripe/wrappers/lightrail_fund"
require "lightrail_stripe/wrappers/lightrail_value"
require "lightrail_stripe/wrappers/refund"

require "lightrail_stripe/stripe_lightrail_split_tender_charge"

module Lightrail
  class << self
    attr_accessor :api_base, :api_key
  end
  @api_base = 'https://api.lightrail.com/v1'
end
