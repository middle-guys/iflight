class OrdersController
  class CreateOrderService
    def new_order(params, current_user)
      @current_user = current_user
      @order = Order.new(params)
      @order.order_number = Order.generate_order_number
      if current_user
        @order.user_id = current_user.ids
      else
        @order.user_id = find_or_create_user(params)
      end
      @order.status = :init
      @order
    end

    private
      def find_or_create_user(params)
        user = User.where(email: params[:contact_email]).first

        unless user.present?
          user = User.new(email: params[:contact_email], phone: params[:contact_phone], 
            name: params[:contact_name], is_registered: false, is_admin: false, 
            gender: params[:contact_gender], password: "123")
          user.save
        end
        return user.id
      end
  end
end