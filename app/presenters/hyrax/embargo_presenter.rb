# frozen_string_literal: true

# This code is copied from https://github.com/samvera/hyrax/pull/6241 to solve https://github.com/scientist-softserv/atla-hyku/issues/121
# The copied code has not been included in a release yet. At the time of this writing, September 26, 2023, it is in hyrax main. The latest release is `hyrax-v4.0.0`.
# This app is currently using hyrax-v3.5.0. However, since the changes being brought in are coming from hyrax main, I'm including the
# entire files instead of writing decorators.

module Hyrax
  # Presents embargoed objects
  class EmbargoPresenter
    include ModelProxy
    attr_accessor :solr_document

    delegate :human_readable_type, :visibility, :to_s, to: :solr_document

    # @param [SolrDocument] solr_document
    def initialize(solr_document)
      @solr_document = solr_document
    end

    def embargo_release_date
      solr_document.embargo_release_date.to_formatted_s(:rfc822)
    end

    def visibility_after_embargo
      solr_document.fetch('visibility_after_embargo_ssim', []).first
    end

    def embargo_history
      solr_document['embargo_history_ssim']
    end

    def enforced?
      solr_document.embargo_enforced?
    end
  end
end