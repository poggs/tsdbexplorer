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
    @origin = Location.new({:location_type=>"LO", :tiploc_code=>"EUSTON", :activity=>"TB", :departure=>"1502", :platform=>"13", :line=>"E  ", :public_departure=>"1502", :engineering_allowance=>nil, :pathing_allowance=>nil, :tiploc_instance=>nil, :performance_allowance=>nil})
    @intermediate = Location.new({:location_type=>"LI", :tiploc_code=>"EUSTON", :arrival=>"1502", :departure=>"1505", :platform=>"2", :line=>"C"})
    @terminate = Location.new({:location_type=>"LT", :tiploc_code=>"EUSTON", :activity=>"TF", :arrival=>"1337", :platform=>"9", :path=>nil})
  end


  # Origin location tests

  it "should require a valid set of fields for an origin location" do
    @origin.should be_valid
  end

  it "should require a location in an origin record" do
    [ nil, '', '       ' ].each do |invalid_data|
      @origin.tiploc_code = invalid_data
      @origin.should_not be_valid
    end
  end

  it "should require a valid departure time in an origin record" do
    @origin.departure = nil
    @origin.should_not be_valid
  end

  it "should not allow an arrival time for an origin location" do
    @origin.arrival = "1500"
    @origin.should_not be_valid
  end

  it "should not allow a public arrival time in an origin record" do
    @origin.public_arrival = "1500"
    @origin.should_not be_valid
  end

  it "should not allow a path for an origin location" do
    @origin.path = "XX"
    @origin.should_not be_valid
  end


  # Intermediate location tests

  it "should require a valid set of fields for an intermediate location" do
    @intermediate.should be_valid
  end

  it "should require a location in an intermediate location record" do
    [ nil, '', '       ' ].each do |invalid_data|
      @intermediate.tiploc_code = invalid_data
      @intermediate.should_not be_valid
    end
  end

  it "should be valid with an departure and arrival time" do

    original_arrival = @intermediate.arrival
    @intermediate.arrival = nil
    @intermediate.should_not be_valid
    @intermediate.arrival = original_arrival

    original_departure = @intermediate.departure
    @intermediate.departure = nil
    @intermediate.should_not be_valid

  end

  it "should be valid with a passing time" do
    @intermediate.arrival = nil
    @intermediate.departure = nil
    @intermediate.pass = "1505"
    @intermediate.should be_valid
  end

  it "should not be valid without an arrival/departure time, or a passing time" do
    @intermediate.arrival = nil
    @intermediate.departure = nil
    @intermediate.pass = nil
    @intermediate.should_not be_valid
  end

  it "should not be valid with both an arrival/departure time and a passing time" do
    @intermediate.pass = "1505"
    @intermediate.should_not be_valid
  end



  # Terminating location tests

  it "should require a valid set of fields for an terminating location record" do
    @terminate.should be_valid
  end

  it "should require a location in a terminating location record" do
    [ nil, '', '       ' ].each do |invalid_data|
      @terminate.tiploc_code = invalid_data
      @terminate.should_not be_valid
    end
  end

  it "should require a valid arrival time in a terminating location record" do
    @terminate.arrival = nil
    @terminate.should_not be_valid
  end

  it "should not allow a departure time for a terminating location" do
    @terminate.departure = "1505"
    @terminate.should_not be_valid
  end

  it "should not allow a public departure time for a terminating location" do
    @terminate.public_departure = "1505"
    @terminate.should_not be_valid
  end

  it "should not allow a line for a terminating location" do
    @terminate.line = "XX"
    @terminate.should_not be_valid
  end


  it "should allow only valid activities to occur at a location"

  it "should have a relationship with a Tiploc model" do
    expected_data = {:schedule=>{:insert=>23, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :tiploc=>{:insert=>19, :delete=>0, :amend=>0}}
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/location_model_relation_tiploc.cif').should eql(expected_data)
    Location.all.each do |loc|
      loc.tiploc should_not be_nil
    end
  end

end
