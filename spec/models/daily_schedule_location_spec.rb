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

require 'spec_helper'

describe DailyScheduleLocation do

  it "should not be valid when first created" do
    record = DailyScheduleLocation.new
    record.should_not be_valid
  end

  it "should have a method which identifies if the location should be publically advertised"
  it "should have a method which identifies if this location is to pick-up passengers only"
  it "should have a method which identifies if this location is to set down passengers only"
  it "should have a method which identifies if this location is the originating point of the schedule"
  it "should hvae a method which identifies if this location is the terminating point of the schedule"

end
