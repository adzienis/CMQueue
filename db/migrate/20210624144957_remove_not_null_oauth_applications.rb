class RemoveNotNullOauthApplications < ActiveRecord::Migration[6.1]
  def change
    change_column_null :oauth_applications, :redirect_uri, true
  end
end
