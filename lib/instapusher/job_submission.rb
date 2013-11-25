class JobSubmission

  attr_reader :options, :debug, :job_status_url

  DEFAULT_HOSTNAME = 'instapusher.com'

  def initialize debug, options
    @debug = debug
    @options = options
  end

  def success?
    job_status_url && job_status_url != ""
  end

  def pre_submission_feedback_to_user
    puts "url to hit: #{url_to_submit_job.inspect}"
    puts "options being passed to the url: #{options.inspect}"
    puts "connecting to #{url_to_submit_job} to send data"
  end

  def feedback_to_user
    puts 'The application will be deployed to: ' + response_body['heroku_url']
    puts 'Monitor the job status at: ' + job_status_url
    cmd = "open #{job_status_url}"
    `#{cmd}`
  end

  def error_message
    response_body['error']
  end

  def submit_the_job
    pre_submission_feedback_to_user if debug

    response = Net::HTTP.post_form URI.parse(url_to_submit_job), options
    @response_body  = ::JSON.parse(response.body)
    puts "response_body: #{response_body.inspect}" if debug
    @job_status_url = response_body['status'] || response_body['job_status_url']
  end

  def url_to_submit_job
    @url ||= begin
        hostname =  if options[:local]
                      "localhost:3000" 
                    else
                      ENV['INSTAPUSHER_HOST'] || DEFAULT_HOSTNAME
                    end
        "http://#{hostname}/heroku.json"
    end
  end
end
