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

      api_key = Instapusher::Configuration.api_key || ""

      options = { project:             project_name,
                  branch:              branch_name,
                  local:               ENV['LOCAL'],
                  api_key:             api_key }

      response = Net::HTTP.post_form URI.parse(url), options

      response_body = MultiJson.load(response.body)
      job_status_url    = response_body['status']

      if job_status_url && job_status_url != ""
        job_status_url = job_status_url.gsub(DEFAULT_HOSTNAME, hostname) if ENV['LOCAL']
        puts 'The appliction will be deployed to: ' + response_body['heroku_url']
        puts 'Monitor the job status at: ' + job_status_url
        cmd = "open #{job_status_url}"
        `#{cmd}`
      else
        puts response_body['error_message']
      end
    end
  end
end
