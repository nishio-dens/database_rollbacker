module DatabaseRollbacker::DataMapper; end

class DatabaseRollbacker::DataMapper::Rollbacker
  def initialize
    @savepoints = []
    @repository = :default
  end

  def save(savepoint_name)
    raise ArgumentError.new('duplicate savepoint name') if savepoint_exist?(savepoint_name)
    DataMapper.repository(@repository) do |repository|
      transaction = DataMapper::Transaction.new(repository)
      transaction.begin
      repository.adapter.push_transaction(transaction)
      transaction_id = transaction
        .instance_variable_get("@transaction_primitives")
        .values
        .find { |v| v.is_a? DataObjects::SavePoint }
        .id
      @savepoints.push DatabaseRollbacker::Savepoint.new(
        savepoint_name,
        transaction_id)
    end
  end

  def rollback(savepoint_name)
    savepoint = fetch_savepoint(savepoint_name)
    raise ArgumentError.new("savepoint not found") unless savepoint.present?
    DataMapper.repository(@repository) do |repository|
      adapter = repository.adapter
      while adapter.current_transaction
        transaction_id = adapter
          .current_transaction
          .instance_variable_get("@transaction_primitives")
          .values
          .find { |v| v.is_a? DataObjects::SavePoint }
          .id
        adapter.current_transaction.rollback
        adapter.pop_transaction
        break if transaction_id == savepoint.savepoint_id
      end
      while @savepoints.present? do
        last_savepoint_name = @savepoints.last.name
        @savepoints.pop
        break if last_savepoint_name == savepoint_name
      end
    end
  end

  def clean
    DataMapper.repository(@repository) do |repository|
      adapter = repository.adapter
      while adapter.current_transaction do
        adapter.current_transaction.rollback
        adapter.pop_transaction
      end
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
