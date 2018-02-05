module OsCtld
  module RunState
    RUNDIR = '/run/osctl'
    POOL_DIR = File.join(RUNDIR, 'pools')
    USER_CONTROL_DIR = File.join(RUNDIR, 'user-control')
    MIGRATION_DIR = File.join(RUNDIR, 'migration')

    def self.create
      Dir.mkdir(RUNDIR, 0711) unless Dir.exists?(RUNDIR)
      Dir.mkdir(POOL_DIR, 0711) unless Dir.exists?(POOL_DIR)
      Dir.mkdir(USER_CONTROL_DIR, 0711) unless Dir.exists?(USER_CONTROL_DIR)

      unless Dir.exists?(MIGRATION_DIR)
        Dir.mkdir(MIGRATION_DIR, 0100)
        File.chown(Migration::UID, 0, MIGRATION_DIR)
      end
    end

    def self.assets(add)
      add.directory(
        RunState::RUNDIR,
        desc: 'Runtime configuration',
        owner: 0,
        group: 0,
        mode: 0711
      )
      add.directory(
        RunState::POOL_DIR,
        desc: 'Runtime pool configuration',
        owner: 0,
        group: 0,
        mode: 0711
      )
      add.directory(
        RunState::USER_CONTROL_DIR,
        desc: 'Runtime user configuration',
        owner: 0,
        group: 0,
        mode: 0711
      )
      add.directory(
        RunState::MIGRATION_DIR,
        desc: 'Migration configuration',
        owner: Migration::UID,
        group: 0,
        mode: 0100,
        optional: true
      )

      Migration.assets(add)
    end
  end
end
