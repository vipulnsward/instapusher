module Instapusher
  class Executor

    attr_accessor :base

    delegate :job,              to: :base

    def initialize base
      @base = base
    end

    def execute cmd, index
      job.add_log("executing: #{cmd}")
      handle_error unless execute_using_popen3
    end

    private

    def handle_failure
      job.update_attributes(ended_at: Time.now, status: :failed)
      msg = "#{cmd} FAILED"
      job.add_log(msg)
      raise msg
    end

    # returns false if command fails
    def execute_using_popen3
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        while line = stdout.gets
          job.add_log(line)
        end
        while line = stderr.gets
          job.add_log(line)
        end

        exit_status = wait_thr.value

        job.add_log("exist_status.success? is: #{exit_status.success?}")
        job.add_log("index is: #{index}")

        success = exit_status.success?
        failure = !success

        if failure && index == 1
          cmd = "git remote add  h#{branch_name} git@heroku.com:#{heroku_app_name}.git"
          job.add_log(cmd)
          return false unless system(cmd)
        elsif failure && index != 1
          return false
        end

        true
      end
    end

  end
end
