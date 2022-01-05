class Admin::Courses::RegistrationsController < Admin::ApplicationController
  def index
    @registrations = Courses::Registration.search params[:q]
    builder = Search::ClauseBuilder.new(attributes: [:approved], params: params)

    where_params = builder.build_clauses(params)
    order_params = builder.build_order_clauses(request.query_parameters)

    @results = Courses::Registration.pagy_search(params[:q].present? ? params[:q] : "*",
      aggs: [:approved],
      where: where_params,
      order: order_params)
    @pagy, @results = pagy_searchkick(@results, items: 10)
  end

  def update
    @registration = Courses::Registration.find(params[:registration_id])
    Admin::Courses::Registrations::CreateCourse.new(@registration).call

    redirect_to admin_courses_registrations_path
  end

  private

  def registration_params
    params.require(:courses_registration).permit(:approved)
  end
end
