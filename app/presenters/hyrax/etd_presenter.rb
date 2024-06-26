# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdPresenter < Hyku::WorkShowPresenter
    delegate :additional_rights_info,
             :bibliographic_citation,
             :institution,
             :format,
             :degree,
             #:level,
             :discipline,
             :degree_granting_institution,
             :advisor,
             :committee_member,
             :types,
             :department,
             :location,
             :year, to: :solr_document
  end
end
