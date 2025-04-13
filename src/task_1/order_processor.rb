class OrderProcessor
  def initialize(order)
    @order = order
  end

  def process
    if @order.nil?
      puts 'Error: Order is nil.'
      nil
    elsif !@order.is_a?(Hash)
      puts 'Error: Order must be a Hash.'
      nil
    elsif !@order.has_key?(:total)
      puts 'Error: Missing total in order.'
      nil
    elsif @order[:total].to_f <= 0
      puts 'Error: Total must be greater than 0.'
      nil
    else
      total = @order[:total].to_f
      shipping_cost = if total > 100
                        10
                      else
                        20
                      end
      tax = total * 0.1
      gross_total = total + shipping_cost + tax
      discount = 0
      discount = 50 if gross_total > 1000
      final_total = gross_total - discount
      if final_total < 0
        puts 'Error: Final total cannot be negative.'
        nil
      else
        return "Order processed with high total: #{final_total}" if final_total > 500

        final_total
      end
    end
  end
end
