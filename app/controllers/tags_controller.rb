class TagsController < ApplicationController
  load_and_authorize_resource

  def index
    @tags = @tags.where(course_id: params[:course_id]) if params[:course_id]
    @course = Course.find(params[:course_id]) if params[:course_id]

    @tags_ransack = @tags.ransack(params[:q])

    @pagy, @records = pagy @tags_ransack.result

    respond_to do |format|
      format.html
      format.json do
        render json: @tags
      end
    end
  end

  def destroy
    tag = Tag.find(params[:id])

    tag.destroy if tag

    redirect_to course_tags_path(tag.course)
  end

  def create
    @tag = Tag.create(create_params)

    redirect_to course_tags_path(@tag.course)
  end

  def update
    @tag = Tag.find(params[:id])
    @tag.update(update_params)

    redirect_to course_tag_path(@tag.course)
  end

  def edit
    @tag = Tag.find(params[:id])
    @course = @tag.course
  end

  def new
    @course = Course.find(params[:course_id]) if params[:course_id]
  end

  def show
    @tag = Tag.find(params[:id])
    @course = @tag.course
  end

  private

  def update_params
    params.require(:tag).permit(:archived, :name, :description)
  end

  def create_params
    params.require(:tag).permit(:archived, :name, :description, :course_id)
  end
end
