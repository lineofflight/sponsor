# frozen_string_literal: true

require "test_helper"

class TestConfiguration < Minitest::Test
  def setup
    AmazonAds.reset_configuration!
  end

  def test_default_region_is_na
    assert_equal(:na, AmazonAds.configuration.region)
  end

  def test_configure_block
    AmazonAds.configure do |config|
      config.region = :eu
      config.client_id = "my_client_id"
      config.client_secret = "my_client_secret"
      config.refresh_token = "my_refresh_token"
      config.profile_id = "123456789"
    end

    assert_equal(:eu, AmazonAds.configuration.region)
    assert_equal("my_client_id", AmazonAds.configuration.client_id)
    assert_equal("my_client_secret", AmazonAds.configuration.client_secret)
    assert_equal("my_refresh_token", AmazonAds.configuration.refresh_token)
    assert_equal("123456789", AmazonAds.configuration.profile_id)
  end

  def test_reset_configuration
    AmazonAds.configure do |config|
      config.region = :eu
    end

    AmazonAds.reset_configuration!

    assert_equal(:na, AmazonAds.configuration.region)
  end

  def test_lwa_builds_instance_from_config
    AmazonAds.configure do |config|
      config.client_id = "my_client_id"
      config.client_secret = "my_client_secret"
      config.refresh_token = "my_refresh_token"
    end

    lwa = AmazonAds.configuration.lwa

    assert_kind_of(AmazonAds::LWA, lwa)
    assert_equal("my_client_id", lwa.client_id)
    assert_equal("my_client_secret", lwa.client_secret)
    assert_equal("my_refresh_token", lwa.refresh_token)
  end

  def test_lwa_raises_without_required_config
    AmazonAds.configure do |config|
      config.client_id = nil
    end

    assert_raises(ArgumentError) do
      AmazonAds.configuration.lwa
    end
  end
end
