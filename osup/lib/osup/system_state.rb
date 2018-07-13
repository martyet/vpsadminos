require 'libosctl'

module OsUp
  # Preserves system state while a migration is run
  class SystemState
    include OsCtl::Lib::Utils::Log
    include OsCtl::Lib::Utils::System

    # Create a new system state snapshot
    def self.create(*args)
      s = new(*args)
      s.create
      s
    end

    # @param pool [String]
    # @param id [String]
    # @param snapshot [Array<Symbol>] datasets to snapshot
    def initialize(pool, id, snapshot: [])
      @pool = pool
      @id = id
      @datasets = datasets_to_snapshot(snapshot)
      @snapshots = []
    end

    # Create system snapshot
    def create
      datasets.each do |ds|
        snapshots << "#{ds}@osup-pre-#{id}"
      end

      zfs(:snapshot, nil, snapshots.join(' ')) if snapshots.any?
    end

    # Changes made to the pool are solid, confirm them
    def commit
      snapshots.each do |snap|
        zfs(:destroy, nil, snap)
      end
    end

    # Revert changes to the pool by restoring original state
    def rollback
      snapshots.each do |snap|
        zfs(:rollback, '-r', snap)
        zfs(:destroy, nil, snap)
      end
    end

    def log_type
      "pool=#{pool}"
    end

    protected
    attr_reader :pool, :id, :datasets, :snapshots

    def datasets_to_snapshot(snapshot)
      ret = []

      snapshot.each do |s|
        case s
        when :conf, :log, :hook
          ret << File.join(pool, s.to_s)
        else
          fail "unsupported snapshot '#{s}'"
        end
      end

      ret
    end
  end
end
