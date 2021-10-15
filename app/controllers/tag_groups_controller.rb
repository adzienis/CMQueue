class TagGroupsController < ApplicationController
  load_and_authorize_resource id_param: :tag_group_id

  respond_to :html, :json

  def index
    @tag_groups = TagGroup.all

    @tag_groups_ransack = @tag_groups.ransack(params[:q])

    @pagy, @records = pagy @tag_groups_ransack.result

  end

  def new
    @tag_group = TagGroup.new
  end

  def show
    @tag_group = @tag_groups.find(params[:tag_group_id])
  end

  def update
    @tag_group.update(tag_group_params)

    respond_with @tag_group, location: course_tag_groups_path(@course)
  end

  def create
    @tag_group = TagGroup.create(tag_group_params)
    respond_with @tag_group, location: course_tag_groups_path(@course)
  end

  def edit
  end

  def destroy
    @tag_group = @tag_groups.find(params[:tag_group_id])

    @tag_group.destroy

    respond_with @tag_group, location: course_tag_groups_path(@course)
  end

  private

  def tag_group_params
    params.require(:tag_group).permit(:course_id, :name, tag_ids: [])
  end
end
