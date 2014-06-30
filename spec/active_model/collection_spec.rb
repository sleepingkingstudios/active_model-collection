# spec/active_model/collection_spec.rb

require 'active_model/collection/spec_helper'

require 'active_model/collection'

RSpec.describe ActiveModel::Collection do
  shared_context 'with a defined model' do
    let(:model) do
      Class.new(ReferenceModel) do
        attr_accessor :integer_field, :string_field

        validates :integer_field, :presence => true
      end # class
    end # let
 
    before(:each) do
      Object.const_set :GenericModel, model
    end # before each
 
    after(:each) do
      Object.send :remove_const, :GenericModel
    end # after each
  end # shared context

  shared_context 'with a defined collection' do
    let(:described_class) { Class.new(super()) }
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
    [*0..2].map { |index| { integer_field: index, string_field: "Title #{index}" } }
  end # let

  let(:invalid_params) do
    [*0..2].map { |index| { string_field: "Title #{index}" } }
  end # let

  let(:mixed_params) do
    [*0..2].map { |index| { integer_field: index.odd? ? index : nil, string_field: "Title #{index}" } }
  end # it

  it_behaves_like ActiveModel::Collection

  describe '::model' do
    it { expect(described_class).to respond_to(:model).with(0).arguments }
 
    it { expect(described_class.model).to be nil }
  end # describe

  describe '::model=' do
    after(:each) do
      if described_class.instance_variable_defined? :@model
        described_class.send :remove_instance_variable, :@model
      end # if
    end # after each
 
    it { expect(described_class).to respond_to(:model=).with(1).arguments }
 
    describe 'with nil' do
      it 'raises an error' do
        expect { described_class.model = nil }.to raise_error ArgumentError
      end # it
    end # describe
 
    describe 'with a class name that does not correspond to a class' do
      it 'raises an error' do
        expect { described_class.model = 'GenericClass' }.to raise_error NameError
      end # it
    end # describe
 
    describe 'with a class name as a String' do
      include_context 'with a defined model'
 
      it 'does not raise an error' do
        expect { described_class.model = 'GenericModel' }.not_to raise_error
      end # it
 
      it 'sets the model' do
        expect { described_class.model = 'GenericModel' }.to change(described_class, :model).to(model)
      end # it
    end # describe
 
    describe 'with a model class' do
      include_context 'with a defined model'
 
      it 'does not raise an error' do
        expect { described_class.model = model }.not_to raise_error
      end # it
 
      it 'sets the model' do
        expect { described_class.model = 'GenericModel' }.to change(described_class, :model).to(model)
      end # it
    end # describe
 
    describe 'with a model already set' do
      include_context 'with a defined model'
 
      before(:each) { described_class.model = model }
 
      it 'raises an error' do
        expect { described_class.model = model }.to raise_error StandardError
      end # it
    end # describe
 
    context 'as a subclass' do
      include_context 'with a defined collection'
 
      describe 'with a model class' do
        include_context 'with a defined model'
 
        it 'sets the model' do
          expect { described_class.model = 'GenericModel' }.to change(described_class, :model).to(model)
        end # it
 
        it 'does not change the model on the base class' do
          expect { described_class.model = 'GenericModel' }.not_to change(ActiveModel::Collection, :model)
        end # it
      end # describe
    end # context
  end # describe
end # describe
