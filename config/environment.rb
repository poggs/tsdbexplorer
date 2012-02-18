#
#  This file is part of TSDBExplorer.
#
#  TSDBExplorer is free software: you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation, either version 3 of the License, or (at your
#  option) any later version.
#
#  TSDBExplorer is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
#  Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with TSDBExplorer.  If not, see <http://www.gnu.org/licenses/>.
#
#  $Id$
#

require File.expand_path('../application', __FILE__)
require 'tsdbexplorer'
require 'yaml'
require 'csv'

required_files = [ 'config/tsdbexplorer.yml', 'config/database.yml' ]

found_files = Array.new
missing_files = Array.new

required_files.each do |f|
  if File.exists? f
    found_files.push f
  else
    missing_files.push f
  end
end

unless missing_files.empty?
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  puts
  puts "The following files were not found:"
  puts
  missing_files.collect { |f| puts "  * #{f}" }
  puts
  puts "Please copy the example files from the config/ directory and edit them"
  puts
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  raise  
end

begin

  $CONFIG = YAML.load(File.open('config/tsdbexplorer.yml'))

rescue Errno::ENOENT

  puts "****************************************************************************"
  puts "*                                                                          *"
  puts "*  Please copy config/tsdbexplorer.yml.example to config/tsdbexplorer.yml  *"
  puts "*                                                                          *"
  puts "****************************************************************************"

  raise

end

Tsdbexplorer::Application.initialize!
