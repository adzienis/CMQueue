module Forms
  def self.use_relative_model_naming?
    true
  end

  module Courses
    class Registration
      include ActiveModel::Model

      attr_accessor :name, :instructor_id

      validate :name_unique

      def initialize(**params)
        super(params)
      end

      def save
        return unless valid?

        ::Courses::Registration.create!(instructor_id: instructor_id, name: name)
      end

      private

      def name_unique
        errors.add(:name, "is not unique") if Course.find_by(name: name).present?
      end
    end
  end
end
