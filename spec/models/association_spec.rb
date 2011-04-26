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
#  $Id: association_spec.rb 109 2011-04-19 21:03:03Z pwh $
#

require 'spec_helper'

describe Association do

  it "should not be valid when first created" do
    assoc = Association.new
    assoc.should_not be_valid
  end

  it "should be valid with valid attributes" do
    assoc = Association.new(:main_train_uid => 'U00000', :assoc_train_uid => 'U11111', :date => '2011-01-01', :category => 'NP', :date_indicator => 'S', :location => 'EUSTON', :base_location_suffix => ' ', :assoc_location_suffix => ' ', :diagram_type => 'T', :assoc_type => 'O', :stp_indicator => 'N')
    assoc.should be_valid
  end

  # TODO: Code further Assocation model specs

end
