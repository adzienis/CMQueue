# app/controllers/oauth/applications_controller.rb
class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_action do
    @course = Course.find(params[:course_id]) if params[:course_id]
  end

  def index
    @applications = current_user.applications unless params[:course_id]
    @applications = Doorkeeper::Application.where(owner_id: params[:course_id], owner_type: "Course") if params[:course_id]
  end

  # only needed if each application must have some owner
  def create
    @application = Doorkeeper::Application.new(application_params)
    @application.owner = current_user unless params[:course_id]
    @application.owner = Course.find(params[:course_id]) if params[:course_id]

    if @application.save
      redirect_to oauth_course_application_url(Course.find(params[:course_id]),@application)
    else
      render :new
    end
  end

  def update
    if @application.update(application_params)
      flash[:notice] = I18n.t(:notice, scope: i18n_scope(:update))

      respond_to do |format|
        format.html { redirect_to oauth_application_url(Course.find(params[:course_id]), @application) }
        format.json { render json: @application, as_owner: true }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json do
          errors = @application.errors.full_messages

          render json: { errors: errors }, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    flash[:notice] = I18n.t(:notice, scope: i18n_scope(:destroy)) if @application.destroy

    respond_to do |format|
      format.html { redirect_to oauth_course_applications_url(@course) }
      format.json { head :no_content }
    end
  end

  private

  def set_application
    @application = current_user.applications.find_by(id: params[:id]) unless params[:course_id]
    @application = Doorkeeper::Application.where(owner_id: params[:course_id], owner_type: "Course").find(params[:id]) if params[:course_id]
  end

end
