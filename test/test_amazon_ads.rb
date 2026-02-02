# frozen_string_literal: true

require "test_helper"

class TestAmazonAds < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil(::AmazonAds::VERSION)
  end

  def test_configuration_returns_configuration_instance
    assert_kind_of(AmazonAds::Configuration, AmazonAds.configuration)
  end

  def test_configuration_is_memoized
    assert_same(AmazonAds.configuration, AmazonAds.configuration)
  end
end
