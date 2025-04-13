require_relative '../../src/task_1/order_processor'

RSpec.describe OrderProcessor do
  subject(:result) { OrderProcessor.new(order).process }

  context 'when order is nil' do
    let(:order) { nil }

    it 'returns failure' do
      expect(result).to be_failure
    end
  end

  context 'when order is not a hash' do
    let(:order) { 'invalid' }

    it 'returns failure' do
      expect(result).to be_failure
    end
  end

  context 'when total is missing' do
    let(:order) { {} }

    it 'returns failure' do
      expect(result).to be_failure
    end
  end

  context 'when total is negative' do
    let(:order) { { total: -1 } }

    it 'returns failure' do
      expect(result).to be_failure
    end
  end

  context 'when total is below 500' do
    let(:order) { { total: 50 } }

    it 'returns a correct value' do
      expect(result.value!).to eq(75)
    end
  end

  context 'when total is above 500' do
    let(:order) { { total: 600 } }

    it 'returns a correct value' do
      expect(result.value!).to eq(670)
    end
  end

  context 'when total is above 1000' do
    let(:order) { { total: 1100 } }

    it 'returns a correct value' do
      expect(result.value!).to eq(1170)
    end
  end
end
