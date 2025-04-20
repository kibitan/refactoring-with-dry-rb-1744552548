require 'dry/monads'

class OrderProcessor
  include Dry::Monads[:result]

  def initialize(order)
    @order = order
  end

  def process
    find_total(@order).bind do |total|
      calculate_final_total(total)
    end
  end

  private

  def find_total(order)
    return Failure(:order_is_nil) if order.nil?
    return Failure(:order_must_be_a_hash) unless order.is_a?(Hash)
    return Failure(:missing_total_in_order) unless order.key?(:total)
    return Failure(:total_must_be_greater_than_zero) if order[:total].to_f <= 0

    Success(order[:total].to_f)
  end

  def calculate_final_total(total)
    shipping_cost = total > 100 ? 10 : 20
    tax = total * 0.1
    gross_total = total + shipping_cost + tax
    discount = gross_total > 1000 ? 50 : 0

    final_total = gross_total - discount
    return Failure(:final_total_cannot_be_negative) if final_total.negative?

    Success(final_total)
  end

  def final_total
    @final_total ||= gross_total - discount
  end
end
