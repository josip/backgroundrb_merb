class LogWorker < Packet::Worker
  set_worker_name :log_worker
  attr_accessor :log_file

  def worker_init
    file = Merb.root / "log" / "backgroundrb_#{CONFIG_FILE[:backgroundrb][:port]}.log"
    @log_file = Merb::Logger.new(file, :debug, "", true)
  end

  def receive_data(p_data)
    case p_data[:type]
      when :request:  process_request(p_data)
      when :response: process_response(p_data)
    end
  end

  def process_request(p_data)
    log_data = p_data[:data]
    @log_file << "[I] " + log_data
  end

  def process_response
    puts "Not implemented and needed"
  end
end
