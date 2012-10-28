require "instapusher/version"
require "hashr"

module Instapusher
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :ConfigLoader
  autoload :Git
  autoload :Util
end

require 'instapusher/railtie'
