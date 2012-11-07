require "open3"

module Instapusher
  class Base

    attr_accessor :branch_name, :commands, :current_user, :settings, :named_branches, :job
    attr_reader :callbacks, :project_name, :heroku_app_name, :git, :config, :config_file

    def initialize(job_id, config_path, callbacks)
      @job = ::Job.find_by_id! job_id
      @callbacks = callbacks
      @git = Git.new
      @commands = []
      @config_file = File.join(config_path, 'push2heroku.yml')
      @config = ConfigLoader.new(@config_file)
      @project_name = @job.project_name
      @branch_name = @job.branch_name
      after_initialize
    end

    def push
      build_commands
      feedback_to_user
      commands.each_with_index do |cmd, index|
        job.add_log("executing: #{cmd}")
        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
          while line = stderr.gets
            job.add_log(line)
          end

          exit_status = wait_thr.value

          job.add_log("exist_status.success? is: #{exit_status.success?}")
          job.add_log("index is: #{index}")

          if !exit_status.success? && index == 1
            cmd = "git remote add  h#{branch_name} git@heroku.com:#{heroku_app_name}.git"
            job.add_log(cmd)
            unless system(cmd)
              job.update_attributes(ended_at: Time.now, status: :failed)
              raise "#{cmd} FAILED"
              job.add_log(msg)
            end
          elsif !exit_status.success? && index != 0
            job.update_attributes(ended_at: Time.now, status: :failed)
            msg = "#{cmd} FAILED"
            job.add_log(msg)
            raise msg
          end

        end
      end
    end

    private

    def after_initialize
      set_current_user_name
      set_named_branches
      set_settings
      set_heroku_app_name
      set_env
      reload_config
    end

    def set_env
      ENV['BRANCH_NAME'] = branch_name
      ENV['HEROKU_APP_NAME'] = heroku_app_name
      ENV['HEROKU_APP_URL'] = "http://#{heroku_app_name}.herokuapp.com"
      ENV['APP_URL'] = @settings.app_url ? @settings.app_url : ENV['HEROKU_APP_URL']
    end

    def set_current_user_name
      @current_user = git.current_user
    end

    def set_named_branches
      @named_branches = config.named_branches
    end

    def set_settings
      @settings = config.settings(branch_name)
    end

    def set_heroku_app_name
      @heroku_app_name =  HerokuAppNameGenerator.new( project_name, branch_name).name
    end

    def reload_config
      @config = ConfigLoader.new(config_file)
      set_settings
    end

    def sanitized_user_name
      current_user || 'ip'
    end

    def build_commands
      commands << settings.pre_config_commands
      build_config_environment_commands
      add_before_every_install
      add_callback_commands
      add_after_every_install

      if public_url = settings.public_url
        commands << "open http://#{public_url}"
      else
        commands << "bundle exec heroku open --app #{heroku_app_name}"
      end

      commands.flatten!.compact!
    end

    def add_before_every_install
      if cmd = settings.post_config_commands.before_every_install
        commands << cmd
      end
    end

    def add_after_every_install
      if cmd = settings.post_config_commands.after_every_install
        commands << cmd
      end
    end

    def add_callback_commands
      callbacks.each do |callback|
        commands << settings.post_config_commands[callback]
      end
    end

    def build_config_environment_commands
      return unless settings.config
      cmd = []
      settings.config.each do |key, value|
        if String === value && !value.strip.empty?
          cmd << "#{key.upcase}=#{value}"
        else
          cmd << "#{key.upcase}=#{value}"
        end
      end
     commands << "bundle exec heroku config:add #{cmd.join(' ')} --app #{heroku_app_name}"
    end

    def feedback_to_user
      job.add_log 'Following commands will be executed:'
      commands.each do |cmd|
        job.add_log(' '*4 + cmd)
      end
    end
  end
end
