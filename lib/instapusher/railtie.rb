module Instapusher
  class Engine < Rails::Engine

    rake_tasks do
      require 'net/http'
      require 'uri'
      require 'multi_json'


      desc "pushes to heroku"
      task :instapusher do

        if ENV['LOCAL']
          URL = 'http://localhost:3000/heroku'
        else
          URL = 'http://instapusher.com/heroku'
        end

        branch_name = Git.new.current_branch
        project_name = File.basename(Dir.getwd)

        response = Net::HTTP.post_form(URI.parse(URL), { project: project_name,
                                                         branch: branch_name,
                                                         local: ENV['LOCAL'],
                                                         'options[callbacks]' => ENV['CALLBACKS']})

        if response.code == '200'
          tmp = MultiJson.load(response.body)
          status_url = tmp['status']
          status_url = status_url.gsub('instapusher.com','localhost:3000') if ENV['LOCAL']
          puts 'The appliction will be deployed to: ' +  tmp['heroku_url']
          puts 'Monitor the job status at: ' +  status_url
        else
          puts 'Something has gone wrong'
        end
      end
    end

  end
end
