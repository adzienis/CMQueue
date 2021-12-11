class AddStateConstraintTrigger < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
                        CREATE or replace FUNCTION check_state_constraint()
                        RETURNS trigger AS
                        $$
                        DECLARE
                          state bigint;
                        BEGIN
      LOCK question_states IN ACCESS EXCLUSIVE MODE;
                          state := (select question_states.state from question_states where question_states.id =#{" "}
                          (select max(question_states.id) from question_states
                            inner join questions on questions.id = NEW.question_id
                            WHERE questions.discarded_at IS NOT NULL));
                        if state IS NULL OR (state != NEW.state)  then
                        return NEW;
                        end if;
                        raise exception 'question already transitioned to same state';
                        END
                        $$ LANGUAGE plpgsql;
                      create trigger check_state_constraint_trigger before insert on question_states for each row
                      execute procedure check_state_constraint();
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION if exists check_state_constraint cascade;
      DROP TRIGGER if exists check_state_constraint_trigger on question_states;
    SQL
  end
end
