# frozen_string_literal: true

class TagsController < ApplicationController
  load_and_authorize_resource

  respond_to :html, :json, :csv

  def download
    @course = Course.find(params[:course_id])
  end

  def index

    @tags = @tags.undiscarded.order("tags.created_at": :desc).where(course_id: params[:course_id]) if params[:course_id]
    @tags = @tags.count if params[:agg] == "count"
    @tags_ransack = @tags.ransack(params[:q])

    @pagy, @records = pagy @tags_ransack.result
    respond_to do |format|
      format.html
      format.json { render json: @records }
      format.js { render inline: "window.open('#{URI::HTTP.build(path: "#{request.path}.csv", query: request.query_parameters.to_query, format: :csv)}', '_blank')" }
      format.csv {
        send_data helpers.to_csv(params[:tag].to_unsafe_h, @tags_ransack.result, Tag),
                  filename: helpers.csv_download_name(controller_name.classify.constantize)
      }
    end
  end

  def import
    CSV.foreach(params[:csv_file], headers: true) do |row|
      tag = Tag.find_or_create_by!(row.to_hash.to_hash.merge({ course_id: params[:course_id] }))
    end

    SiteNotification.with(type: "Success", body: "Successfully imported file.", title: "Success", delay: 2).deliver(current_user)

    redirect_to request.referer
  end

  def destroy
    tag = Tag.find(params[:id])

    render nothing: true, status: :bad_request unless tag

    tag.discard

    redirect_to request.referer
  end

  def create
    @tag = Tag.create(create_params)
    respond_with @tag, location: course_tags_path(@course)
  end

  def update
    @tag = Tag.find(params[:id])
    @tag.update(update_params)

    respond_with @tag, location: course_tags_path(@course)
  end

  def edit
    @tag = Tag.find(params[:id])
    @course = @tag.course
  end

  def new
    @course = Course.find(params[:course_id]) if params[:course_id]
    @tag = Tag.new
  end

  def show
    @tag = Tag.find(params[:id])
    @course = @tag.course
  end

  private

  def update_params
    params.require(:tag).permit(:archived, :name, :description, :course_id, :tag_group_id)
  end

  def create_params
    params.require(:tag).permit(:archived, :name, :description, :course_id, :tag_group_id)
  end
end
