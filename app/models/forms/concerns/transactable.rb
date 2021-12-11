module Forms::Concerns::Transactable
  extend ActiveSupport::Concern

  included do
    def guard_transaction
      ActiveRecord::Base.transaction do
        yield
      end
    rescue ActiveRecord::RecordInvalid => e
      promote_errors(e.record) and return false
    ensure
      true
    end
  end
end
