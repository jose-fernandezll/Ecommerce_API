class Api::V1::ProductsController < ApplicationController
  before_action :find_product, only: %i[show update destroy]

  def index
    @products = Product.all

    render_product(@products)
  end

  def show
    render_product(@product)
  end

  def create
    @product = Product.new(product_params)
    authorize @product

    return render_product(@product, status: :created) if @product.save

    render json: { errors: @product.errors }, status: :unprocessable_entity

  end

  def update
    authorize @product

    return render_product(@product) if @product.update(product_params)

    render json: { errors: @product.errors }, status: :unprocessable_entity
  end

  def destroy
    authorize @product

    if @product.destroy
      head :no_content
    else
      render json: { error: "Failed to delete product" }, status: :unprocessable_entity
    end
  end

  private

  def find_product
    @product ||= Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock)
  end

  def render_product(product, status: :ok)
    render json: ProductSerializer.new(product).serializable_hash.to_json, status: status
  end

end
