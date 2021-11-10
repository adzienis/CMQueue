class Forms::Courses::UserInvitation
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :given_name, :string
  attribute :family_name, :string

end
