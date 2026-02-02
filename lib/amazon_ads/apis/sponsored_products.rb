# frozen_string_literal: true

# rbs_inline: enabled

module AmazonAds
  # Amazon Ads API - Sponsored Products
  #
  # @see https://advertising.amazon.com/API/docs/en-us/sponsored-products
  class SponsoredProducts < API
    # Gets a bid recommendation for an ad group. [PLANNED DEPRECATION 3/27/2024]
    #: (Numeric) -> untyped
    def get_ad_group_bid_recommendations(ad_group_id)
      get("/v2/sp/adGroups/#{ad_group_id}/bidRecommendations")
    end

    # Gets a bid recommendation for a keyword. [PLANNED DEPRECATION 3/27/2024]
    #: (Numeric) -> untyped
    def get_keyword_bid_recommendations(keyword_id)
      get("/v2/sp/keywords/#{keyword_id}/bidRecommendations")
    end

    # Gets bid recommendations for keywords. [PLANNED DEPRECATION 3/27/2024]
    #: (?body: Hash[String, untyped]) -> untyped
    def create_keyword_bid_recommendations(body: {})
      post("/v2/sp/keywords/bidRecommendations", body: body)
    end

    # Gets suggested keywords for the specified ad group.
    #: (Numeric, ?max_num_suggestions: Integer?, ?ad_state_filter: String?) -> untyped
    def get_ad_group_suggested_keywords(ad_group_id, max_num_suggestions: nil, ad_state_filter: nil)
      get("/v2/sp/adGroups/#{ad_group_id}/suggested/keywords", params: { "maxNumSuggestions" => max_num_suggestions, "adStateFilter" => ad_state_filter }.compact)
    end

    # Gets suggested keywords with extended data for the specified ad group.
    #: (Numeric, ?max_num_suggestions: Integer?, ?suggest_bids: String?, ?ad_state_filter: String?) -> untyped
    def get_ad_group_suggested_keywords_ex(ad_group_id, max_num_suggestions: nil, suggest_bids: nil, ad_state_filter: nil)
      get("/v2/sp/adGroups/#{ad_group_id}/suggested/keywords/extended", params: { "maxNumSuggestions" => max_num_suggestions, "suggestBids" => suggest_bids, "adStateFilter" => ad_state_filter }.compact)
    end

    # Gets suggested keywords for the specified ASIN.
    #: (String, ?max_num_suggestions: Integer?) -> untyped
    def get_asin_suggested_keywords(asin_value, max_num_suggestions: nil)
      get("/v2/sp/asins/#{asin_value}/suggested/keywords", params: { "maxNumSuggestions" => max_num_suggestions }.compact)
    end

    # Gets suggested keyword for a specified list of ASINs.
    #: (?body: Hash[String, untyped]) -> untyped
    def bulk_get_asin_suggested_keywords(body: {})
      post("/v2/sp/asins/suggested/keywords", body: body)
    end

    # Gets a list of bid recommendations for keyword, product, or auto targeting expressions.
    #: (?body: Hash[String, untyped]) -> untyped
    def get_bid_recommendations(body: {})
      post("/v2/sp/targets/bidRecommendations", body: body)
    end

    # Request a snapshot
    #: (String, ?body: Hash[String, untyped]) -> untyped
    def request_snapshot(record_type, body: {})
      post("/v2/sp/#{record_type}/snapshot", body: body)
    end

    # Get the status of a requested snapshot
    #: (Numeric) -> untyped
    def get_snapshot_status(snapshot_id)
      get("/v2/sp/snapshots/#{snapshot_id}")
    end

    # Download requested snapshot
    #: (Numeric) -> untyped
    def download_snapshot(snapshot_id)
      get("/v2/sp/snapshots/#{snapshot_id}/download")
    end
  end
end
