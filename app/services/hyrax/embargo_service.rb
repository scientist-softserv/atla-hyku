# frozen_string_literal: true

# This code is copied from https://github.com/samvera/hyrax/pull/6241 to solve https://github.com/scientist-softserv/atla-hyku/issues/121
# The copied code has not been included in a release yet. At the time of this writing, September 26, 2023, it is in hyrax main. The latest release is `hyrax-v4.0.0`.
# This app is currently using hyrax-v3.5.0. However, since the changes being brought in are coming from hyrax main, I'm including the
# entire files instead of writing decorators.

module Hyrax
  ##
  # Methods for Querying Repository to find Embargoed Objects
  class EmbargoService < RestrictionService
    class << self
      # Returns all assets with embargo release date set to a date in the past
      def assets_with_expired_enforced_embargoes
        builder = Hyrax::ExpiredEmbargoSearchBuilder.new(self)
        presenters(builder)
      end
      alias assets_with_expired_embargoes assets_with_expired_enforced_embargoes

      ##
      # Returns all assets with embargoes that are currently enforced,
      # regardless of whether the embargoes are active or expired.
      #
      # @see Hyrax::EmbargoManager
      def assets_with_enforced_embargoes
        builder = Hyrax::EmbargoSearchBuilder.new(self)
        presenters(builder).select(&:enforced?)
      end
      alias assets_under_embargo assets_with_enforced_embargoes

      # Returns all assets that have had embargoes deactivated in the past.
      def assets_with_deactivated_embargoes
        builder = Hyrax::DeactivatedEmbargoSearchBuilder.new(self)
        presenters(builder)
      end

      def search_state_class
        nil
      end

      private

      def presenter_class
        Hyrax::EmbargoPresenter
      end
    end
  end
end