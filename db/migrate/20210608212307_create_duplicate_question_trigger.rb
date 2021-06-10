class CreateDuplicateQuestionTrigger < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE or replace FUNCTION check_duplicate_question()
      RETURNS trigger AS
      $$
      DECLARE
        state integer;
      BEGIN
        state := (select question_states.state from question_states where question_states.id = 
        (select max(question_states.id) from question_states 
          inner join questions on questions.id = question_states.question_id 
          where questions.user_id = NEW.user_id));
      
      if (state in (2,4)) then
      return NEW;
      end if;
      
      raise exception 'question already exists';
      
      
      END
      $$ LANGUAGE plpgsql;


    create trigger check_duplicate_question_trigger before insert on questions for each row
    execute procedure check_duplicate_question();
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION if exists check_duplicate_question cascade;
      DROP TRIGGER if exists check_duplicate_question on questions;
    SQL
  end
end
