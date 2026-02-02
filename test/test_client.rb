# frozen_string_literal: true

require "test_helper"

class TestClient < Minitest::Test
  def setup
    AmazonAds.reset_configuration!
    AmazonAds.configure do |config|
      config.client_id = "test_client_id"
      config.client_secret = "test_client_secret"
      config.refresh_token = "test_refresh_token"
      config.region = :na
    end
    ENV["AMAZON_ADS_CLIENT_ID"] = "test_client_id"

    stub_request(:post, AmazonAds::LWA::URL)
      .to_return(
        status: 200,
        body: { access_token: "test_token", expires_in: 3600 }.to_json,
        headers: { "Content-Type" => "application/json" },
      )
  end

  def test_creates_client_from_configuration
    client = AmazonAds::Client.new

    assert_equal(:na, client.region)
    assert_kind_of(AmazonAds::LWA, client.lwa)
  end

  def test_client_with_custom_lwa
    lwa = AmazonAds::LWA.new(
      client_id: "custom_id",
      client_secret: "custom_secret",
      refresh_token: "custom_refresh",
    )

    client = AmazonAds::Client.new(lwa: lwa)

    assert_equal(lwa, client.lwa)
  end

  def test_profiles_returns_profiles_api
    client = AmazonAds::Client.new

    assert_kind_of(AmazonAds::Profiles, client.profiles)
  end

  def test_sponsored_products_returns_sponsored_products_api
    client = AmazonAds::Client.new

    assert_kind_of(AmazonAds::SponsoredProducts, client.sponsored_products)
  end

  def test_apis_are_memoized
    client = AmazonAds::Client.new

    assert_same(client.profiles, client.profiles)
    assert_same(client.sponsored_products, client.sponsored_products)
  end

  def test_with_profile_creates_new_client
    client = AmazonAds::Client.new
    profile_client = client.with_profile("123456789")

    refute_same(client, profile_client)
    assert_nil(client.profile_id)
    assert_equal("123456789", profile_client.profile_id)
    assert_same(client.lwa, profile_client.lwa)
  end

  def test_client_apis_share_lwa
    client = AmazonAds::Client.new

    stub_request(:get, "https://advertising-api.amazon.com/v2/profiles")
      .to_return(
        status: 200,
        body: [].to_json,
        headers: { "Content-Type" => "application/json" },
      )

    client.profiles.list_profiles

    # Only one LWA request should be made even across different API instances
    assert_requested(:post, AmazonAds::LWA::URL, times: 1)
  end
end
