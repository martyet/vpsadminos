module OsCtld
  class Commands::Group::Delete < Commands::Logged
    handle :group_delete

    def find
      grp = DB::Groups.find(opts[:name], opts[:pool])
      error!('group not found') unless grp
      error!('group is used by containers') if grp.has_containers?
      grp
    end

    def execute(grp)
      DB::Groups.sync do
        grp.exclusively do
          # Double-check user's containers, for only within the lock
          # can we be sure
          return error('group is used by containers') if grp.has_containers?

          File.unlink(grp.config_path)
        end

        DB::Groups.remove(grp)
      end

      ok
    end
  end
end
