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

describe ApplicationHelper do

  it "should convert a Time object representing a whole minute to HHMM format using the 24 hour clock" do    
    time_only(Time.parse('2011-01-01 09:00:00')).should eql('0900')
    time_only(Time.parse('2011-01-01 19:00:00')).should eql('1900')
  end

  it "should convert a Time object representing a half minute to HHMM format using the 24 hour clock" do
    time_only(Time.parse('2011-01-01 09:00:30')).should eql('0900H')
    time_only(Time.parse('2011-01-01 19:00:30')).should eql('1900H')
  end

end
