# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    include Pagy::Backend
    helper all_helpers_from_path "app/helpers"
    before_action :authenticate_user!, :authenticate_admin

    def authenticate_admin
      raise CanCan::AccessDenied unless current_user.has_role? :admin
    end

    def current_ability
      @current_ability ||= Ability.new(current_user, params)
    end

    def index
      authorize_resource(resource_class)

      @q = scoped_resource.ransack(params[:q])

      search_term = params[:search].to_s.strip
      #resources = Administrate::Search.new(scoped_resource,
      #                                     dashboard_class,
      #                                     search_term).run
      resources = @q.result
      @pagy, @records = pagy resources
      resources = apply_collection_includes(resources)
      resources = order.apply(resources)
      resources = resources.page(params[:_page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      render locals: {
        resources: resources,
        search_term: search_term,
        page: page,
        show_search_bar: show_search_bar?,
      }
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end
  end
end
