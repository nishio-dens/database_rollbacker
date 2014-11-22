class DatabaseRollbacker::Savepoint
  attr_accessor :name, :savepoint_id

  def initialize(name, savepoint_id)
    @name = name
    @savepoint_id = savepoint_id
  end
end
