require 'dry/monads'

class OrderProcessor
  include Dry::Monads[:result]

  def initialize(order)
    @order = order
  end

  def process
    find_total(@order).bind do |total|
      calculate_gross_total(total).bind do |gross_total|
        calculate_discount(gross_total).bind do |discount|
          calculate_final_total(gross_total, discount)
        end
      end
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

  def calculate_gross_total(total)
    shipping_cost = total > 100 ? 10 : 20
    tax = total * 0.1

    Success(total + shipping_cost + tax)
  end

  def calculate_discount(gross_total)
    Success(gross_total > 1000 ? 50 : 0)
  end

  def calculate_final_total(gross_total, discount)
    final_total = gross_total - discount
    return Failure(:final_total_cannot_be_negative) if final_total.negative?

    Success(final_total)
  end
end
