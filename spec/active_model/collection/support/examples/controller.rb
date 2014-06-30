# spec/active_model/collection/support/examples/collection.rb

RSpec.shared_examples 'MockController' do
  include_context 'with a defined model and collection'

  let(:controller) do
    double('controller').tap do |mock|
      allow(mock).to receive(:redirect)
      allow(mock).to receive(:render)
    end # tap
  end # let

  describe '#create' do
    def perform_action
      if collection.save
        controller.redirect
      else
        controller.render
      end # if-else
    end # method perform_action

    let(:collection) { described_class.new *params }

    describe 'with valid params' do
      let(:params) { valid_params }

      it 'persists the records' do
        expect { perform_action }.to change(model, :count).by(params.count)
      end # it

      it 'calls controller#redirect' do
        expect(controller).to receive(:redirect)
        perform_action
      end # it
    end # describe

    describe 'with invalid params' do
      let(:params) { invalid_params }

      it 'does not persist the records' do
        expect { perform_action }.not_to change(model, :count)
      end # it

      it 'calls controller#render' do
        expect(controller).to receive(:render)
        perform_action
      end # it
    end # describe
  end # describe
end # shared_examples
