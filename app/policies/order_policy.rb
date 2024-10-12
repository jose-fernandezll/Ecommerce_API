class OrderPolicy < ApplicationPolicy
  def create?
    user_owns_cart_or_admin?
  end

  def show?
    user_owns_cart_or_admin?
  end


  private

  def user_owns_cart_or_admin?
    user.admin? || record.user == user
  end
end
