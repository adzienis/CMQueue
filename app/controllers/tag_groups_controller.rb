class TagGroupsController < ApplicationController

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
    @tag_group = TagGroup.accessible_by(current_ability).find(params[:tag_group_id])
  end

  def update
    @tag_group = TagGroup.accessible_by(current_ability).find(params[:tag_group_id])
    @tag_group.update(tag_group_params)



    respond_with @tag_group, location: course_tag_groups_path(@course)
  end

  def create
    @tag_group = TagGroup.create(tag_group_params)
    respond_with @tag_group, location: course_tag_groups_path(@course)
  end

  def edit
    @tag_group = TagGroup.accessible_by(current_ability).find(params[:tag_group_id])
  end

  def destroy
  end

  private

  def tag_group_params
    params.require(:tag_group).permit(:course_id, :name,  tag_ids: [])
  end
end
