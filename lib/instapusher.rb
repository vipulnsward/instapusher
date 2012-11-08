require "instapusher/version"
require "hashr"

module Instapusher
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :ConfigLoader
  autoload :Git
  autoload :Util
  autoload :HerokuAppNameGenerator
  autoload :Executor
  autoload :CommandBuilder
end

require 'instapusher/railtie'
