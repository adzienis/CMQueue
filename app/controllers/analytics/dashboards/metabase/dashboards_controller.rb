class Analytics::Dashboards::Metabase::DashboardsController < ApplicationController

  respond_to :json

  before_action :required_params

  def index
    metabase = Analytics::Metabase.new

    metabase.login("arthurdzieniszewski@gmail.com", "Tadeusz1")

    collection = metabase.collections.find{|c| c["name"] == @course.name}

    respond_with nil if collection.nil?

    items = metabase.collection_items(collection["id"])

    respond_with nil if items.nil?

    respond_with items["data"].filter{|item| item["model"] == "dashboard"}
  end

  private

  def required_params
    render json: nil, status: 400 if params[:course_id].nil?
  end
end
