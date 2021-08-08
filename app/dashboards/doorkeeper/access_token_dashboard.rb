require "administrate/base_dashboard"

class Doorkeeper::AccessTokenDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    application: Field::BelongsTo,
    resource_owner: Field::Polymorphic,
    id: Field::Number,
    token: Field::String,
    refresh_token: Field::String,
    expires_in: Field::Number,
    revoked_at: Field::DateTime,
    created_at: Field::DateTime,
    scopes: Field::String,
    previous_refresh_token: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    application
    resource_owner
    id
    token
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    application
    resource_owner
    id
    token
    refresh_token
    expires_in
    revoked_at
    created_at
    scopes
    previous_refresh_token
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    application
    resource_owner
    token
    refresh_token
    expires_in
    revoked_at
    scopes
    previous_refresh_token
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how access tokens are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(access_token)
  #   "Doorkeeper::AccessToken ##{access_token.id}"
  # end
end
