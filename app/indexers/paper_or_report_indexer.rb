# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work PaperOrReport`
class PaperOrReportIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['format_sim'] = object.format.first if object.format.present?
      solr_doc['date_created_sim'] = object.date_created if object.date_created.present?
      solr_doc['funder_name_sim']  = object.funder_name.first if object.funder_name.present?
      solr_doc['event_title_sim']  = object.event_title.first if object.event_title.present?
      solr_doc['event_date_sim'] = object.event_date.first if object.event_date.present?
    end
  end
end