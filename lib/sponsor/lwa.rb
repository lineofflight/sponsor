# frozen_string_literal: true

# rbs_inline: enabled

require "http"

module Sponsor
  # Requests Login with Amazon (LWA) access tokens for the Amazon Ads API.
  #
  # @see https://advertising.amazon.com/API/docs/en-us/info/api-overview
  class LWA
    URL = "https://api.amazon.com/auth/o2/token" #: String

    attr_reader :client_id #: String
    attr_reader :client_secret #: String
    attr_reader :refresh_token #: String

    #: (?client_id: String, ?client_secret: String, ?refresh_token: String) -> void
    def initialize(
      client_id: ENV.fetch("LWA_CLIENT_ID"),
      client_secret: ENV.fetch("LWA_CLIENT_SECRET"),
      refresh_token: ENV.fetch("LWA_REFRESH_TOKEN")
    )
      @client_id = client_id
      @client_secret = client_secret
      @refresh_token = refresh_token
    end

    #: () -> HTTP::Response
    def request
      HTTP.post(URL, form: params)
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
