require 'singleton'

class DatabaseRollbacker::Rollbacker
  include Singleton

  def initialize
    @rollbacker = detect_rollbacker
  end

  def save(savepoint_name)
    @rollbacker.save(savepoint_name)
  end

  def rollback(savepoint_name)
    @rollbacker.rollback(savepoint_name)
  end

  def clean
    @rollbacker.clean
  end

  private

  def detect_rollbacker
    if defined? ::ActiveRecord
      DatabaseRollbacker::ActiveRecord::Rollbacker.new
    elsif defined? ::DataMapper
      DatabaseRollbacker::DataMapper::Rollbacker.new
    end
  end
end
