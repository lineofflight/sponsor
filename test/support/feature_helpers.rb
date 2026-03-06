# frozen_string_literal: true

require_relative "recordable"

module FeatureHelpers
  include Recordable

  def setup
    super

    class_name = self.class.name.delete_prefix("Test")
    @api = AmazonAds.const_get(class_name).new(**api_options)
  end

  private

  def api_options
    @api_options ||= {
      region: ENV.fetch("AMAZON_ADS_TEST_REGION", "na"),
      profile_id: ENV["AMAZON_ADS_TEST_PROFILE_ID"],
      access_token: access_token,
    }
  end

  def access_token
    data = AmazonAds::LWA.request(
      refresh_token: ENV.fetch("AMAZON_ADS_TEST_REFRESH_TOKEN", "dummy"),
    )

    data.fetch("access_token")
  end
end
