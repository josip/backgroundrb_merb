class WorkerGenerator < Merb::GeneratorBase
  attr_reader :worker_class_name, :worker_file_name

  def initialize(args, runtime_args = {})
    @base =             File.dirname(__FILE__)
    super
    @worker_file_name =  args.shift.snake_case
    @worker_class_name = @worker_file_name.to_const_string
  end

  def manifest
    record do |m|
      @m = m

      @assigns = {
        :worker_file_name  => worker_file_name,
        :worker_class_name => worker_class_name
      }

      copy_dirs
      copy_files

#      Not sure what is this for, tests?
#      m.dependency "merb_model_test", [model_file_name], @assigns
    end
  end

  protected
    def banner
      <<-EOS.split("\n").map{|x| x.strip}.join("\n")
        Creates a basic BackgroundRB worker in app/workers.

        USAGE: #{spec.name} worker
      EOS
    end
end
