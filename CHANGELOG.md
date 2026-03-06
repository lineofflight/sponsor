## [Unreleased]

## [0.2.0] - 2026-03-06

- Rewrite core: stateless API classes take access_token directly
- Remove Configuration and Client classes
- Generate 20+ API classes from OpenAPI specs
- Fix generator handling of $ref body parameters
- Add VCR-based integration tests
- Add client_id/client_secret with ENV fallback on AmazonAds module

## [0.1.0] - 2025-12-27

- Initial release
- LWA authentication with automatic token refresh
- HTTP client with retry and rate limit handling
- Profiles API
- Sponsored Products API
- OpenAPI-based code generator
- RBS type signatures

[Unreleased]: https://github.com/lineofflight/amazon-ads-ruby/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/lineofflight/amazon-ads-ruby/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/lineofflight/amazon-ads-ruby/releases/tag/v0.1.0
