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

describe "lib/tsdbexplorer.rb" do

  it "should validate a correctly formatted train identity" do

    TSDBExplorer.validate_train_identity("1A99").should be_true
    TSDBExplorer.validate_train_identity("2Z00").should be_true
    TSDBExplorer.validate_train_identity("3C01").should be_true
    TSDBExplorer.validate_train_identity("9O10").should be_true

  end

  it "should reject an incorrectly formed train identity" do

    TSDBExplorer.validate_train_identity(nil).should be_false
    TSDBExplorer.validate_train_identity("").should be_false
    TSDBExplorer.validate_train_identity("0000").should be_false
    TSDBExplorer.validate_train_identity("AAAA").should be_false
    TSDBExplorer.validate_train_identity("foobarbaz").should be_false

  end

  it "should validate a correctly formatted train UID" do

    TSDBExplorer.validate_train_uid("A00000").should be_true
    TSDBExplorer.validate_train_uid("C11111").should be_true
    TSDBExplorer.validate_train_uid("Z99999").should be_true

  end

  it "should reject an incorrectly formatted train UID" do

    TSDBExplorer.validate_train_uid(nil).should be_false
    TSDBExplorer.validate_train_uid("").should be_false
    TSDBExplorer.validate_train_uid("000000").should be_false
    TSDBExplorer.validate_train_uid("AAAAAA").should be_false
    TSDBExplorer.validate_train_uid("foobarbaz").should be_false

  end

  it "should convert a date in YYYYMMDDHHMMSS format to YYYY-MM-DD HH:MM:SS" do

    TSDBExplorer.yyyymmddhhmmss_to_time("19600101120000").should eql(Time.parse("1960-01-01 12:00:00"))
    TSDBExplorer.yyyymmddhhmmss_to_time("19991231235959").should eql(Time.parse("1999-12-31 23:59:59"))
    TSDBExplorer.yyyymmddhhmmss_to_time("20000101000000").should eql(Time.parse("2000-01-01 00:00:00"))
    TSDBExplorer.yyyymmddhhmmss_to_time("20591231235959").should eql(Time.parse("2059-12-31 23:59:59"))

  end

  it "should return nil for an invalid date to be converted to YYYYMMDDHHMMSS format" do

    TSDBExplorer.yyyymmddhhmmss_to_time('00000000000000').should be_nil

  end

  it "should convert a date in DDMMYY format to YYYY-MM-DD" do

    TSDBExplorer.ddmmyy_to_date("010160").should eql("1960-01-01")
    TSDBExplorer.ddmmyy_to_date("311299").should eql("1999-12-31")
    TSDBExplorer.ddmmyy_to_date("010100").should eql("2000-01-01")
    TSDBExplorer.ddmmyy_to_date("311259").should eql("2059-12-31")

  end


  it "should convert a date in YYMMDD format to YYYY-MM-DD" do

    TSDBExplorer.yymmdd_to_date("600101").should eql("1960-01-01")
    TSDBExplorer.yymmdd_to_date("991231").should eql("1999-12-31")
    TSDBExplorer.yymmdd_to_date("000101").should eql("2000-01-01")
    TSDBExplorer.yymmdd_to_date("591231").should eql("2059-12-31")

  end

  it "should convert a time in HHMM to HH:MM" do

    TSDBExplorer.normalise_time("0000").should eql("00:00")
    TSDBExplorer.normalise_time("2359").should eql("23:59")

  end

  it "should convert a time in HHMM with an 'H' in to HH:MM:30" do

    TSDBExplorer.normalise_time("0000H").should eql("00:00:30")
    TSDBExplorer.normalise_time("2359H").should eql("23:59:30")

  end

  it "should convert an allowance time to an integer number of seconds" do

    TSDBExplorer.normalise_allowance_time("0").should eql(0)
    TSDBExplorer.normalise_allowance_time("H").should eql(30)
    TSDBExplorer.normalise_allowance_time("1").should eql(60)
    TSDBExplorer.normalise_allowance_time("1H").should eql(90)

  end

  it "should merge a date and a time in to a Time object" do

    TSDBExplorer.normalise_datetime("2011-01-01 0800").should eql(Time.parse("2011-01-01 08:00"))
    TSDBExplorer.normalise_datetime("2011-01-01 2000").should eql(Time.parse("2011-01-01 20:00"))

    TSDBExplorer.normalise_datetime("2011-01-01 0800H").should eql(Time.parse("2011-01-01 08:00:30"))
    TSDBExplorer.normalise_datetime("2011-01-01 2000H").should eql(Time.parse("2011-01-01 20:00:30"))

  end


  # Miscellaneous functions

  it "should convert a departure time in to a coded letter for a 10-character Unique Train Identity" do

    expected_data = { "0000" => "0", "0001" => "0", "0059" => "0", "0100" => "1", "0159" => "1", "0200" => "2", "0659" => "6", "0700" => "A", "0729" => "A", "0730" => "B", "0759" => "B", "0800" => "C" }

    expected_data.each do |k,v|
      TSDBExplorer::CIF::departure_to_code(k).should eql(v)
    end

  end

  it "should sort a list of Locations by their arrival, passing and departure times" do

    # Sort trains by passing time

    loc_p1 = Location.new(:tiploc_code => '1', :location_type => 'LI', :pass => '2011-01-01 12:00:00')
    loc_p2 = Location.new(:tiploc_code => '2', :location_type => 'LI', :pass => '2011-01-01 12:05:00')
    loc_p3 = Location.new(:tiploc_code => '3', :location_type => 'LI', :pass => '2011-01-01 12:10:00')

    [ loc_p3, loc_p1, loc_p2 ].sort { |a,b| TSDBExplorer::train_sort(a,b) }.should eql([ loc_p1, loc_p2, loc_p3 ])

    # Sort trains by departure time

    loc_d1 = Location.new(:tiploc_code => '1', :location_type => 'LO', :departure => '2011-01-01 12:01:00')
    loc_d2 = Location.new(:tiploc_code => '2', :location_type => 'LO', :departure => '2011-01-01 12:06:30')
    loc_d3 = Location.new(:tiploc_code => '3', :location_type => 'LO', :departure => '2011-01-01 12:11:00')

    [ loc_d3, loc_d1, loc_d2 ].sort { |a,b| TSDBExplorer::train_sort(a,b) }.should eql([ loc_d1, loc_d2, loc_d3 ])

    # Sort trains by arrival time

    loc_a1 = Location.new(:tiploc_code => '1', :location_type => 'LT', :arrival => '2011-01-01 12:02:00')
    loc_a2 = Location.new(:tiploc_code => '2', :location_type => 'LT', :arrival => '2011-01-01 12:07:30')
    loc_a3 = Location.new(:tiploc_code => '3', :location_type => 'LT', :arrival => '2011-01-01 12:12:00')

    [ loc_a3, loc_a1, loc_a2 ].sort { |a,b| TSDBExplorer::train_sort(a,b) }.should eql([ loc_a1, loc_a2, loc_a3 ])

    # Sort trains by all three

    [ loc_p1, loc_p2, loc_p3, loc_d1, loc_d2, loc_d3, loc_a1, loc_a2, loc_a3 ].sort { |a,b| TSDBExplorer::train_sort(a,b) }.should eql([ loc_p1, loc_d1, loc_a1, loc_p2, loc_d2, loc_a2, loc_p3, loc_d3, loc_a3 ])

    # Sort trains where one has an arrival and departure time, and the other has a departure time

    loc_ad1 = Location.new(:tiploc_code => '1', :location_type => 'LT', :arrival => '2011-01-01 12:02:00', :departure => '2011-01-01 12:08:00')
    loc_ad2 = Location.new(:tiploc_code => '2', :location_type => 'LT', :departure => '2011-01-01 12:07:30')

    [ loc_ad1, loc_ad2 ].sort { |a,b| TSDBExplorer::train_sort(a,b) }.should eql([ loc_ad2, loc_ad1 ])

    # Sort trains where both have an arrival and departure time, but one leaves before the other

    loc_ad1 = Location.new(:tiploc_code => '1', :location_type => 'LT', :arrival => '2011-01-01 12:02:00', :departure => '2011-01-01 12:08:00')
    loc_ad2 = Location.new(:tiploc_code => '2', :location_type => 'LT', :arrival => '2011-01-01 12:01:30', :departure => '2011-01-01 12:07:30')

    [ loc_ad1, loc_ad2 ].sort { |a,b| TSDBExplorer::train_sort(a,b) }.should eql([ loc_ad2, loc_ad1 ])

  end

end
