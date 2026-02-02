# frozen_string_literal: true

# rbs_inline: enabled

module AmazonAds
  # High-level client for Amazon Ads API.
  # Provides convenient access to all API endpoints with automatic authentication.
  class Client
    attr_reader :lwa #: LWA
    attr_reader :region #: Symbol
    attr_reader :profile_id #: String?

    #: (?region: Symbol, ?profile_id: String?, ?lwa: LWA?) -> void
    def initialize(region: AmazonAds.configuration.region, profile_id: AmazonAds.configuration.profile_id, lwa: nil)
      @lwa = lwa || AmazonAds.configuration.lwa
      @region = region
      @profile_id = profile_id
    end

    # Access Profiles API
    #: () -> Profiles
    def profiles
      @profiles ||= Profiles.new(region: region, lwa: lwa, profile_id: profile_id)
    end

    # Access Sponsored Products API
    #: () -> SponsoredProducts
    def sponsored_products
      @sponsored_products ||= SponsoredProducts.new(region: region, lwa: lwa, profile_id: profile_id)
    end

    # Creates a new client with a different profile ID
    #: (String) -> Client
    def with_profile(profile_id)
      Client.new(region: region, profile_id: profile_id, lwa: lwa)
    end
  end
end
