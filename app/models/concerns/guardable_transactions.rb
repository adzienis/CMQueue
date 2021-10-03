module GuardableTransactions
  extend ActiveSupport::Concern

  private

  def promote_errors(child)
    child.errors.each do |attribute, message|
      errors.add(attribute, message)
    end
  end

  def guard_db(&block)
    result = begin
               transaction do
                 result = yield
                 validate!
                 result
               end
             rescue ActiveRecord::RecordInvalid => error
               error
             end
    if result.instance_of? Exception
      if result.instance_of? ActiveRecord::RecordInvalid
        promote_errors(result.record)
      else
        nil
      end
    end
    reload and result
  end

end