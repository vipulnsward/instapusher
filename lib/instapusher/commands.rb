require 'net/http'
require 'uri'
require 'multi_json'
require 'instapusher'

module Instapusher
  class Commands

    DEFAULT_HOSTNAME = 'instapusher.com'

    attr_reader :debug, :api_key, :branch_name, :project_name

    def initialize init_options = {}

      @debug = init_options[:debug]
      @quick = init_options[:quick]
      @local = init_options[:local]

      git          = Git.new
      @branch_name  = init_options[:project_name] || ENV['INSTAPUSHER_BRANCH'] || git.current_branch
      @project_name = init_options[:branch_name] || ENV['INSTAPUSHER_PROJECT'] || git.project_name
    end

    def options
      @options ||= begin
        { project: project_name,
          branch:  branch_name,
          quick:   @quick,
          local:   @local,
          api_key: api_key }
      end
    end

    def verify_api_key
      @api_key = ENV['API_KEY'] || Instapusher::Configuration.api_key || ""

      if @api_key.to_s.length == 0
        puts "Please enter instapusher api_key at ~/.instapusher "
      end
    end

    def url
      @url ||= begin
          hostname =  if options[:local]
                        "localhost:3000" 
                      else
                        ENV['INSTAPUSHER_HOST'] || DEFAULT_HOSTNAME
                      end
          "http://#{hostname}/heroku.json"
      end
    end

    def deploy
      verify_api_key

      if debug
        puts "url to hit: #{url.inspect}"
        puts "options being passed to the url: #{options.inspect}"
      end

      response = Net::HTTP.post_form URI.parse(url), options
      response_body  = MultiJson.load(response.body)

      puts "response_body: #{response_body.inspect}" if debug

      job_status_url = response_body['status'] || response_body['job_status_url']

      if job_status_url && job_status_url != ""
        puts 'The appliction will be deployed to: ' + response_body['heroku_url']
        puts 'Monitor the job status at: ' + job_status_url
        cmd = "open #{job_status_url}"
        `#{cmd}`
      else
        puts response_body['error']
      end
    end
  end
end
