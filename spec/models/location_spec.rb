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

describe Location do

  before(:each) do
    @origin = Location.new({:location_type=>"LO", :tiploc_code=>"EUSTON ", :activity=>"TB          ", :departure=>Time.parse('2011-01-01 15:02:00'), :platform=>"13 ", :line=>"E  ", :public_departure=>Time.parse('2011-01-01 15:02:00'), :engineering_allowance=>nil, :pathing_allowance=>nil, :tiploc_instance=>nil, :performance_allowance=>nil})
  end

  it "should require a valid set of fields for an origin location" do
    @origin.should be_valid
  end

  it "should require a location in an origin record" do
    [ nil, '', '       ' ].each do |invalid_data|
      @origin.tiploc_code = invalid_data
      @origin.should_not be_valid
    end
  end

  it "should require a valid departure time in an origin record"
  it "should require a valid public departure time in an origin record"
  it "should not allow an arrival time in an origin record"
  it "should not allow a public arrival time in an origin record"
  it "should require a valid set of fields for an intermediate location"
  it "should require a valid set of fields for a terminating location"

  it "should not allow an arrival time for an origin location"
  it "should not allow a departure time for a terminating location"

  it "should not allow a path for an origin location"
  it "should not allow a line for a terminating location"

  it "should allow only valid activities to occur at a location"

  it "should have a relationship with a Tiploc model" do
    expected_data = {:schedule=>{:insert=>23, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :tiploc=>{:insert=>19, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/location_model_relation_tiploc.cif').should eql(expected_data)
    Location.all.each do |loc|
      loc.tiploc should_not be_nil
    end
  end

end
