# frozen_string_literal: true

module Courses
  class SettingsController < ApplicationController
    def index
      @course = Course.find(params[:id])

      @tags = Course.find(params[:id]).tags
    end
  end
end
