class ProductsController < ApplicationController
  before_action :find_product, only: %i[show update destroy]

  def index
    @products = Product.all

    render json: @products
  end

  def show
    render json: @product
  end

  def create
    @product = Product.new(product_params)
    authorize @product

    return render json: @product, status: :created if @product.save

    render json: @product.errors, status: :unprocessable_entity
  end

  def update
    authorize @product

    return render json: @product if @product.update(product_params)

    render json: @product.errors, status: :unprocessable_entity
  end

  def destroy
    authorize @product
    @product.destroy
    head :no_content
  end

  private

  def find_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock)
  end
end
