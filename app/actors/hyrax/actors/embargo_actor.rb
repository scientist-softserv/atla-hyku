# frozen_string_literal: true

# This code is copied from https://github.com/samvera/hyrax/pull/6241 to solve https://github.com/scientist-softserv/atla-hyku/issues/121
# The copied code has not been included in a release yet. At the time of this writing, September 26, 2023, it is in hyrax main. The latest release is `hyrax-v4.0.0`.
# This app is currently using hyrax-v3.5.0. However, since the changes being brought in are coming from hyrax main, I'm including the
# entire files instead of writing decorators.

module Hyrax
  module Actors
    class EmbargoActor
      attr_reader :work

      # @param [Hydra::Works::Work] work
      def initialize(work)
        @work = work
      end

      # Update the visibility of the work to match the correct state of the embargo, then clear the embargo date, etc.
      # Saves the embargo and the work
      def destroy
        case work
        when Valkyrie::Resource
          Hyrax::EmbargoManager.deactivate_embargo_for(resource: work) &&
            Hyrax.persister.save(resource: work.embargo) &&
            Hyrax::AccessControlList(work).save
        else
          work.embargo_visibility! # If the embargo has lapsed, update the current visibility.
          work.deactivate_embargo!
          work.embargo.save!
          work.save!
        end
      end
    end
  end
end
