# frozen_string_literal: true

RSpec.describe Hyrax::GenericWorkForm do
  let(:work) { GenericWork.new }
  let(:form) { described_class.new(work, nil, nil) }
  let(:file_set) { FactoryBot.create(:file_set) }

  describe '.model_attributes' do
    subject { described_class.model_attributes(params) }

    let(:params) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        title: ['foo'],
        rendering_ids: [file_set.id],
        location: ['San Diego, CA']
      }
    end

    it 'permits parameters' do
      expect(subject['rendering_ids']).to eq [file_set.id]
      expect(subject['location']).to eq ['San Diego, CA']
    end
  end

  include_examples('generic_work_form')
end
