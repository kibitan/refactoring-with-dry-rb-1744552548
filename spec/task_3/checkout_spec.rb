require_relative '../../src/task_3/checkout'

RSpec.describe Checkout do
  include Dry::Monads[:result, :maybe, :try]
  subject(:checkout) { described_class.new }

  let(:physical_item) { Item.new(50, false) }
  let(:digital_item)  { Item.new(50, true) }
  let(:user_with_addr)    { User.new(100, '123 Maple St') }
  let(:user_no_addr)      { User.new(100, nil) }
  let(:user_low_balance)  { User.new(20, '123 Maple St') }
  let(:valid_coupon)   { 'COUPON10' }
  let(:invalid_coupon) { 'INVALID' }

  it 'fails if no user is provided' do
    result = checkout.checkout(nil, [physical_item])
    expect(result).to eq(Failure('User is required'))
  end

  it 'fails if item list is empty' do
    result = checkout.checkout(user_with_addr, [])
    expect(result).to eq(Failure('No items to checkout'))
  end

  it 'fails if shipping address is missing for physical items' do
    result = checkout.checkout(user_no_addr, [physical_item])
    expect(result).to eq(Failure('Shipping address required for physical items'))
  end

  it 'fails if an invalid coupon code is given' do
    result = checkout.checkout(user_with_addr, [digital_item], invalid_coupon)
    expect(result).to eq(Failure('Invalid coupon code'))
  end

  it 'applies discount for a valid coupon code' do
    result = checkout.checkout(user_with_addr, [Item.new(50, false)], valid_coupon)
    expect(result).to eq(Success(40))
  end

  it 'fails if user has insufficient funds' do
    result = checkout.checkout(user_low_balance, [digital_item])
    expect(result).to eq(Failure('Insufficient funds'))
  end

  it 'fails if payment processing raises an error' do
    allow(PaymentGateway).to receive(:charge).and_raise(PaymentGateway::PaymentError.new('Gateway timeout'))
    result = checkout.checkout(user_with_addr, [physical_item])
    expect(result).to eq(Failure('Payment error: Gateway timeout'))
  end

  it 'succeeds for a valid user with digital items and no coupon' do
    result = checkout.checkout(user_with_addr, [digital_item])
    expect(result).to eq(Success(50))
  end

  it 'succeeds for a valid user with physical items and a shipping address' do
    result = checkout.checkout(user_with_addr, [physical_item])
    expect(result).to eq(Success(50))
  end
end
