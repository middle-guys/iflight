class OrdersController
  class CreateOrderService
    def new_order(params)
      @order = Order.new(order_params)
      @order.order_number = Order.generate_order_number
      @order.user = find_or_create_user(params)
      @order.status = :init

      @order
    end

    private
      def find_or_create_user(params)
        return current_user if user_signed_in?
      end
  end
end