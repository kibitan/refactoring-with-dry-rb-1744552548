class Checkout
  def initialize
    @last_order_id = nil
  end

  def checkout(user, items, payment_method, shipping_method, coupon_code = nil)
    if user.nil?
      puts 'Error: No user provided.'
      false
    elsif (user.respond_to?(:active?) && !user.active?) || (user.respond_to?(:active) && !user.active)
      puts 'Error: User is not active.'
      false
    elsif items.nil?
      puts 'Error: No items in the cart.'
      false
    elsif items.empty?
      puts 'Error: Cart is empty.'
      false
    else
      items.each do |item|
        if item.nil?
          puts 'Error: An invalid item was found in the cart.'
          return false
        end
        next unless !item.respond_to?(:[]) || item[:digital] != true

        stock_quantity = 0
        if item.respond_to?(:[]) && item.key?(:stock)
          stock_quantity = (item[:stock] || 0).to_i
        elsif item.respond_to?(:stock)
          stock_quantity = (item.stock || 0).to_i
        end
        if stock_quantity <= 0
          puts "Error: Item '#{item.respond_to?(:[]) ? item[:name] : item}' is out of stock."
          return false
        end
      end
      total = 0
      items.each do |item|
        price = 0
        if item.respond_to?(:[]) && item.key?(:price)
          price = item[:price].to_f
        elsif item.respond_to?(:price)
          begin
            price = item.price.to_f
          rescue StandardError
            price = 0
          end
        end
        total += price
      end
      unless coupon_code.nil?
        if coupon_code == 'EXPIRED'
          puts 'Error: Coupon has expired.'
          return false
        elsif coupon_code != 'DISCOUNT10'
          puts 'Error: Coupon code is invalid.'
          return false
        else
          puts 'Coupon applied. 10% discount on total price.'
          total -= (total * 0.10)
        end
      end
      if payment_method.nil? || (payment_method.respond_to?(:empty?) && payment_method.empty?)
        puts 'Error: No payment method provided.'
        return false
      else
        valid_payments = [:credit_card, :paypal, 'credit_card', 'paypal']
        unless valid_payments.include?(payment_method)
          puts "Error: Payment method '#{payment_method}' is not accepted."
          return false
        end
      end
      physical_items = items.select { |item| !(item.respond_to?(:[]) && item[:digital] == true) }
      if physical_items.nil? || physical_items.empty?
        puts 'All items are digital. No shipping needed.'
      elsif shipping_method.nil? || (shipping_method.respond_to?(:empty?) && shipping_method.empty?)
        puts 'Error: No shipping method provided for physical items.'
        return false
      else
        allowed_shipping = ['standard', 'express', :standard, :express]
        unless allowed_shipping.include?(shipping_method)
          puts "Error: Shipping method '#{shipping_method}' is not available."
          return false
        end
      end
      @last_order_id ||= 1000
      @last_order_id += 1
      order_id = @last_order_id
      puts "Checkout completed successfully. Order ##{order_id} created."
      order_id
    end
  end
end
