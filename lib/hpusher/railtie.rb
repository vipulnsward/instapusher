module Hpusher
  class Engine < Rails::Engine

    rake_tasks do
      require 'net/http'
      require 'uri'
      require 'multi_json'

      HPUSHER_URL = 'http://74.207.237.77/heroku'

      desc "pushes to heroku"
      task :hpusher do
        branch_name = Git.new.current_branch
        project_name = File.basename(Dir.getwd)

        response = Net::HTTP.post_form(URI.parse(HPUSHER_URL), { project: project_name, branch: branch_name, 'options[callbacks]' => ENV['CALLBACKS']})

        if response.code == '200'
          tmp = MultiJson.load(response.body)
          puts 'The appliction will be deployed to: ' +  tmp['heroku_url']
          puts 'Monitor the job status at: ' +  tmp['status']
        else
          puts 'Something has gone wrong'
        end
      end
    end

  end
end
