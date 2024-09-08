class ReviewsController < ApplicationController
  before_action :set_item, only: %i[new create]

  def create
    @review = Review.new(review_params)
    @review.item = @item
    @review.user = current_user
    @review.save
    redirect_to item_path(@item)
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def review_params
    params.require(:review).permit(:comment, :rating)
  end
end
