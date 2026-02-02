# frozen_string_literal: true

# rbs_inline: enabled

require "http"

module AmazonAds
  # Requests Login with Amazon (LWA) access tokens for the Amazon Ads API.
  # Handles token caching and automatic refresh when tokens expire.
  #
  # @see https://advertising.amazon.com/API/docs/en-us/info/api-overview
  class LWA
    URL = "https://api.amazon.com/auth/o2/token" #: String
    TOKEN_EXPIRY_BUFFER = 60 #: Integer

    attr_reader :client_id #: String
    attr_reader :client_secret #: String
    attr_reader :refresh_token #: String

    #: (?client_id: String, ?client_secret: String, ?refresh_token: String) -> void
    def initialize(
      client_id: ENV.fetch("AMAZON_ADS_CLIENT_ID"),
      client_secret: ENV.fetch("AMAZON_ADS_CLIENT_SECRET"),
      refresh_token: ENV.fetch("AMAZON_ADS_REFRESH_TOKEN")
    )
      @client_id = client_id
      @client_secret = client_secret
      @refresh_token = refresh_token
      @access_token = nil #: String?
      @expires_at = nil #: Time?
      @mutex = Mutex.new
    end

    # Returns a valid access token, refreshing if necessary.
    #: () -> String
    def access_token
      @mutex.synchronize do
        refresh! if token_expired?
        @access_token or raise AmazonAds::AuthenticationError, "Failed to obtain access token"
      end
    end

    # Forces a token refresh regardless of expiry.
    #: () -> String
    def refresh!
      response = HTTP.post(URL, form: params)

      unless response.status.success?
        body = begin
          response.parse
        rescue StandardError
          {}
        end
        message = body["error_description"] || body["error"] || "Authentication failed"
        raise AmazonAds::AuthenticationError.new(message, response: response)
      end

      data = response.parse
      @access_token = data.fetch("access_token")
      expires_in = data.fetch("expires_in", 3600)
      @expires_at = Time.now + expires_in - TOKEN_EXPIRY_BUFFER

      @access_token
    end

    # Returns true if the token is expired or not yet fetched.
    #: () -> bool
    def token_expired?
      @access_token.nil? || @expires_at.nil? || Time.now >= @expires_at
    end

    private

    #: () -> Hash[String, String]
    def params
      {
        "grant_type" => "refresh_token",
        "client_id" => client_id,
        "client_secret" => client_secret,
        "refresh_token" => refresh_token,
      }
    end
  end
end
