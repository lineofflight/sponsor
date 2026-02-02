# frozen_string_literal: true

# rbs_inline: enabled

require "http"

module AmazonAds
  # Base class for Amazon Ads API clients.
  # Handles authentication, response parsing, error mapping, and retry logic.
  class API
    ENDPOINTS = { #: Hash[Symbol, String]
      na: "https://advertising-api.amazon.com",
      eu: "https://advertising-api-eu.amazon.com",
      fe: "https://advertising-api-fe.amazon.com",
    }.freeze

    MAX_RETRIES = 3 #: Integer
    BASE_RETRY_DELAY = 1 #: Integer

    attr_reader :region #: Symbol
    attr_reader :profile_id #: String?

    #: (region: Symbol, ?access_token: String?, ?lwa: LWA?, ?profile_id: String?) -> void
    def initialize(region:, access_token: nil, lwa: nil, profile_id: nil)
      @region = region
      @access_token = access_token
      @lwa = lwa
      @profile_id = profile_id

      unless @access_token || @lwa
        raise ArgumentError, "Either access_token or lwa must be provided"
      end
    end

    private

    # Returns the current access token, refreshing via LWA if needed.
    #: () -> String
    def access_token
      @lwa ? @lwa.access_token : @access_token or raise AmazonAds::AuthenticationError, "No access token"
    end

    #: () -> HTTP::Client
    def http
      HTTP
        .headers(default_headers)
        .use(:auto_inflate)
    end

    #: () -> Hash[String, String]
    def default_headers
      headers = {
        "Authorization" => "Bearer #{access_token}",
        "Amazon-Advertising-API-ClientId" => client_id,
        "Content-Type" => "application/json",
        "Accept" => "application/json",
      }
      headers["Amazon-Advertising-API-Scope"] = profile_id if profile_id

      headers
    end

    #: () -> String
    def client_id
      ENV.fetch("AMAZON_ADS_CLIENT_ID")
    end

    #: () -> String
    def endpoint
      ENDPOINTS.fetch(region) do
        raise ArgumentError, "Unknown region: #{region}"
      end
    end

    # Handles HTTP response, raising appropriate errors or parsing success responses.
    #: (HTTP::Response) -> untyped
    def handle_response(response)
      case response.status.code
      when 200..299
        return if response.body.to_s.empty?

        response.parse
      when 400
        raise AmazonAds::BadRequestError.new("Bad request", response: response)
      when 401
        raise AmazonAds::AuthenticationError.new("Unauthorized", response: response)
      when 404
        raise AmazonAds::NotFoundError.new("Not found", response: response)
      when 429
        retry_after = response.headers["Retry-After"]&.to_i
        raise AmazonAds::RateLimitError.new("Rate limited", response: response, retry_after: retry_after)
      when 500..599
        raise AmazonAds::ServerError.new("Server error", response: response)
      else
        raise AmazonAds::Error.new("Request failed with status #{response.status.code}", response: response)
      end
    end

    # Executes request with retry logic for rate limiting.
    #: () { () -> HTTP::Response } -> untyped
    def with_retry(&block)
      retries = 0

      loop do
        response = yield
        return handle_response(response)
      rescue AmazonAds::RateLimitError => e
        retries += 1
        raise if retries > MAX_RETRIES

        delay = e.retry_after || (BASE_RETRY_DELAY * (2**(retries - 1)))
        sleep(delay)
      end
    end

    #: (String, ?params: Hash[String, untyped]) -> untyped
    def get(path, params: {})
      with_retry { http.get("#{endpoint}#{path}", params: params) }
    end

    #: (String, ?body: Hash[String, untyped]) -> untyped
    def post(path, body: {})
      with_retry { http.post("#{endpoint}#{path}", json: body) }
    end

    #: (String, ?body: Hash[String, untyped]) -> untyped
    def put(path, body: {})
      with_retry { http.put("#{endpoint}#{path}", json: body) }
    end

    #: (String, ?body: Hash[String, untyped]) -> untyped
    def patch(path, body: {})
      with_retry { http.patch("#{endpoint}#{path}", json: body) }
    end

    #: (String) -> untyped
    def delete(path)
      with_retry { http.delete("#{endpoint}#{path}") }
    end
  end
end
