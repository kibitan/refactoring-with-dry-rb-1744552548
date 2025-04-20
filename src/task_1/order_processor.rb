require 'dry/monads'

class OrderProcessor
  include Dry::Monads[:result]

  def initialize(order)
    @order = order
  end

  def process
    return Failure(:order_is_nil) if @order.nil?
    return Failure(:order_must_be_a_hash) unless @order.is_a?(Hash)
    return Failure(:missing_total_in_order) unless @order.has_key?(:total)
    return Failure(:total_must_be_greater_than_zero) if @order[:total].to_f <= 0
    return Failure(:final_total_cannot_be_negative) if final_total < 0

    Success(final_total)
  end

  private

  def total
    @order[:total].to_f
  end

  def shipping_cost
    total > 100 ? 10 : 20
  end

  def tax
    total * 0.1
  end

  def gross_total
    total + shipping_cost + tax
  end

  def discount
    gross_total > 1000 ? 50 : 0
  end

  def final_total
    gross_total - discount
  end
end
