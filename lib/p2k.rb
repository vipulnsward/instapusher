require "p2k/version"
require "hashr"

module P2k
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :ConfigLoader
  autoload :Git
  autoload :Util
end

require 'p2k/railtie'
