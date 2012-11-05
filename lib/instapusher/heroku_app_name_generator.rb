module Instapusher
  class HerokuAppNameGenerator

    attr_accessor :project_name, :branch_name

    def initialize( project_name, branch_name )
      @project_name = project_name
      @branch_name = branch_name
    end

    # heroku only allows upto 30 characters in name
    def name
      array = [sanitized_project_name, sanitized_branch_name]
      name = sanitized_app_name(array)

      if %w(production staging).include?(branch_name)
        name[0..29]
      else
        name[0..26] << "-ip"
      end
    end

    def heroku_url
      ['http://', name, '.herokuapp.com'].join('')
    end

    private

    def sanitize_app_name(array)
      array.join('-').gsub(/[^0-9a-zA-Z]+/,'-').downcase.chomp('-')
    end

    def sanitized_branch_name
      branch_name.gsub(/[^0-9a-zA-Z]+/,'-').downcase
    end

    def sanitized_project_name
      project_name.gsub(/[^0-9a-zA-Z]+/,'-').downcase
    end

  end
end

