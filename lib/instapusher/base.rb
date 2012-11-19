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
      @config_file = File.join(config_path, 'instapusher.yml')
      @config = ConfigLoader.new(@config_file)
      @project_name = @job.project_name
      @branch_name = @job.branch_name
      after_initialize
    end

    def push
      CommandBuilder.new(self).build.each_with_index do |cmd, index|
        Executor.new(self).execute(cmd, index)
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

  end
end
