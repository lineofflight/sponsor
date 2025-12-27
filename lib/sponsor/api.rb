# frozen_string_literal: true

# rbs_inline: enabled

require "http"

module Sponsor
  # Base class for Amazon Ads API clients
  class API
    ENDPOINTS = { #: Hash[Symbol, String]
      na: "https://advertising-api.amazon.com",
      eu: "https://advertising-api-eu.amazon.com",
      fe: "https://advertising-api-fe.amazon.com",
    }.freeze

    attr_reader :region #: Symbol
    attr_reader :access_token #: String
    attr_reader :profile_id #: String?

    #: (region: Symbol, access_token: String, ?profile_id: String?) -> void
    def initialize(region:, access_token:, profile_id: nil)
      @region = region
      @access_token = access_token
      @profile_id = profile_id
    end

    private

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

    #: (String, ?params: Hash[String, untyped]) -> HTTP::Response
    def get(path, params: {})
      http.get("#{endpoint}#{path}", params: params)
    end

    #: (String, ?body: Hash[String, untyped]) -> HTTP::Response
    def post(path, body: {})
      http.post("#{endpoint}#{path}", json: body)
    end

    #: (String, ?body: Hash[String, untyped]) -> HTTP::Response
    def put(path, body: {})
      http.put("#{endpoint}#{path}", json: body)
    end

    #: (String) -> HTTP::Response
    def delete(path)
      http.delete("#{endpoint}#{path}")
    end
  end
end
