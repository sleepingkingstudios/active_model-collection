# spec/active_model/collection/blog_post_spec.rb

require 'active_model/collection/spec_helper'

require 'active_model/collection'

if defined?(BlogPost)
  RSpec.describe BlogPost do
    shared_context 'with a defined model' do
      let(:model) { BlogPost }
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

      let(:params) { valid_params_for_create }
    end # shared context

    let(:invalid_key) { BSON::ObjectId.new }

    let(:valid_params_for_create) do
      [*0..2].map { |index| { index: index, title: "#{index} Blog Facts That Will Shock You!" } }
    end # let

    let(:invalid_params_for_create) do
      [*0..2].map { |index| { title: "#{index} Blog Facts That Will Shock You!" } }
    end # let

    let(:mixed_params_for_create) do
      [*0..2].map { |index| { index: index.odd? ? index : nil, title: "#{index} Blog Facts That Will Shock You!" } }
    end # it

    let(:valid_params_for_update) do
      [*0..2].map { |index| { index: 100 + index } }
    end # let

    let(:invalid_params_for_update) do
      [*0..2].map { |index| { index: nil } }
    end # let

    let(:mixed_params_for_update) do
      [*0..2].map { |index| { index: index.odd? ? 100 + index : nil } }
    end # let

    let(:described_class) { ActiveModel::Collection }

    it_behaves_like ActiveModel::Collection

    it_behaves_like 'MockController'
  end # describe
end # if
