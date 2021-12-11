module Admin
  class ApplicationController < ApplicationController
    before_action :verify_admin!

    def verify_admin!
      raise CanCan::AccessDenied unless current_user.has_role? :admin
    end
  end
end
