# Amazon Ads Ruby SDK

## Commands
- Test: `bundle exec rake test`
- Lint: `bundle exec rake rubocop`
- Type check: `bundle exec rake steep`
- All checks: `bundle exec rake`
- Generate rbs: `bundle exec rake rbs`

## Style
- Inline RBS
- git: 50/72
- No emojis, em dashes

## Design
- All files in `lib/amazon_ads/apis/` are auto-generated; never hand-edit them
- Stateless LWA: each call to `LWA#request` hits the token endpoint; the caller owns token caching
- API classes take `access_token` directly; no in-process token management

## References
- API overview: https://advertising.amazon.com/API/docs/en-us/reference/api-overview
- SDK generation guide: https://advertising.amazon.com/API/docs/en-us/guides/get-started/generate-sdk
- v1 merged spec: https://d1y2lf8k3vrkfu.cloudfront.net/openapi/en-us/dest/AmazonAdsAPIALLMerged_prod_3p.json
- Profiles spec: https://d3a0d0y2hgofx6.cloudfront.net/openapi/en-us/profiles/3-0/openapi.yaml
- Reporting spec: https://d1y2lf8k3vrkfu.cloudfront.net/openapi/en-us/dest/OfflineReport_prod_3p.json
- Marketing Stream spec: https://dtrnk0o2zy01c.cloudfront.net/openapi/en-us/dest/AmazonMarketingStream_prod_3p.json
