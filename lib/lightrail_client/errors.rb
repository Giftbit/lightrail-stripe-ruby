module LightrailClient
  class LightrailError < StandardError
    attr_reader :message
    attr_accessor :response

    def initialize (message='', response)
      @message = message
      @response = response
    end
  end

  class AuthorizationError < LightrailError
  end

  class InsufficientValueError < LightrailError
  end

  class BadParameterError < LightrailError
  end

  class CouldNotFindObjectError < LightrailError
  end

  class IdempotencyError < LightrailError
  end

  class ThirdPartyPaymentError < LightrailError
  end


  class LightrailArgumentError < ArgumentError
  end

end