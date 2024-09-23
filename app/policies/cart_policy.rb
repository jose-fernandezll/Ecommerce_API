class CartPolicy < ApplicationPolicy
  def add_item?
    user_owns_cart_or_admin?
  end

  def remove_item?
    user_owns_cart_or_admin?
  end


  private

  def user_owns_cart_or_admin?
    user.admin? || record.user == user
  end
end
