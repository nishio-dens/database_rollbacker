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
      require 'database_rollbacker/active_record/rollbacker.rb'
      DatabaseRollbacker::ActiveRecord::Rollbacker.new
    elsif defined? ::DataMapper
      require 'database_rollbacker/data_mapper/rollbacker.rb'
      DatabaseRollbacker::DataMapper::Rollbacker.new
    end
  end
end
