class QuestionTag < ApplicationRecord
  self.table_name = "questions_tags"
  belongs_to :question
  belongs_to :tag

end
