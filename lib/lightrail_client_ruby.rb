require "dotenv/load"
require "faraday"
require "json"
require "securerandom"

require "lightrail_client_ruby/version"

require "lightrail_client_ruby/errors"
require "lightrail_client_ruby/validator"
require "lightrail_client_ruby/translator"
require "lightrail_client_ruby/connection"
require "lightrail_client_ruby/ping"
require "lightrail_client_ruby/gift_value"
require "lightrail_client_ruby/gift_charge"
require "lightrail_client_ruby/gift_fund"
require "lightrail_client_ruby/refund"

module LightrailClientRuby
  class << self
    attr_accessor :api_base, :api_key
  end
  @api_base = 'https://dev.lightrail.com/v1'
end
