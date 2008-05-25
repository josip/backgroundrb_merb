namespace :bdrb do
  require 'yaml'

  desc 'Control BackgrounDRb server'
  # Or 'clt'?
  namespace :ctl do
    # Load BDRb files
    bdrb_dir = Merb.root / "gems" / "gems" / "backgroundrb_merb-1.0.3"
    $LOAD_PATH.unshift(bdrb_dir)
    $LOAD_PATH.unshift(bdrb_dir / "lib" / "backgroundrb_merb")
    $LOAD_PATH.unshift(bdrb_dir / "server" / "lib")

    # Load workers
    WORKER_ROOT = Merb.root / "app" / "workers"
    $LOAD_PATH.unshift(WORKER_ROOT)

    require 'packet'
    require 'bdrb_config.rb'
    require 'master_worker.rb'
    require 'meta_worker.rb'

#     BackgrounDRbMerb::Config.parse_cmd_options(ARGV[1..-1])
    CONFIG_FILE = BackgrounDRbMerb::Config.read_config(Merb.root / "config" / "backgroundrb.yml")
    bdrb_conf = CONFIG_FILE[:backgroundrb]
    pid_file = bdrb_dir / "pids" / "drb_#{bdrb_conf[:port]}.pid"
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

#     exit # To avoid "don't know how to build task start/stop"
  end

  desc 'Remove backgroundrb from your rails application'
  task :remove do
    script_src = "#{Merb.root}/script/backgroundrb"

    if File.exists?(script_src)
        puts "Removing #{script_src} ..."
        FileUtils.rm(script_src, :force => true)
    end

    #test_helper_src = "#{Merb.root}/test/bdrb_test_helper.rb"
    #if File.exists?(test_helper_src)
    #  puts "Removing backgroundrb test helper.."
    #  FileUtils.rm(test_helper_src,:force => true)
    #end

    workers_dest = "#{Merb.root}/app/workers"
    if File.exists?(workers_dest) && Dir.entries("#{workers_dest}").size == 2
        puts "#{workers_dest} is empty...deleting!"
        FileUtils.rmdir(workers_dest)
    end
  end
end