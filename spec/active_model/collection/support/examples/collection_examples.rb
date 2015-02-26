# spec/active_model/collection/support/examples/collection_examples.rb

RSpec.shared_examples ActiveModel::Collection do
  let(:params)   { [] }
  let(:instance) { described_class.new params }

  describe '::create' do
    include_context 'with a defined model and collection'

    let(:collection) { described_class.create params }

    it { expect(described_class).to respond_to(:create).with(1).arguments }

    describe 'with a non-enumerable object' do
      let(:params) { Object.new }

      it 'raises an error' do
        expect { described_class.create! params }.to raise_error ArgumentError
      end # it
    end # describe

    describe 'with an array of valid params hashes' do
      let(:params) { valid_params_for_create }

      it 'creates an instance of the collection with created model objects' do
        expect(collection).to be_a(described_class) & have(params.count).items
      end # it

      it 'saves the created model objects' do
        expect { described_class.create params }.to change(model, :count).by(params.count)
      end # it
    end # describe

    describe 'with an array of invalid params hashes' do
      let(:params) { invalid_params_for_create }

      it 'creates an instance of the collection with created model objects' do
        expect(collection).to be_a(described_class) & have(params.count).items
      end # it

      it 'does not save the created model objects' do
        expect { described_class.create params }.not_to change(model, :count)
      end # it
    end # describe
  end # describe

  describe '::create!' do
    include_context 'with a defined model and collection'

    let(:collection) { described_class.create! params }

    it { expect(described_class).to respond_to(:create!).with(1).arguments }

    describe 'with a non-enumerable object' do
      let(:params) { Object.new }

      it 'raises an error' do
        expect { described_class.create! params }.to raise_error ArgumentError
      end # it
    end # describe

    describe 'with an empty array' do
      let(:params) { [] }

      it 'raises an error' do
        expect { described_class.create! params }.to raise_error ArgumentError
      end # it
    end # describe

    describe 'with an array of valid params hashes' do
      let(:params) { valid_params_for_create }

      it 'creates an instance of the collection with created model objects' do
        expect(collection).to be_a(described_class) & have(params.count).items
      end # it

      it 'saves the created model objects' do
        expect { described_class.create! params }.to change(model, :count).by(params.count)
      end # it
    end # describe

    describe 'with an array of invalid params hashes' do
      let(:params) { invalid_params_for_create }

      it 'raises an error' do
        expect { described_class.create! params }.to raise_error /Unable to persist collection/
      end # it

      it 'does not save the created model objects' do
        expect {
          begin; described_class.create! params; rescue; end
        }.not_to change(model, :count)
      end # it
    end # describe
  end # describe

  describe '#initialize' do
    include_context 'with a defined model and collection'

    it { expect(described_class).to construct.with(1).arguments }

    describe 'with a non-enumerable arguments object' do
      let(:params) { Object.new }

      it 'raises an error' do
        expect { described_class.new params }.to raise_error ArgumentError
      end # it
    end # describe

    describe 'with an empty parameters array' do
      let(:params) { [] }

      it 'creates an empty collection' do
        expect(instance.to_a).to have(0).items
      end # it
    end # describe

    describe 'with an array of params hashes' do
      let(:params) { valid_params_for_create }

      it 'creates instances of the model with the specified parameters' do
        expect(instance.to_a).to have(3).items
        instance.to_a.each.with_index do |item, index|
          expect(item).to be_a(model)
          params[index].each do |attribute, value|
            expect(item.send attribute).to be == value
          end # each
        end # each
      end # it
    end # describe

    describe 'with an array of model instances' do
      let(:params) do
        [*0..2].map { |index| model.new }
      end # let

      it 'stores the model instances in the collection' do
        expect(instance.to_a).to be == params
      end # it

      it 'creates a duplicate of the array' do
        expect { params.pop }.not_to change(instance, :count)
      end # it
    end # describe
  end # describe

  describe '#assign_attributes' do
    it { expect(instance).to respond_to(:assign_attributes).with(1).arguments }

    context 'with created records' do
      include_context 'with created records'

      before(:each) { instance.save! }

      let(:records) { instance.to_a }

      describe 'with a non-enumerable object' do
        let(:attributes) { Object.new }

        it 'raises an error' do
          expect { instance.assign_attributes attributes }.to raise_error ArgumentError
        end # it
      end # describe

      describe 'with an array with count < collection.count' do
        let(:attributes) { Array.new(instance.count - 1) }

        it 'raises an error' do
          expect { instance.assign_attributes attributes }.to raise_error ArgumentError
        end # it
      end # describe

      describe 'with an array with count > collection.count' do
        let(:attributes) { Array.new(instance.count + 1) }

        it 'raises an error' do
          expect { instance.assign_attributes attributes }.to raise_error ArgumentError
        end # it
      end # describe

      describe 'with a hash with nil keys' do
        let(:attributes) do
          params = valid_params_for_update
          { records.first.id => valid_params_for_update.first,
            nil                        => valid_params_for_update.last
          } # end hash
        end # let

        it 'raises an error' do
          expect { instance.assign_attributes attributes }.to raise_error ArgumentError, /can't be blank/
        end # it
      end # describe

      describe 'with a hash with unrecognized keys' do
        let(:attributes) do
          params = valid_params_for_update
          { records.first.id => valid_params_for_update.first,
            invalid_key                => valid_params_for_update.last
          } # end hash
        end # let

        it 'raises an error' do
          expect { instance.assign_attributes attributes }.to raise_error ArgumentError, /not found/
        end # it
      end # describe

      describe 'with an array of invalid params hashes' do
        let(:attributes) { invalid_params_for_update }

        it 'sets the attributes' do
          instance.assign_attributes attributes

          records.each.with_index do |record, index|
            attributes[index].each do |attribute, value|
              expect(record[attribute]).to be == value
            end # each
          end # each
        end # it
      end # describe

      describe 'with an array of valid params hashes' do
        let(:attributes) { valid_params_for_update }

        it 'sets the attributes' do
          instance.assign_attributes attributes

          records.each.with_index do |record, index|
            attributes[index].each do |attribute, value|
              expect(record[attribute]).to be == value
            end # each
          end # each
        end # it
      end # describe

      describe 'with an empty hash' do
        let(:attributes) { {} }

        it 'does not raise an error' do
          expect { instance.assign_attributes attributes }.not_to raise_error
        end # it
      end # describe

      describe 'with a hash of invalid params hashes' do
        let(:attributes) do
          params = valid_params_for_update
          { records.first.id => invalid_params_for_update.first,
            records.last.id  => invalid_params_for_update.last
          } # end hash
        end # let

        it 'sets the attributes' do
          instance.assign_attributes attributes

          attributes.each do |key, values|
            record = records.select { |record| instance.send(:extract_key, record) == key }.first

            values.each do |attribute, value|
              expect(record[attribute]).to be == value
            end # each
          end # each
        end # it
      end # describe

      describe 'with a hash of valid params hashes' do
        let(:attributes) do
          params = valid_params_for_update
          { records.first.id => valid_params_for_update.first,
            records.last.id  => valid_params_for_update.last
          } # end hash
        end # let

        it 'sets the attributes' do
          instance.assign_attributes attributes

          attributes.each do |key, values|
            record = records.select { |record| instance.send(:extract_key, record) == key }.first

            values.each do |attribute, value|
              expect(record[attribute]).to be == value
            end # each
          end # each
        end # it
      end # describe

      describe 'with a custom method for assigning attributes' do
        shared_examples 'assigns attributes via the custom method' do
          it 'assigns attributes via the custom method' do
            constructor = form_class.method(:new)
            expect(form_class).to receive(:new).exactly(attributes.count).times do |record|
              form = constructor.call(record)

              expect(form).to receive(:assign_attributes).and_call_original

              form
            end # expect

            instance.assign_attributes attributes
          end # it
        end # shared_examples

        let(:form_name)  { "#{records.first.class.name}Form" }
        let(:form_class) { Object.const_get(form_name) }

        before(:each) do
          klass = Class.new(Struct.new :object) do
            def assign_attributes attributes
              object.assign_attributes attributes
            end # method assign_attributes
          end # klass
          Object.const_set(form_name, klass)

          allow(instance).to receive(:assign_record_attributes) do |record, attributes|
            form = form_class.new(record)
            form.assign_attributes attributes
          end # method
        end # before each

        after(:each) do
          Object.send :remove_const, form_name
        end # after each

        describe 'with an array of valid params hashes' do
          let(:attributes) { valid_params_for_update }

          include_examples 'assigns attributes via the custom method'

          it 'sets the attributes' do
            instance.assign_attributes attributes

            records.each.with_index do |record, index|
              attributes[index].each do |attribute, value|
                expect(record[attribute]).to be == value
              end # each
            end # each
          end # it
        end # describe

        describe 'with a hash of valid params hashes' do
          let(:attributes) do
            params = valid_params_for_update
            { records.first.id => valid_params_for_update.first,
              records.last.id  => valid_params_for_update.last
            } # end hash
          end # let

          include_examples 'assigns attributes via the custom method'

          it 'sets the attributes' do
            instance.assign_attributes attributes

            attributes.each do |key, values|
              record = records.select { |record| instance.send(:extract_key, record) == key }.first

              values.each do |attribute, value|
                expect(record[attribute]).to be == value
              end # each
            end # each
          end # it
        end # describe
      end # describe
    end # describe
  end # describe

  describe '#blank?' do
    it { expect(instance).to respond_to(:blank?).with(0).arguments }

    context 'with no created records' do
      it { expect(instance).to be_blank }
    end # context

    context 'with created records' do
      include_context 'with created records'

      it { expect(instance).not_to be_blank }
    end # context
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

  describe '#empty?' do
    it { expect(instance).to respond_to(:empty?).with(0).arguments }

    context 'with no created records' do
      it { expect(instance).to be_empty }
    end # context

    context 'with created records' do
      include_context 'with created records'

      it { expect(instance).not_to be_empty }
    end # context
  end # describe

  describe '#save' do
    it { expect(instance).to respond_to(:save).with(0..1).arguments }

    describe 'with no records' do
      it 'returns false' do
        expect(instance.save).to be false
      end # it
    end # describe

    describe 'with invalid records' do
      include_context 'with a defined model and collection'

      let(:params) { invalid_params_for_create }

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

      let(:params) { mixed_params_for_create }

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

      let(:params) { valid_params_for_create }

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

  describe '#save!' do
    it { expect(instance).to respond_to(:save!).with(0..1).arguments }

    describe 'with no records' do
      it 'raises an error' do
        expect { instance.save! }.to raise_error /Unable to persist collection/
      end # it
    end # describe

    describe 'with invalid records' do
      include_context 'with a defined model and collection'

      let(:params) { invalid_params_for_create }

      it 'raises an error' do
        expect { instance.save! }.to raise_error /Unable to persist collection/
      end # it

      it 'does not create the records' do
        expect {
          begin instance.save!; rescue; end
        }.not_to change(model, :count)
      end # it

      describe 'with validate: true' do
        it 'does not raise an error' do
          expect { instance.save! :validate => false }.not_to raise_error
        end # it

        it 'creates the records' do
          expect { instance.save! :validate => false }.to change(model, :count).by(params.count)
        end # it
      end # describe
    end # describe

    describe 'with a mix of valid and invalid records' do
      include_context 'with a defined model and collection'

      let(:params) { mixed_params_for_create }

      it 'raises an error' do
        expect { instance.save! }.to raise_error /Unable to persist collection/
      end # it

      it 'does not create the records' do
        expect {
          begin instance.save!; rescue; end
        }.not_to change(model, :count)
      end # it

      describe 'with validate: true' do
        it 'does not raise an error' do
          expect { instance.save! :validate => false }.not_to raise_error
        end # it

        it 'creates the records' do
          expect { instance.save! :validate => false }.to change(model, :count).by(params.count)
        end # it
      end # describe
    end # describe

    describe 'with valid records' do
      include_context 'with a defined model and collection'

      let(:params) { valid_params_for_create }

      it 'does not raise an error' do
        expect { instance.save! }.not_to raise_error
      end # it

      it 'creates the records' do
        expect { instance.save! }.to change(model, :count).by(params.count)
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

  describe '#update' do
    it { expect(instance).to respond_to(:update).with(1).arguments }

    it 'is an alias of #update_attributes' do
      expect(instance.method :update).to be == instance.method(:update_attributes)
    end # it
  end # describe

  describe '#update_attributes' do
    it { expect(instance).to respond_to(:update_attributes).with(1).arguments }

    context 'with created records' do
      include_context 'with created records'

      before(:each) { instance.save! }

      let(:records) { instance.to_a }

      describe 'with a non-enumerable object' do
        let(:attributes) { Object.new }

        it 'raises an error' do
          expect { instance.update_attributes attributes }.to raise_error ArgumentError
        end # it
      end # describe

      describe 'with an empty array' do
        let(:attributes) { [] }

        it 'raises an error' do
          expect { instance.update_attributes attributes }.to raise_error ArgumentError
        end # it
      end # describe

      describe 'with an array with count < collection.count' do
        let(:attributes) { Array.new(instance.count - 1) }

        it 'raises an error' do
          expect { instance.update_attributes attributes }.to raise_error ArgumentError
        end # it
      end # describe

      describe 'with an array with count > collection.count' do
        let(:attributes) { Array.new(instance.count + 1) }

        it 'raises an error' do
          expect { instance.update_attributes attributes }.to raise_error ArgumentError
        end # it
      end # describe

      describe 'with a hash with nil keys' do
        let(:attributes) do
          params = valid_params_for_update
          { records.first.id => valid_params_for_update.first,
            nil                        => valid_params_for_update.last
          } # end hash
        end # let

        it 'raises an error' do
          expect { instance.assign_attributes attributes }.to raise_error ArgumentError, /can't be blank/
        end # it
      end # describe

      describe 'with a hash with unrecognized keys' do
        let(:attributes) do
          params = valid_params_for_update
          { records.first.id => valid_params_for_update.first,
            invalid_key                => valid_params_for_update.last
          } # end hash
        end # let

        it 'raises an error' do
          expect { instance.assign_attributes attributes }.to raise_error ArgumentError, /not found/
        end # it
      end # describe

      describe 'with an array of invalid params hashes' do
        let(:attributes) { invalid_params_for_update }

        it 'returns false' do
          expect(instance.update_attributes attributes).to be false
        end # it

        it 'sets the attributes' do
          instance.update_attributes attributes

          records.each.with_index do |record, index|
            attributes[index].each do |attribute, value|
              expect(record[attribute]).to be == value
            end # each
          end # each
        end # it

        it 'does not update the records' do
          records.map(&:save!)

          instance.update_attributes attributes

          records.map(&:reload).each.with_index do |record, index|
            attributes[index].each do |attribute, value|
              expect(record[attribute]).not_to be == value
            end # each
          end # each
        end # it
      end # describe

      describe 'with an array of valid params hashes' do
        let(:attributes) { valid_params_for_update }

        it 'returns true' do
          expect(instance.update_attributes attributes).to be true
        end # it

        it 'sets the attributes' do
          instance.update_attributes attributes

          records.each.with_index do |record, index|
            attributes[index].each do |attribute, value|
              expect(record[attribute]).to be == value
            end # each
          end # each
        end # it

        it 'updates the records' do
          records.map(&:save!)

          instance.update_attributes attributes

          records.map(&:reload).each.with_index do |record, index|
            attributes[index].each do |attribute, value|
              expect(record[attribute]).to be == value
            end # each
          end # each
        end # it
      end # describe

      describe 'with an empty hash' do
        let(:attributes) { {} }

        it 'does not raise an error' do
          expect { instance.update_attributes attributes }.not_to raise_error
        end # it
      end # describe

      describe 'with a hash of invalid params hashes' do
        let(:attributes) do
          params = valid_params_for_update
          { records.first.id => invalid_params_for_update.first,
            records.last.id  => invalid_params_for_update.last
          } # end hash
        end # let

        it 'returns false' do
          expect(instance.update_attributes attributes).to be false
        end # it

        it 'sets the attributes' do
          instance.update_attributes attributes

          attributes.each do |key, values|
            record = records.select { |record| instance.send(:extract_key, record) == key }.first

            values.each do |attribute, value|
              expect(record[attribute]).to be == value
            end # each
          end # each
        end # it

        it 'does not update the records' do
          records.map(&:save!)

          instance.update_attributes attributes

          attributes.each do |key, values|
            record = records.select { |record| instance.send(:extract_key, record) == key }.first.reload

            values.each do |attribute, value|
              expect(record[attribute]).not_to be == value
            end # each
          end # each
        end # it
      end # describe

      describe 'with a hash of valid params hashes' do
        let(:attributes) do
          params = valid_params_for_update
          { records.first.id => valid_params_for_update.first,
            records.last.id  => valid_params_for_update.last
          } # end hash
        end # let

        it 'returns true' do
          expect(instance.update_attributes attributes).to be true
        end # it

        it 'sets the attributes' do
          instance.update_attributes attributes

          attributes.each do |key, values|
            record = records.select { |record| instance.send(:extract_key, record) == key }.first

            values.each do |attribute, value|
              expect(record[attribute]).to be == value
            end # each
          end # each
        end # it

        it 'updates the records' do
          records.map(&:save!)

          instance.update_attributes attributes

          attributes.each do |key, values|
            record = records.select { |record| instance.send(:extract_key, record) == key }.first.reload

            values.each do |attribute, value|
              expect(record[attribute]).to be == value
            end # each
          end # each
        end # it
      end # describe

      describe 'with a custom method for assigning attributes' do
        shared_examples 'assigns attributes via the custom method' do
          it 'assigns attributes via the custom method' do
            constructor = form_class.method(:new)
            expect(form_class).to receive(:new).exactly(attributes.count).times do |record|
              form = constructor.call(record)

              expect(form).to receive(:assign_attributes).and_call_original

              form
            end # expect

            instance.assign_attributes attributes
          end # it
        end # shared_examples

        let(:form_name)  { "#{records.first.class.name}Form" }
        let(:form_class) { Object.const_get(form_name) }

        before(:each) do
          klass = Class.new(Struct.new :object) do
            def assign_attributes attributes
              object.assign_attributes attributes
            end # method assign_attributes
          end # klass
          Object.const_set(form_name, klass)

          allow(instance).to receive(:assign_record_attributes) do |record, attributes|
            form = form_class.new(record)
            form.assign_attributes attributes
          end # method
        end # before each

        after(:each) do
          Object.send :remove_const, form_name
        end # after each

        describe 'with an array of valid params hashes' do
          let(:attributes) { valid_params_for_update }

          include_examples 'assigns attributes via the custom method'

          it 'returns true' do
            expect(instance.update_attributes attributes).to be true
          end # it

          it 'sets the attributes' do
            instance.update_attributes attributes

            records.each.with_index do |record, index|
              attributes[index].each do |attribute, value|
                expect(record[attribute]).to be == value
              end # each
            end # each
          end # it

          it 'updates the records' do
            records.map(&:save!)

            instance.update_attributes attributes

            records.map(&:reload).each.with_index do |record, index|
              attributes[index].each do |attribute, value|
                expect(record[attribute]).to be == value
              end # each
            end # each
          end # it
        end # describe

        describe 'with a hash of valid params hashes' do
          let(:attributes) do
            params = valid_params_for_update
            { records.first.id => valid_params_for_update.first,
              records.last.id  => valid_params_for_update.last
            } # end hash
          end # let

          include_examples 'assigns attributes via the custom method'

          it 'returns true' do
            expect(instance.update_attributes attributes).to be true
          end # it

          it 'sets the attributes' do
            instance.update_attributes attributes

            attributes.each do |key, values|
              record = records.select { |record| instance.send(:extract_key, record) == key }.first

              values.each do |attribute, value|
                expect(record[attribute]).to be == value
              end # each
            end # each
          end # it

          it 'updates the records' do
            records.map(&:save!)

            instance.update_attributes attributes

            attributes.each do |key, values|
              record = records.select { |record| instance.send(:extract_key, record) == key }.first.reload

              values.each do |attribute, value|
                expect(record[attribute]).to be == value
              end # each
            end # each
          end # it
        end # describe
      end # describe
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
  end # describe
end # shared examples
