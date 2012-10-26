require "hpusher/version"
require "hashr"

module Hpusher
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :ConfigLoader
  autoload :Git
  autoload :Util
end

require 'hpusher/railtie'
