module OsCtld
  module Commands
    module Container ; end
    module Event ; end
    module Group ; end
    module History ; end
    module Migration ; end
    module NetInterface ; end
    module Pool ; end
    module Self ; end
    module User ; end
  end
  module DB ; end
  module Generic ; end
  module Routing ; end
  module Utils ; end
  module UserControl
    module Commands ; end
  end
  module Zfs ; end

  def self.root
    File.join(File.dirname(__FILE__), '..')
  end

  def self.bin(name)
    File.absolute_path(File.join(root, 'bin', name))
  end

  def self.hook_src(name)
    File.absolute_path(File.join(root, 'hooks', name))
  end

  def self.hook_run(name, pool)
    File.join(pool.hook_dir, name)
  end

  def self.script(name)
    File.absolute_path(File.join(root, 'scripts', name))
  end

  def self.tpl(name)
    File.absolute_path(File.join(root, 'templates', "#{name}.erb"))
  end
end

require_relative 'osctld/version'
require_relative 'osctld/logger'
require_relative 'osctld/exceptions'
require_relative 'osctld/template'
require_relative 'osctld/lockable'
require_relative 'osctld/db/list'
require_relative 'osctld/run_state'
require_relative 'osctld/utils/log'
require_relative 'osctld/utils/system'
require_relative 'osctld/utils/zfs'
require_relative 'osctld/utils/switch_user'
require_relative 'osctld/utils/ip'
require_relative 'osctld/utils/cgroup_params'
require_relative 'osctld/utils/assets'
require_relative 'osctld/utils/migration'
require_relative 'osctld/zfs/stream'
require_relative 'osctld/event'
require_relative 'osctld/eventd'
require_relative 'osctld/history'
require_relative 'osctld/generic/server'
require_relative 'osctld/generic/client_handler'
require_relative 'osctld/user_control/supervisor'
require_relative 'osctld/user_control'
require_relative 'osctld/cgroup'
require_relative 'osctld/cgroup/params'
require_relative 'osctld/prlimit'
require_relative 'osctld/mount'
require_relative 'osctld/command'
require_relative 'osctld/user_control/command'

require_relative 'osctld/assets'
require_relative 'osctld/assets/base'
require_relative 'osctld/assets/base_file'
Dir.glob(File.join(
  File.dirname(__FILE__),
  'osctld', 'assets', '*.rb'
)).each { |f| require_relative f unless f.end_with?('definition.rb') }
require_relative 'osctld/assets/definition'

require_relative 'osctld/db/pools'
require_relative 'osctld/pool'
require_relative 'osctld/db/pooled_list'
require_relative 'osctld/db/containers'
require_relative 'osctld/container'
require_relative 'osctld/container/builder'
require_relative 'osctld/container/exporter'
require_relative 'osctld/container/importer'
require_relative 'osctld/db/users'
require_relative 'osctld/user'
require_relative 'osctld/db/groups'
require_relative 'osctld/group'
require_relative 'osctld/monitor'
require_relative 'osctld/monitor/process'
require_relative 'osctld/monitor/master'
require_relative 'osctld/routing/via'
require_relative 'osctld/routing/via_ipv4'
require_relative 'osctld/routing/via_ipv6'
require_relative 'osctld/net_interface'
require_relative 'osctld/net_interface/base'
require_relative 'osctld/net_interface/veth'
require_relative 'osctld/net_interface/bridge'
require_relative 'osctld/net_interface/routed'
require_relative 'osctld/console'
require_relative 'osctld/console/tty'
require_relative 'osctld/console/console'
require_relative 'osctld/console/container'
require_relative 'osctld/migration'
require_relative 'osctld/migration/server'
require_relative 'osctld/migration/key_chain'
require_relative 'osctld/migration/log'
require_relative 'osctld/migration/command'
require_relative 'osctld/dist_config'
require_relative 'osctld/dist_config/base'
require_relative 'osctld/dist_config/debian'
require_relative 'osctld/dist_config/ubuntu'
require_relative 'osctld/dist_config/alpine'
require_relative 'osctld/dist_config/unsupported'
require_relative 'osctld/daemon'
require_relative 'osctld/switch_user'
require_relative 'osctld/switch_user/container_control'

require_relative 'osctld/commands/base'
require_relative 'osctld/commands/logged'
Dir.glob(File.join(
  File.dirname(__FILE__),
  'osctld', 'commands', '*', '*.rb'
)).each { |f| require_relative f }

require_relative 'osctld/user_control/commands/base'
Dir.glob(File.join(
  File.dirname(__FILE__),
  'osctld', 'user_control', 'commands', '*.rb'
)).each { |f| require_relative f }

require_relative 'osctld/migration/commands/base'
Dir.glob(File.join(
  File.dirname(__FILE__),
  'osctld', 'migration', 'commands', '*.rb'
)).each { |f| require_relative f }
