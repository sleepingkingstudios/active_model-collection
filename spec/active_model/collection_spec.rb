# spec/active_model/collection_spec.rb

require 'active_model/collection/spec_helper'

require 'active_model/collection'

RSpec.describe ActiveModel::Collection do
  shared_context 'with a defined model' do
    let(:model) do
      Class.new do
        include ActiveModel::Model
        include ActiveModel::Validations

        class << self
          attr_accessor :count
        end # class << self
        
        self.count = 0

        attr_accessor :integer_field, :string_field

        def save(*args)
          opts = args.extract_options!

          if !opts.fetch(:validate, true) || valid?
            self.class.count += 1
            true
          else
            false
          end
        end # method save
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

    let(:params) do
      [*0..2].map { |index| { integer_field: index, string_field: "Title #{index}" } }
    end # let
  end # shared context

  let(:params)   { [] }
  let(:instance) { described_class.new *params }

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

  describe '#initialize' do
    describe 'with an array of params hashes' do
      include_context 'with a defined model and collection'
 
      let(:params) do
        [*0..2].map { |index| { integer_field: index, string_field: "Title #{index}" } }
      end # let
      let(:instance) { described_class.new *params }
 
      it 'creates instances of the model with the specified parameters' do
        expect(instance.to_a).to have(3).items
        instance.to_a.each.with_index do |item, index|
          expect(item).to be_a(model)
          expect(item.integer_field).to be == params[index][:integer_field]
          expect(item.string_field).to be  == params[index][:string_field]
        end # each
      end # it
    end # describe
  end # describe

  describe '#build' do
    it { expect(instance).to respond_to(:build).with(1).arguments }
 
    describe 'with a defined model and collection' do
      include_context 'with a defined model and collection'
 
      let(:params) do
        [*0..2].map { |index| { integer_field: index, string_field: "Title #{index}" } }
      end # let
 
      it 'creates instances of the model with the specified parameters' do
        expect { instance.build *params }.to change(instance, :to_a).to(have(3).items)
        instance.to_a.each.with_index do |item, index|
          expect(item).to be_a(model)
          expect(item.integer_field).to be == params[index][:integer_field]
          expect(item.string_field).to be  == params[index][:string_field]
        end # each
      end # it
    end # describe
  end # describe

  describe '#count' do
    it { expect(instance).to respond_to(:count).with(0).arguments }

    context 'with created records' do
      include_context 'with created records'

      it { expect(instance.count).to be == params.count }
    end # context
  end # describe

  describe '#each' do
    it { expect(instance).to respond_to(:each).with_a_block }
  end # describe

  describe '#save' do
    it { expect(instance).to respond_to(:save).with(0).arguments }
    it { expect(instance).to respond_to(:save).with(1).arguments }
 
    describe 'with no records' do
      it 'returns false' do
        expect(instance.save).to be false
      end # it
    end # describe
 
    describe 'with invalid records' do
      include_context 'with a defined model and collection'
 
      let(:params) do
        [*0..2].map { |index| { integer_field: index, string_field: "Title #{index}" } }
      end # let
      let(:instance) { described_class.new *params }
 
      before(:each) do
        allow_any_instance_of(model).to receive(:valid?).and_return(false)
      end # before each
 
      it 'returns false' do
        expect(instance.save).to be false
      end # it
 
      it 'does not create the records' do
        expect { instance.save }.not_to change(model, :count)
      end # it
 
      describe 'with validate: false' do
        it 'returns true' do
          expect(instance.save validate: false).to be true
        end # it
 
        it 'creates the records' do
          expect { instance.save validate: false }.to change(model, :count).by(params.count)
        end # it
      end # describe
    end # describe
 
    describe 'with a mix of valid and invalid records' do
      include_context 'with a defined model and collection'
 
      let(:params) do
        [*0..2].map { |index| { integer_field: index, string_field: "Title #{index}" } }
      end # it
      let(:instance) { described_class.new *params }
 
      before(:each) do
        allow_any_instance_of(model).to receive(:valid?) do |record|
          record.integer_field.even?
        end # allow
      end # before each
 
      it 'does not raise an error' do
        expect { instance.save }.not_to raise_error
      end # it
 
      it 'returns false' do
        expect(instance.save).to be false
      end # it
 
      it 'does not create the records' do
        expect { instance.save }.not_to change(model, :count)
      end # it
 
      describe 'with validate: false' do
        it 'does not raise an error' do
          expect { instance.save validate: false }.not_to raise_error
        end # it
 
        it 'returns true' do
          expect(instance.save validate: false).to be true
        end # it
 
        it 'creates the records' do
          expect { instance.save validate: false }.to change(model, :count).by(params.count)
        end # it
      end # describe
    end # describe
 
    describe 'with valid records' do
      include_context 'with a defined model and collection'
 
      let(:params) do
        [*0..2].map { |index| { integer_field: index, string_field: "Title #{index}" } }
      end # let
      let(:instance) { described_class.new *params }
 
      it 'does not raise an error' do
        expect { instance.save }.not_to raise_error
      end # it
 
      it 'returns true' do
        expect(instance.save).to be true
      end # it
 
      it 'creates the records' do
        expect { instance.save }.to change(model, :count).by(params.count)
      end # it
    end # describe
  end # describe

  describe '#to_a' do
    it { expect(instance).to respond_to(:to_a).with(0).arguments }
 
    it { expect(instance.to_a).to be == [] }

    context 'with created records' do
      include_context 'with created records'

      it { expect(instance.to_a).to be_a(Array) & have(params.count).items }

      it 'creates a duplicate of the array' do
        expect { instance.to_a.pop }.not_to change(instance, :count)
      end # it
    end # context
  end # describe

  describe '#valid?' do
    it { expect(instance).to respond_to(:valid?).with(0).arguments }
  end # describe

  describe 'validation' do
    it { expect(instance.valid?).to be false }
 
    it { expect(instance.tap(&:valid?).errors).to have_key(:records) }
    it { expect(instance.tap(&:valid?).errors[:records]).to include("can't be blank") }
 
    context 'with created records' do
      include_context 'with created records'
 
      it { expect(instance.valid?).to be true }
    end # context
 
    context 'with invalid records' do
      include_context 'with created records'
 
      before(:each) { instance.each { |record| allow(record).to receive(:valid?).and_return(false) } }
 
      it { expect(instance.valid?).to be false }
    end # context
  end # contxt
end # describe
