# frozen_string_literal: true

require "test_helper"

class TestAPI < Minitest::Test
  def setup
    ENV["AMAZON_ADS_CLIENT_ID"] = "test_client_id"
    @endpoint = "https://advertising-api.amazon.com"
  end

  def test_requires_access_token_or_lwa
    error = assert_raises(ArgumentError) do
      AmazonAds::Profiles.new(region: :na)
    end

    assert_equal("Either access_token or lwa must be provided", error.message)
  end

  def test_accepts_access_token
    api = AmazonAds::Profiles.new(region: :na, access_token: "test_token")
    assert_equal(:na, api.region)
  end

  def test_accepts_lwa_instance
    lwa = AmazonAds::LWA.new(
      client_id: "id",
      client_secret: "secret",
      refresh_token: "refresh",
    )
    stub_request(:post, AmazonAds::LWA::URL)
      .to_return(
        status: 200,
        body: { access_token: "lwa_token", expires_in: 3600 }.to_json,
        headers: { "Content-Type" => "application/json" },
      )

    api = AmazonAds::Profiles.new(region: :na, lwa: lwa)

    stub_request(:get, "#{@endpoint}/v2/profiles")
      .with(headers: { "Authorization" => "Bearer lwa_token" })
      .to_return(
        status: 200,
        body: [].to_json,
        headers: { "Content-Type" => "application/json" },
      )

    api.list_profiles
    assert_requested(:get, "#{@endpoint}/v2/profiles")
  end

  def test_returns_parsed_response
    stub_request(:get, "#{@endpoint}/v2/profiles")
      .to_return(
        status: 200,
        body: [{ profileId: 123, countryCode: "US" }].to_json,
        headers: { "Content-Type" => "application/json" },
      )

    api = AmazonAds::Profiles.new(region: :na, access_token: "test_token")
    result = api.list_profiles

    assert_kind_of(Array, result)
    assert_equal(123, result.first["profileId"])
  end

  def test_raises_authentication_error_on_401
    stub_request(:get, "#{@endpoint}/v2/profiles")
      .to_return(status: 401, body: "{}", headers: { "Content-Type" => "application/json" })

    api = AmazonAds::Profiles.new(region: :na, access_token: "test_token")

    error = assert_raises(AmazonAds::AuthenticationError) do
      api.list_profiles
    end

    assert_equal("Unauthorized", error.message)
    refute_nil(error.response)
  end

  def test_raises_not_found_error_on_404
    stub_request(:get, "#{@endpoint}/v2/profiles/999")
      .to_return(status: 404, body: "{}", headers: { "Content-Type" => "application/json" })

    api = AmazonAds::Profiles.new(region: :na, access_token: "test_token")

    assert_raises(AmazonAds::NotFoundError) do
      api.get_profile_by_id(999)
    end
  end

  def test_raises_bad_request_error_on_400
    stub_request(:get, "#{@endpoint}/v2/profiles")
      .to_return(status: 400, body: "{}", headers: { "Content-Type" => "application/json" })

    api = AmazonAds::Profiles.new(region: :na, access_token: "test_token")

    assert_raises(AmazonAds::BadRequestError) do
      api.list_profiles
    end
  end

  def test_raises_server_error_on_500
    stub_request(:get, "#{@endpoint}/v2/profiles")
      .to_return(status: 500, body: "{}", headers: { "Content-Type" => "application/json" })

    api = AmazonAds::Profiles.new(region: :na, access_token: "test_token")

    assert_raises(AmazonAds::ServerError) do
      api.list_profiles
    end
  end

  def test_retries_on_rate_limit
    stub_request(:get, "#{@endpoint}/v2/profiles")
      .to_return(status: 429, body: "{}", headers: { "Content-Type" => "application/json", "Retry-After" => "0" })
      .then
      .to_return(
        status: 200,
        body: [].to_json,
        headers: { "Content-Type" => "application/json" },
      )

    api = AmazonAds::Profiles.new(region: :na, access_token: "test_token")
    result = api.list_profiles

    assert_kind_of(Array, result)
    assert_requested(:get, "#{@endpoint}/v2/profiles", times: 2)
  end

  def test_raises_rate_limit_error_after_max_retries
    stub_request(:get, "#{@endpoint}/v2/profiles")
      .to_return(status: 429, body: "{}", headers: { "Content-Type" => "application/json", "Retry-After" => "0" })

    api = AmazonAds::Profiles.new(region: :na, access_token: "test_token")

    error = assert_raises(AmazonAds::RateLimitError) do
      api.list_profiles
    end

    assert_equal("Rate limited", error.message)
    assert_requested(:get, "#{@endpoint}/v2/profiles", times: 4) # 1 initial + 3 retries
  end

  def test_supports_different_regions
    assert_equal(:na, AmazonAds::Profiles.new(region: :na, access_token: "t").region)
    assert_equal(:eu, AmazonAds::Profiles.new(region: :eu, access_token: "t").region)
    assert_equal(:fe, AmazonAds::Profiles.new(region: :fe, access_token: "t").region)
  end

  def test_raises_on_unknown_region
    stub_request(:get, /advertising-api/)
      .to_return(status: 200, body: "{}", headers: { "Content-Type" => "application/json" })

    api = AmazonAds::Profiles.new(region: :invalid, access_token: "test_token")

    assert_raises(ArgumentError) do
      api.list_profiles
    end
  end

  def test_includes_profile_id_header_when_set
    stub_request(:get, "#{@endpoint}/v2/profiles")
      .with(headers: { "Amazon-Advertising-API-Scope" => "123456789" })
      .to_return(
        status: 200,
        body: [].to_json,
        headers: { "Content-Type" => "application/json" },
      )

    api = AmazonAds::Profiles.new(region: :na, access_token: "test_token", profile_id: "123456789")
    api.list_profiles

    assert_requested(:get, "#{@endpoint}/v2/profiles")
  end
end
