# frozen_string_literal: true

# This code is copied from https://github.com/samvera/hyrax/pull/6241 to solve https://github.com/scientist-softserv/atla-hyku/issues/121
# The copied code has not been included in a release yet. At the time of this writing, September 26, 2023, it is in hyrax main. The latest release is `hyrax-v4.0.0`.
# This app is currently using hyrax-v3.5.0. However, since the changes being brought in are coming from hyrax main, I'm including the
# entire files instead of writing decorators.

namespace :hyrax do
  namespace :embargo do
    desc 'Deactivate embargoes for which the lift date has past'
    task deactivate_expired: :environment do
      ids = Hyrax::EmbargoService.assets_with_expired_embargoes.map(&:id)

      Hyrax.query_service.find_many_by_ids(ids: ids).each do |resource|
        Hyrax::EmbargoManager.release_embargo_for(resource: resource) &&
          Hyrax.persister.save(resource: resource.embargo) &&
          Hyrax::AccessControlList(resource).save
      end
    end
  end

  namespace :lease do
    desc 'Deactivate leases for which the expiration date has past'
    task deactivate_expired: :environment do
      ids = Hyrax::LeaseService.assets_with_expired_leases.map(&:id)

      Hyrax.query_service.find_many_by_ids(ids: ids).each do |resource|
        Hyrax::LeaseManager.release_lease_for(resource: resource) &&
          Hyrax::AccessControlList(resource).save
      end
    end
  end
end
