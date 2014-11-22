module DatabaseRollbacker::ActiveRecord; end

require 'active_record'

class DatabaseRollbacker::ActiveRecord::Rollbacker
  def initialize
    @savepoints = []
  end

  def save(savepoint_name)
    raise ArgumentError.new('duplicate savepoint name') if savepoint_exist?(savepoint_name)
    transaction_number = ActiveRecord::Base.connection.current_transaction.number
    ActiveRecord::Base.connection.begin_transaction(joinable: false)
    @savepoints.push DatabaseRollbacker::Savepoint.new(
      savepoint_name,
      transaction_number)
  end

  def rollback(savepoint_name)
    savepoint = fetch_savepoint(savepoint_name)
    raise ArgumentError.new("savepoint not found") unless savepoint.present?
    while ActiveRecord::Base.connection.current_transaction.number > 0 do
      break if ActiveRecord::Base.connection.current_transaction.number == savepoint.savepoint_id
      ActiveRecord::Base.connection.rollback_transaction
    end
    while @savepoints.present? do
      if @savepoints.last.name == savepoint.name
        @savepoints.pop
        break
      else
        @savepoints.pop
      end
    end
  end

  def clean
    while ActiveRecord::Base.connection.current_transaction.number > 0 do
      ActiveRecord::Base.connection.rollback_transaction
    end
    @savepoints = []
  end

  private

  def savepoint_exist?(savepoint_name)
    @savepoints.any? { |s| s.name == savepoint_name }
  end

  def fetch_savepoint(savepoint_name)
    @savepoints.find { |s| s.name == savepoint_name }
  end
end
