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
#  $Id: tiploc_spec.rb 109 2011-04-19 21:03:03Z pwh $
#

require 'spec_helper'

describe Tiploc do

  it "should return details of a TIPLOC from the database" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ti.cif')
    london_euston = Tiploc.first
    expected_data = { :tiploc_code => 'EUSTON', :nalco => '144400', :nalco_four => '1444', :tps_description => 'LONDON EUSTON', :stanox => '72410', :crs_code => 'EUS', :description => 'LONDON EUSTON' }
    expected_data.each do |k,v|
      london_euston.send(k).should eql(v)
    end

  end

  it "should return all TIPLOC records which share the same NLC base as a TIPLOC" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/reading_locations.cif')
    location = Tiploc.find_by_tiploc_code('RDNGSTN')
    related_locations = location.find_related
    related_locations.count.should eql(7)

    reading_tiplocs = [ 'RDNGCE', 'RDNGSTN', 'RDNGTMD', 'RDNGWTR', 'REDG535', 'REDGDMR', 'REDGDMU' ]

    related_locations.each do |l|
      reading_tiplocs.should include(l.tiploc_code)
    end

  end

end
