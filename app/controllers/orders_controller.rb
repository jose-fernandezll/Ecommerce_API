class OrdersController < ApplicationController
  before_action :set_cart, only: [:create]
  before_action :find_order, only: [:show]

  def create
    authorize Order

    return render json: { error: 'Cart is empty' }, status: :unprocessable_entity if @cart.cart_items.empty?

    order = current_user.orders.build
    ActiveRecord::Base.transaction do

      @cart.cart_items.each do |cart_item|
        product = cart_item.product

        order.order_items.build(
          product: product,
          quantity: cart_item.quantity,
          price: product.price
        )

        product.update!(stock: product.stock - cart_item.quantity)
      end

      order.save!
      @cart.cart_items.destroy_all
    end

    render json: {
      message: "La orden ha sido creada exitosamente.",
      status: "pending",
      order: OrderSerializer.new(order).serializable_hash
    }, status: :created

  end

  def show
    authorize @order

    render json: OrderSerializer.new(@order, include: [:order_items]).serializable_hash.to_json
  end

  def update
    ActiveRecord::Base.transaction do
      update_order_items
      @order.save!
    end

    render json: { order: serialized_body('OrderSerializer', @order) }, status: :ok
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def update_order_items

    params[:order][:order_items].each do |item_params|
      product = Product.find(item_params[:product_id])
      order_item = @order.order_items.find_or_initialize_by(product: product)

      if item_params[:quantity].to_i <= 0
        order_item.destroy
      else

        order_item.update!(quantity: item_params[:quantity])
      end

      if product.stock < order_item.quantity
        raise ActiveRecord::RecordInvalid.new(@order), "Insufficient stock for product #{product.name}"
      end
    end
  end


  private

  def set_cart
    @cart = current_user.cart
  end

  def find_order
    @order = current_user.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(order_items: [:product_id, :quantity])
  end
end
