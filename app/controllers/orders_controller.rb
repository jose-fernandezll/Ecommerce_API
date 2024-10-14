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

  private

  def set_cart
    @cart = current_user.cart
  end

  def find_order
    @order = current_user.orders.find(params[:id])
  end
end
