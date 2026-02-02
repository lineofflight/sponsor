# Amazon Ads

A Ruby client for the [Amazon Ads API](https://advertising.amazon.com/API/docs/en-us).

## Installation

Add to your Gemfile:

```ruby
gem "amazon-ads"
```

Or install directly:

```bash
gem install amazon-ads
```

## Configuration

Configure with your Amazon Ads API credentials:

```ruby
AmazonAds.configure do |config|
  config.client_id = "your_client_id"
  config.client_secret = "your_client_secret"
  config.refresh_token = "your_refresh_token"
  config.region = :na  # :na, :eu, or :fe
end
```

Or set environment variables:

- `AMAZON_ADS_CLIENT_ID`
- `AMAZON_ADS_CLIENT_SECRET`
- `AMAZON_ADS_REFRESH_TOKEN`

## Usage

```ruby
client = AmazonAds::Client.new

# List advertising profiles
profiles = client.profiles.list

# Switch to a specific profile
client = client.with_profile(profiles.first["profileId"])

# Use Sponsored Products API
client.sponsored_products.get_bid_recommendations(ad_group_id: "123")
```

## Development

```bash
bin/setup        # Install dependencies
rake test        # Run tests
rake rubocop     # Lint
rake steep       # Type check
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/lineofflight/amazon-ads-ruby).

## License

MIT
