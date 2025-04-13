class Checkout
  User = Struct.new(:name, :active?)
  Cart = Struct.new(:items)

  def checkout(user, cart, payment_info)
    return 'Error: No user provided' if user.nil?

    return 'Error: User account is not active' unless user.active?

    return 'Error: No cart provided' if cart.nil?

    return 'Error: Cart is empty' if cart.items.nil? || cart.items.empty?

    return 'Error: Cart contains items with invalid quantity' if cart.items.any? { |item| item[:quantity] <= 0 }

    return 'Error: Payment information is missing' if payment_info.nil?

    return 'Error: Card number is invalid' if payment_info[:card_number].to_s.strip == ''

    return 'Error: CVV code is invalid' if payment_info[:cvv].to_s.length != 3

    return 'Error: Payment amount must be greater than 0' if payment_info[:amount].nil? || payment_info[:amount] <= 0

    return 'Error: Payment gateway declined the card' if payment_info[:card_number].start_with?('0')

    return 'Error: Payment failed due to amount limit' if payment_info[:amount] > 1000

    payment_success = true # (In a real scenario, we'd get a response from a payment API)
    return 'Error: Unknown payment error occurred' unless payment_success

    if cart.items.any? { |item| item[:name] == 'Forbidden Item' }
      return 'Error: Order creation failed due to forbidden item in cart'
    end

    order_id = rand(1000..9999)
    order_summary = {
      order_id: order_id,
      user_name: user.name,
      total_items: cart.items.size,
      total_amount: payment_info[:amount]
    }

    return 'Error: Too many items in the order, cannot create order' if order_summary[:total_items] > 50

    "Order ##{order_id} created successfully for user #{user.name}"
  end
end
