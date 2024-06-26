# frozen_string_literal: true

# Generated via
# `rails generate hyrax:work Image`

RSpec.describe Hyrax::ImageForm do
  let(:work) { Image.new }
  let(:form) { described_class.new(work, nil, nil) }
  let(:file_set) { FactoryBot.create(:file_set) }

  describe ".model_attributes" do
    subject { described_class.model_attributes(params) }

    let(:params) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        title: ['foo'],
        extent: ['extent'],
        location: ['San Diego, CA']
      }
    end

    it 'permits parameters' do
      expect(subject['extent']).to eq ['extent']
      expect(subject['location']).to eq ['San Diego, CA']
    end
  end
end
