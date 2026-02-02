# frozen_string_literal: true

require "test_helper"

class TestLWA < Minitest::Test
  def setup
    @lwa = AmazonAds::LWA.new(
      client_id: "test_client_id",
      client_secret: "test_client_secret",
      refresh_token: "test_refresh_token",
    )
  end

  def test_access_token_fetches_and_caches_token
    stub_request(:post, AmazonAds::LWA::URL)
      .to_return(
        status: 200,
        body: { access_token: "test_access_token", expires_in: 3600 }.to_json,
        headers: { "Content-Type" => "application/json" },
      )

    # First call fetches token
    token = @lwa.access_token
    assert_equal("test_access_token", token)

    # Second call returns cached token (no new request)
    token = @lwa.access_token
    assert_equal("test_access_token", token)

    assert_requested(:post, AmazonAds::LWA::URL, times: 1)
  end

  def test_access_token_refreshes_when_expired
    stub_request(:post, AmazonAds::LWA::URL)
      .to_return(
        status: 200,
        body: { access_token: "token_1", expires_in: 60 }.to_json,
        headers: { "Content-Type" => "application/json" },
      ).then
      .to_return(
        status: 200,
        body: { access_token: "token_2", expires_in: 3600 }.to_json,
        headers: { "Content-Type" => "application/json" },
      )

    # First call fetches token
    token = @lwa.access_token
    assert_equal("token_1", token)

    # Simulate token expiry
    @lwa.instance_variable_set(:@expires_at, Time.now - 1)

    # Second call refreshes token
    token = @lwa.access_token
    assert_equal("token_2", token)

    assert_requested(:post, AmazonAds::LWA::URL, times: 2)
  end

  def test_raises_authentication_error_on_failure
    stub_request(:post, AmazonAds::LWA::URL)
      .to_return(
        status: 401,
        body: { error: "invalid_grant", error_description: "Invalid refresh token" }.to_json,
        headers: { "Content-Type" => "application/json" },
      )

    error = assert_raises(AmazonAds::AuthenticationError) do
      @lwa.access_token
    end

    assert_equal("Invalid refresh token", error.message)
    refute_nil(error.response)
  end

  def test_token_expired_returns_true_when_no_token
    assert(@lwa.token_expired?)
  end

  def test_refresh_sends_correct_parameters
    stub_request(:post, AmazonAds::LWA::URL)
      .with(body: {
        grant_type: "refresh_token",
        client_id: "test_client_id",
        client_secret: "test_client_secret",
        refresh_token: "test_refresh_token",
      })
      .to_return(
        status: 200,
        body: { access_token: "test_access_token", expires_in: 3600 }.to_json,
        headers: { "Content-Type" => "application/json" },
      )

    @lwa.refresh!

    assert_requested(:post, AmazonAds::LWA::URL)
  end
end
