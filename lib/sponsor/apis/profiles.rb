# frozen_string_literal: true

# rbs_inline: enabled

module Sponsor
  # Amazon Ads API - Profiles
  #
  # @see https://amzn-clicks.atlassian.net/servicedesk/customer/portals
  class Profiles < API
    # Gets a list of profiles.
    #: (?api_program: String?, ?access_level: String?, ?profile_type_filter: String?, ?valid_payment_method_filter: String?) -> HTTP::Response
    def list_profiles(api_program: nil, access_level: nil, profile_type_filter: nil, valid_payment_method_filter: nil)
      get("/v2/profiles", params: { "apiProgram" => api_program, "accessLevel" => access_level, "profileTypeFilter" => profile_type_filter, "validPaymentMethodFilter" => valid_payment_method_filter }.compact)
    end

    # Update the daily budget for one or more profiles.
    #: (?body: Hash[String, untyped]) -> HTTP::Response
    def update_profiles(body: {})
      put("/v2/profiles", body: body)
    end

    # Gets a profile specified by identifier.
    #: (Integer) -> HTTP::Response
    def get_profile_by_id(profile_id)
      get("/v2/profiles/#{profile_id}")
    end
  end
end
