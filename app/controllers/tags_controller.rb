class TagsController < ApplicationController
  def index
    @tags = Tag.all
    @tags = @tags.where(course_id: params[:course_id]) if params[:course_id]


    render json: @tags
  end

  def destroy
    tag = Tag.find(params[:id])

    tag.destroy if tag

    redirect_to settings_queues_course_path(tag.course)
  end

  def create
    @tag = Tag.create(create_tag_params)

    redirect_to settings_queues_course_path(@tag.course)
  end

  def update
    @tag = Tag.find(params[:id])
    @tag.update(update_params)

    redirect_to edit_tag_path(@tag)
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def show

    @tag = Tag.find(params[:id])
  end

  private

  def update_params
    params.require(:tag).permit(:archived, :name, :description)
  end

  def create_tag_params
    params.require(:tag).permit(:archived, :name, :description, :course_id)
  end
end
