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

describe "lib/tsdbexplorer/geography.rb" do

  it "should process a set of ELR records" do

    GeoElr.count.should eql(0)
    TSDBExplorer::Geography.import_static_data('test/fixtures/geography')
    GeoElr.count.should eql(4)

    first_elr = GeoElr.first
    first_elr.elr_code.should eql('AAA')
    first_elr.line_name.should eql('Alpha Junction - Bravo Branch')

  end

  it "should process a set of locations" do

    GeoPoint.count.should eql(0)
    TSDBExplorer::Geography.import_static_data('test/fixtures/geography')
    GeoPoint.count.should eql(4)

    first_point = GeoPoint.first
    first_point.location_name.should eql('Alpha Junction')
    first_point.route_code.should eql('AA123')
    first_point.elr_code.should eql('AAA')
    first_point.miles.should eql(0)
    first_point.chains.should eql(0)

  end

end
