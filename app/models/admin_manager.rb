class AdminManager < ApplicationRecord
  has_many :settings, as: :resource, dependent: :destroy

  after_create_commit do
    settings.create([{
                       value: {
                         login: {
                           label: "Login Allowed",
                           value: false,
                           description: "Allow logging in to the website.",
                           type: "boolean"
                         }
                       }
                     }])
  end


  def singleton
    first
  end


end
