require "instapusher/version"

module Instapusher
  extend ActiveSupport::Autoload
  autoload :Git
end

require 'instapusher/railtie'
