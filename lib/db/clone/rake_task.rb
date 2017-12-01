module Db
  module Clone
    class RakeTask
      include Rake::DSL if defined? Rake::DSL

      def install_tasks
        return unless defined? namespace

        namespace :db do
          task :make_pgpass do
            prod_conf = ActiveRecord::Base.configurations['production']

            # This won't work correctly for the PostGIS adapter, but I'm not sure if we should call that out directly
            if prod_conf['adapter'] == 'postgresql'
              passfile = File.expand_path '~/.pgpass'
              File.open(passfile, 'w', 0600) do |f|
                f << prod_conf.values_at('host', 'port', 'database', 'username', 'password').join(':')
              end

              at_exit do
                File.delete passfile
              end
            end
          end

          desc 'clones a source database to a destination database'
          task :clone, [:manual] => [:environment, :make_pgpass] do |t, args|
            invoke_cli = !args[:manual].nil?
            Db::Clone::Base.clone! invoke_cli
          end
        end
      end
    end
  end
end
