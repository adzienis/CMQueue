module GuardableTransactions
  extend ActiveSupport::Concern

  private

  def promote_errors(association:nil, child:)
    child.errors.each do |attribute, message|
      if association.present?
        send(association).errors.add(attribute, message)
        errors.add(association, "is invalid")
      else
        errors.add(attribute, message)
      end
    end
  end

  def guard_db(association:nil, &block)
    result = begin
               ActiveRecord::Base.transaction do
                 yield
                 validate!
                 nil
               end
             rescue Exception => error
               error
             end
    if result.is_a? Exception
      if result.is_a? ActiveRecord::RecordInvalid
        promote_errors(association: association, child: result.record)
      end
      result
    else
      false
    end
  end

end
