require "active_support"

module Instapusher
  extend ActiveSupport::Autoload
  autoload :Git
end

require 'instapusher/railtie'
