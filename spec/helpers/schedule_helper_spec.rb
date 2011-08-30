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

describe ScheduleHelper do

  it "should convert a set of catering codes to icons" do
    # TODO: Fix wheelchair-only restaurant reservations
    expected_data = { 'C' => ['Buffet'], 'F' => ['Restaurant', '1st Class'], 'H' => ['Hot food'], 'M' => ['Meal', '1st Class'], 'P' => [''], 'R' => ['Restaurant'], 'T' => ['Trolley'] }
    expected_data.each do |k,v|
      v.each do |expected_text|
        catering_icon(k).should include(expected_text)
      end
    end
  end

  it "should handle a null catering code"
  it "should handle an invalid catering code"

end
