# frozen_string_literal: true

class ApplicationsController < ApplicationController
  include Doorkeeper

  def index
    @course = Course.find(params[:course_id]) if params[:course_id]
    @applications = Application.all
    if params[:course_id]
      @applications = @applications.where(id: AccessGrant.where(resource_owner_type: 'Course',
                                                                resource_owner_id: params[:course_id]).select('distinct on (resource_owner_id) *').pluck(:resource_owner_id))
    end

    puts @applications
  end

  def create; end

  def show
    @course = Course.find(params[:course_id]) if params[:course_id]
  end
end
