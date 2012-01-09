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

describe StationName do

  it "should return a list of related TIPLOCs, given a CRS code" do
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/watford_junction.msn')
    related = StationName.find_related('WFJ').collect { |s| s.tiploc_code }
    related.should have_exactly(2).items
    related.should include('WATFDJ')
    related.should include('WATFJDC')
  end

end
