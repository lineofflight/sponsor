# frozen_string_literal: true

require "test_helper"

class TestErrors < Minitest::Test
  def test_error_inherits_from_standard_error
    assert(AmazonAds::Error < StandardError)
  end

  def test_error_stores_response
    response = Object.new
    error = AmazonAds::Error.new("message", response: response)

    assert_equal("message", error.message)
    assert_equal(response, error.response)
  end

  def test_authentication_error_inherits_from_error
    assert(AmazonAds::AuthenticationError < AmazonAds::Error)
  end

  def test_rate_limit_error_stores_retry_after
    error = AmazonAds::RateLimitError.new("rate limited", retry_after: 30)

    assert_equal(30, error.retry_after)
  end

  def test_not_found_error_inherits_from_error
    assert(AmazonAds::NotFoundError < AmazonAds::Error)
  end

  def test_bad_request_error_inherits_from_error
    assert(AmazonAds::BadRequestError < AmazonAds::Error)
  end

  def test_server_error_inherits_from_error
    assert(AmazonAds::ServerError < AmazonAds::Error)
  end
end
