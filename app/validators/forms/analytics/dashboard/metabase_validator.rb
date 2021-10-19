class Forms::Analytics::Dashboard::MetabaseValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.start_with? 'X'
      record.errors.add :name, "Need a name starting with X please!" if false
    end
  end
end