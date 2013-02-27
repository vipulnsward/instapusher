require 'net/http'
require 'uri'
require 'multi_json'
require 'instapusher'

module Instapusher
  class Commands
    DEFAULT_HOSTNAME = 'instapusher.com'

    def self.deploy

      hostname = ENV['INSTAPUSHER_HOST'] || DEFAULT_HOSTNAME

      #TODO: Remove this env and use host instead of duplication
      if ENV['LOCAL']
        hostname = "localhost:3000"
      end
      url = "http://#{hostname}/heroku"


      git = Git.new
      branch_name  = git.current_branch
      project_name = git.project_name

      response = Net::HTTP.post_form(URI.parse(url),
                                     { project:             project_name,
                                       branch:              branch_name,
                                       local:               ENV['LOCAL'],
                                       'options[callbacks]' => ENV['CALLBACKS'] })

      if response.code == '200'
        response_body = MultiJson.load(response.body)
        status_url    = response_body['status']

        status_url = status_url.gsub(DEFAULT_HOSTNAME, hostname) if ENV['LOCAL']
        puts 'The appliction will be deployed to: ' + response_body['heroku_url']
        puts 'Monitor the job status at: ' + status_url
        cmd = "open #{status_url}"
        `#{cmd}`
      else
        puts 'Something has gone wrong'
      end
    end
  end
end