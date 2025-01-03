module Api
    module V1
      class CartsController < ApplicationController
        before_action :set_cart
      
        def add_item
          authorize @cart
          product = Product.find(params[:product_id])
      
          if product.stock < params[:quantity].to_i
            raise InsufficientStockError.new(product)
          end
      
          find_or_initialize_cart_item(product)
      
          render json: CartSerializer.new(@cart, include: [:cart_items]).serializable_hash.to_json, status: :ok
        end
      
        def remove_item
          authorize @cart
      
          item = @cart.cart_items.find_by!(product_id: params[:product_id])
      
          item.destroy
          render json: CartSerializer.new(@cart, include: [:cart_items]).serializable_hash.to_json, status: :ok
        end
      
        def show
          render json: CartSerializer.new(@cart, include: [:cart_items]).serializable_hash.to_json
        end
      
        private
      
        def set_cart
          @cart = current_user.cart
        end
      
        def find_or_initialize_cart_item(product)
          item = @cart.cart_items.find_or_initialize_by(product: product)
          item.quantity += params[:quantity].to_i
          item.save
          item
        end
      end
    end
end
