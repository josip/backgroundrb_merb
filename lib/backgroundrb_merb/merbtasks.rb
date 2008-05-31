namespace :bdrb do
  require 'yaml'

  BDRB_DIR = File.expand_path(File.dirname(__FILE__) + '/../../')

  unless File.exists?(Merb.root/"config"/"backgroundrb.yml") then
    desc 'Create config file'
    task :setup do
      template = BDRB_DIR/"config"/"backgroundrb.yml"
      FileUtils.cp(template, Merb.root/"config")
      puts "Created #{Merb.root}/config/backgroundrb.yml"
    end
  else
    desc 'Control BackgrounDRb server'
    namespace :ctl do
      $LOAD_PATH.unshift(BDRB_DIR)
      $LOAD_PATH.unshift(BDRB_DIR / "lib" / "backgroundrb_merb")
      $LOAD_PATH.unshift(BDRB_DIR / "server" / "lib")

      WORKER_ROOT = Merb.root / "app" / "workers"
      $LOAD_PATH.unshift(WORKER_ROOT)

      require 'bdrb_config.rb'
      require 'master_worker.rb'
      require 'log_worker.rb'
      require 'meta_worker.rb'

#     BackgrounDRbMerb::Config.parse_cmd_options(ARGV[1..-1])
      CONFIG_FILE = BackgrounDRbMerb::Config.read_config(Merb.root / "config" / "backgroundrb.yml")
      bdrb_conf = CONFIG_FILE[:backgroundrb]
      pid_file = BDRB_DIR / "pids" / "drb_#{bdrb_conf[:port]}.pid"
      SERVER_LOGGER = Merb.root / "log" / "bdrb_server_#{bdrb_conf[:port]}.log"


      desc 'Start and detach from console'
      task :daemonize do
        if fork then
          exit
        else
          File.open(pid_file, 'w') {|f| f << Process.pid.to_s}
          if bdrb_conf[:log].nil? or bdrb_conf[:log] != 'foreground' then
            log_file = File.open(SERVER_LOGGER, 'w+')
            [STDIN, STDOUT, STDERR].each {|dev| dev.reopen(log_file)}
          end

          BackgrounDRbMerb::MasterProxy.new
        end
        exit
      end

      desc 'Stop BackgrounDRb'
      task :stop do
        pid = nil
        File.open(pid_file, 'r') {|f| pid = f.gets.strip.chomp.to_i}

        begin
          pgid = Process.getpgid(pid)
          Process.kill('TERM', pid)
          Process.kill('-TERM', pgid)
          Process.kill('KILL', pid)
        rescue Errno::ESRCH => e
          puts "Deleting pid file"
        rescue
          puts $!
        ensure
          File.delete(pid_file) if File.exists?(pid_file)
        end
        exit
      end

      desc 'Start BackgrounDRb'
      task :start do
        BackgrounDRbMerb::MasterProxy.new
      end
    end

    desc 'Remove BackgroundRB from your app'
    task :remove do
      [Merb.root/"app"/"workers", Merb.root/"spec"/"workers"].each do |dir|
        if File.exists?(dir) && Dir.entries(dir).size == 2
            puts "#{dir} is empty...deleting!"
            sleep 0.5
            FileUtils.rmdir(dir)
        end
      end
      FileUtils.rm(Merb.root/"config"/"backgroundrb.yml")

      puts %{Don't forget to remove "require 'backgroundrb_merb'" from your init.rb!}
    end
  end
end