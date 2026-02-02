# frozen_string_literal: true

# rbs_inline: enabled

module AmazonAds
  # Base error class for AmazonAds API errors
  class Error < StandardError
    attr_reader :response #: HTTP::Response?

    #: (?String?, ?response: HTTP::Response?) -> void
    def initialize(message = nil, response: nil)
      @response = response
      super(message)
    end
  end

  # Raised when authentication fails (401 Unauthorized)
  class AuthenticationError < Error
  end

  # Raised when rate limited (429 Too Many Requests)
  class RateLimitError < Error
    attr_reader :retry_after #: Integer?

    #: (?String?, ?response: HTTP::Response?, ?retry_after: Integer?) -> void
    def initialize(message = nil, response: nil, retry_after: nil)
      @retry_after = retry_after
      super(message, response: response)
    end
  end

  # Raised when resource not found (404 Not Found)
  class NotFoundError < Error
  end

  # Raised when request is invalid (400 Bad Request)
  class BadRequestError < Error
  end

  # Raised when server error occurs (5xx)
  class ServerError < Error
  end
end
