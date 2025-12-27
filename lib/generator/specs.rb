# frozen_string_literal: true

require "http"
require "yaml"
require "fileutils"

module Generator
  # Downloads and caches OpenAPI specs from Amazon Ads
  module Specs
    SPECS = {
      profiles: "https://d3a0d0y2hgofx6.cloudfront.net/openapi/en-us/profiles/3-0/openapi.yaml",
      sponsored_products: "https://d3a0d0y2hgofx6.cloudfront.net/openapi/en-us/sponsored-products/2-0/openapi.yaml",
    }.freeze

    SPECS_DIR = File.expand_path("../../specs", __dir__)

    class << self
      def download_all
        FileUtils.mkdir_p(SPECS_DIR)

        SPECS.each do |name, url|
          download(name, url)
        end
      end

      def download(name, url)
        puts "Downloading #{name}..."
        response = HTTP.get(url)

        unless response.status.success?
          warn("Failed to download #{name}: #{response.status}")
          return
        end

        path = File.join(SPECS_DIR, "#{name}.yaml")
        File.write(path, response.body.to_s)
        puts "Saved #{path}"
      end

      def load(name)
        path = File.join(SPECS_DIR, "#{name}.yaml")
        YAML.load_file(path)
      end
    end
  end
end
