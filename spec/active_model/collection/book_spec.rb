# spec/active_model/collection/book_spec.rb

require 'active_model/collection/spec_helper'

require 'active_model/collection'

if defined?(Book)
  RSpec.describe 'BookCollection' do
    shared_context 'with a defined model' do
      let(:model) { Book }
    end # shared context

    shared_context 'with a defined collection' do
      let(:described_class) { Class.new(ActiveModel::Collection) }
    end # shared context

    shared_context 'with a defined model and collection' do
      include_context 'with a defined model'
      include_context 'with a defined collection'
   
      before(:each) { described_class.model = model }
    end # shared context

    shared_context 'with created records' do
      include_context 'with a defined model and collection'

      let(:params) { valid_params }
    end # shared context

    let(:valid_params) do
      [*0..2].map { |index| { isbn: 1000 + index, synopsis: "Synopsis #{index}" } }
    end # let

    let(:invalid_params) do
      [*0..2].map { |index| { synopsis: "Synopsis #{index}" } }
    end # let

    let(:mixed_params) do
      [*0..2].map { |index| { isbn: index.odd? ? 1000 + index : nil, synopsis: "Synopsis #{index}" } }
    end # it

    let(:described_class) { ActiveModel::Collection }

    it_behaves_like ActiveModel::Collection

    it_behaves_like 'MockController'
  end
end
