# frozen_string_literal: true

module Courses
  class QuestionQueuesController < ApplicationController
    def create; end

    def index

      respond_to do |format|
        format.html
        format.json { render json: Course.where('name LIKE :name', name: "%#{params[:name]}%") }
      end
    end

    def show; end
  end
end
