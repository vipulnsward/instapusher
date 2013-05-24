require_relative "../instapusher"
require 'net/http'
require 'uri'

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

    def special_instructions_for_production
      question = "You are deploying to production. Did you take backup? If not then execute rake handy:heroku:backup_production and then come back. "
      STDOUT.puts question
      STDOUT.puts "Answer 'yes' or 'no' "
      
      input = STDIN.gets.chomp.downcase

        if %w(yes y).include?(input)
        elsif %w(no n).include?(input)
          abort "Please try again when you have taken the backup"
        else
          abort "Please answer yes or no"
        end

      version_number = Time.current.to_s.parameterize


      cmd = "git tag -a -m \"Version #{version_number}\" #{version_number}"
      puts cmd if debug
      system cmd

      cmd =  "git push --tags"
      puts cmd if debug
      system cmd
    end

    def deploy
      verify_api_key
      special_instructions_for_production if branch_name.intern == :production

      if debug
        puts "url to hit: #{url.inspect}"
        puts "options being passed to the url: #{options.inspect}"
        puts "connecting to #{url} to send data"
      end

      
      response = Net::HTTP.post_form URI.parse(url), options
      response_body  = ::JSON.parse(response.body)

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
