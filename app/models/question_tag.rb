# == Schema Information
#
# Table name: questions_tags
#
#  id          :bigint           not null, primary key
#  question_id :bigint
#  tag_id      :bigint
#
class QuestionTag < ApplicationRecord
  self.table_name = "questions_tags"
  belongs_to :question, touch: true
  has_one :course, through: :question
  belongs_to :tag
end
