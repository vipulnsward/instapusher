module Instapusher
  class CommandBuilder

    attr_reader :base

    delegate :setttings,        to: :base
    delegate :heroku_app_name,  to: :base
    delegate :callbacks,        to: :base
    delegate :job,              to: :base

    def initialize base
      @base = base
      @commands = []
    end

    def build
      add_pre_config_commands
      add_config_environment_commands
      add_before_every_install_commands
      add_callback_commands
      add_after_every_install

      commands.flatten!.compact!
      feedback_to_user
      commands
    end

    private

    def feedback_to_user
      job.add_log 'Following commands will be executed:'
      commands.each do |cmd|
        job.add_log(' '*4 + cmd)
      end
    end

    def add_after_every_install
      commands << settings.post_config_commands.after_every_install
    end

    def add_callback_commands
      callbacks.each do |callback|
        commands << settings.post_config_commands[callback]
      end
    end

    def add_before_every_install_commands
      commands << settings.post_config_commands.before_every_install
    end

    def add_pre_config_commands
      commands << settings.pre_config_commands
    end

    def add_config_environment_commands
      return unless settings.config
      config_cmd = settings.config.map { |key, value| "#{key.upcase}=#{value}" }
     commands << "bundle exec heroku config:add #{config_cmd.join(' ')} --app #{heroku_app_name}"
    end

  end
end
