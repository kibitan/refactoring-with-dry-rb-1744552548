require_relative '../../src/task_4/checkout'

RSpec.describe Checkout do
  include Dry::Monads[:result]

  let(:user) { double('User', active?: true) }
  let(:inactive_user) { double('User', active?: false) }
  let(:item)          { double('Item', price: 50) }
  let(:cart)          { double('Cart', items: [item], empty?: false) }
  let(:empty_cart)    { double('Cart', items: [], empty?: true) }
  let(:payment)       { double('Payment', charge: true) }
  let(:failing_payment) { double('Payment', charge: false) }

  describe '#call' do
    subject(:result) { described_class.new.call(user:, cart:, payment:) }

    it 'returns Success with confirmation message for valid input' do
      expect(result).to match(Success(/Order #\d+ placed successfully/))
    end

    context 'when user is invalid' do
      context 'when user is nil' do
        let(:user) { nil }

        it 'returns Failure with invalid user message' do
          expect(result).to eq(Failure('Invalid user'))
        end
      end

      context 'when user is not active' do
        let(:user) { inactive_user }

        it 'returns Failure with invalid user message' do
          expect(result).to eq(Failure('Invalid user'))
        end
      end
    end

    context 'when cart is invalid' do
      context 'when cart is nil' do
        let(:cart) { nil }

        it 'returns Failure with empty cart message' do
          expect(result).to eq(Failure('Cart is empty'))
        end
      end

      context 'when cart has no items' do
        let(:cart) { empty_cart }

        it 'returns Failure with empty cart message' do
          expect(result).to eq(Failure('Cart is empty'))
        end
      end
    end

    context 'when payment is invalid' do
      context 'when payment is nil' do
        let(:payment) { nil }

        it 'returns Failure with invalid payment message' do
          expect(result).to eq(Failure('Invalid payment'))
        end
      end

      context 'when payment charge fails' do
        let(:payment) { failing_payment }

        it 'returns Failure with payment failed message' do
          expect(result).to eq(Failure('Payment failed'))
        end
      end
    end
  end
end
