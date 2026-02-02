# frozen_string_literal: true

require "erb"
require "yaml"
require "fileutils"

module Generator
  # Generates API classes from OpenAPI specs
  class API
    TEMPLATE_PATH = File.expand_path("templates/api.erb", __dir__)

    attr_reader :spec_name, :spec, :class_name

    def initialize(spec_name)
      @spec_name = spec_name
      @spec = YAML.load_file(File.expand_path("../../specs/#{spec_name}.yaml", __dir__))
      @class_name = spec_name.split("_").map(&:capitalize).join
    end

    def generate
      template = File.read(TEMPLATE_PATH)
      ERB.new(template, trim_mode: "-").result(binding)
    end

    def save
      output_dir = File.expand_path("../../lib/amazon_ads/apis", __dir__)
      FileUtils.mkdir_p(output_dir)

      path = File.join(output_dir, "#{spec_name}.rb")
      File.write(path, generate)
      puts("Generated #{path}")
    end

    private

    def operations
      spec["paths"].flat_map do |path, methods|
        methods.filter_map do |http_method, details|
          next unless ["get", "post", "put", "patch", "delete"].include?(http_method)

          build_operation(path, http_method, details)
        end
      end
    end

    def build_operation(path, http_method, details)
      params = extract_params(details)
      path_params = params.select { |p| p[:in] == "path" }
      query_params = params.select { |p| p[:in] == "query" }
      has_body = ["post", "put", "patch"].include?(http_method) && details["requestBody"]

      {
        method_name: to_method_name(details["operationId"]),
        http_method: http_method,
        path: interpolate_path(path),
        summary: details["summary"]&.gsub("\n", " "),
        params: build_params(path_params, query_params, has_body),
        signature: build_signature(path_params, query_params, has_body),
        args: build_args(query_params, has_body),
      }
    end

    def extract_params(details)
      (details["parameters"] || []).filter_map do |param|
        param = resolve_ref(param["$ref"]) if param["$ref"]
        next unless param&.dig("name")
        next if param["in"] == "header"

        {
          name: to_snake_case(param["name"]),
          original_name: param["name"],
          in: param["in"],
          required: param["required"] || false,
          type: param.dig("schema", "type") || "string",
        }
      end
    end

    def resolve_ref(ref)
      return unless ref

      parts = ref.delete_prefix("#/").split("/")
      parts.reduce(spec) { |obj, key| obj&.dig(key) }
    end

    def to_method_name(operation_id)
      to_snake_case(operation_id)
    end

    def to_snake_case(str)
      str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .downcase
    end

    def interpolate_path(path)
      path.gsub(/\{(\w+)\}/) { '#{' + to_snake_case(::Regexp.last_match(1)) + "}" }
    end

    def build_params(path_params, query_params, has_body)
      parts = []
      path_params.each { |p| parts << p[:name] }
      query_params.each { |p| parts << "#{p[:name]}: nil" }
      parts << "body: {}" if has_body
      parts.join(", ")
    end

    def build_signature(path_params, query_params, has_body)
      parts = []
      path_params.each { |p| parts << ruby_type(p[:type]) }
      query_params.each { |p| parts << "?#{p[:name]}: #{ruby_type(p[:type])}?" }
      parts << "?body: Hash[String, untyped]" if has_body
      parts.join(", ")
    end

    def build_args(query_params, has_body)
      args = []
      if query_params.any?
        params_hash = query_params.map { |p| "\"#{p[:original_name]}\" => #{p[:name]}" }.join(", ")
        args << "params: { #{params_hash} }.compact"
      end
      args << "body: body" if has_body
      args.empty? ? "" : ", #{args.join(", ")}"
    end

    def ruby_type(openapi_type)
      case openapi_type
      when "integer" then "Integer"
      when "number" then "Numeric"
      when "boolean" then "bool"
      else "String"
      end
    end
  end
end
