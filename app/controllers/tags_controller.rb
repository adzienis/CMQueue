# frozen_string_literal: true

class TagsController < ApplicationController
  load_and_authorize_resource

  def index
    @course = Course.find(params[:course_id]) if params[:course_id]

    @tags = @tags.undiscarded.order(updated_at: :desc).where(course_id: params[:course_id]) if params[:course_id]
    @tags_ransack = @tags.ransack(params[:q])

    @pagy, @records = pagy @tags_ransack.result

    respond_to do |format|
      format.html
      format.js { render inline: "window.open('#{URI::HTTP.build(path: "#{request.path}.csv", query: request.query_parameters.to_query, format: :csv)}', '_blank')" }
      format.csv { send_data helpers.to_csv(params[:tag].to_unsafe_h, @tags_ransack.result, Tag), filename: "test.csv" }
    end
  end

  def import
    CSV.foreach(params[:csv_file], headers: true) do |row|
      tag = Tag.find_or_create_by!(row.to_hash.to_hash.merge({ course_id: params[:course_id]}))
    end

    SiteNotification.with(type: "Success", body: "Successfully imported file.", title: "Success", delay: 2).deliver(current_user)

    redirect_to request.referer
  end

  def destroy
    tag = Tag.find_by(id: params[:id])

    render nothing: true, status: :bad_request unless tag

    tag.discard

    redirect_to request.referer
  end

  def create
    @tag = Tag.create(create_params)

    render turbo_stream: (turbo_stream.replace @tag, partial: "shared/edit_form", locals: { model_instance: @tag }) and return unless @tag.errors.count == 0

    redirect_to course_tags_path(@tag.course)
  end

  def update
    @tag = Tag.find(params[:id])
    @tag.update(update_params)

    render turbo_stream: (turbo_stream.update @tag, partial: "shared/edit_model", locals: { model_instance: @tag }) and return unless @tag.errors.count == 0

    redirect_to course_tag_path(@tag.course)
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
    params.require(:tag).permit(:archived, :name, :description)
  end

  def create_params
    params.require(:tag).permit(:archived, :name, :description, :course_id)
  end
end
