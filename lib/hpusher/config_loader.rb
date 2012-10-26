module Hpusher
  class ConfigLoader

    attr_reader :filename, :hash

    def initialize(filename)
      @filename = filename
      @hash = load_config
    end

    def settings(branch_name)
      common_hash = hash['common'] || {}
      env_hash = hash[branch_name.to_s] || {}
      final_hash = common_hash.deep_merge(env_hash)
      Hashr.new(final_hash)
    end

    def named_branches
      hash.keys - ['common']
    end

    private

    def load_config
      unless File.exists? filename
        puts "you do not have config/hpusher.yml file. Please execute "
        puts "rails generate hpusher:install"
        abort
      end
      YAML.load(ERB.new(File.read(filename)).result)
    end

  end
end
