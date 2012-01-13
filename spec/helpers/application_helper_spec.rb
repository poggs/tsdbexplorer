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

  it "should convert a train class in to text" do
    decode_train_class('B').should_not be_nil
    decode_train_class('S').should_not be_nil
  end

  it "should gracefully handle an unknown train class" do
    decode_train_class(nil).should eql('Unknown')
    decode_train_class('').should eql('Unknown')
    decode_train_class('$').should eql('$: Unknown')
  end

  it "should convert a train status in to text" do
    decode_train_status('P').should eql('P: Passenger/Parcels')
    decode_train_status('1').should eql('1: Passenger/Parcels (STP)')
  end

  it "should gracefully handle an unknown train status" do
    decode_train_status('$').should eql('$: Unknown')
  end

  it "should convert a reservation status in to text" do
    decode_reservations(' ').should eql('not available')
    decode_reservations(nil).should eql('not available')
    decode_reservations('A').should eql('compulsory')
    decode_reservations('S').should eql('possible')
  end

  it "should gracefully handle an unknown reservation status" do
    decode_reservations('$').should eql('unknown')
  end

  it "should return the description for a Location object referencing a known TIPLOC" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    location = Location.where(:tiploc_code => 'EUSTON').first
    decode_tiploc(location).should eql('LONDON EUSTON')
  end

  it "should return the Tiploc code for a Location object referring to an unknown TIPLOC" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ti.cif')
    location = Location.new(:tiploc_code => 'WATFDJ')
    decode_tiploc(location).should eql('WATFDJ')
  end

  it "should tidy up text with railway jargon and abbreviations" do
    tidy_text("JUNCTION ROAD JN.").should eql('Junction Road Junction')
    tidy_text("LONDN RD SDGS").should eql('London Road Sidings')
    tidy_text(nil).should eql("")
    tidy_text("").should eql("")
    tidy_text("FOOINGHAM").should eql("Fooingham")
    tidy_text("BARVILLE (BAZCESTER)").should eql('Barville (Bazcester)')
  end

  it "should convert a known TOC code to text" do
    decode_toc('LM').should eql('London Midland')
    decode_toc('LO').should eql('London Overground')
  end

  it "should return nil when asked to decode an unknown TOC" do
    decode_toc('11').should be_nil
  end

  it "should decode a Delay Attribution code in to text" do
    da_to_text('IA').should eql('a signal failure')
    da_to_text('V8').should eql('a bird strike')
  end

  it "should return the DA code when asked to decode an unknown DA code" do
    da_to_text('99').should eql('delay causation code 99')
  end

  it "should display the simplest representation of the time between two dates" do
    date_range(Time.parse('2011-01-01 09:00:00'), Time.parse('2011-01-01 10:00:00')).should eql('between 0900 and 1000 on Saturday 01 January 2011')
    date_range(Time.parse('2011-01-01 23:00:00'), Time.parse('2011-01-02 01:00:00')).should eql('between 2300 on Saturday 01 January 2011 and 0100 on Sunday 02 January 2011')
  end

  it "should trim a trailing space from WTT timings for a whole minute" do
    tidy_wtt_time('1800 ').should eql('1800')
  end

  it "should append a half-sign to WTT timings with a half-minute appended" do
    tidy_wtt_time('1800H').should eql('1800&half;')
  end

  it "should display the platform, line and path for a location with all three set" do
    location = Location.new(:platform => '1', :line => 'SL')
    format_platform_and_line(location).should eql('Plat 1, SL')
  end

  it "should display the platform for a location without a line or path specified" do
    location = Location.new(:platform => '1')
    format_platform_and_line(location).should eql('Plat 1')
  end

  it "should display the line for a location without a platform or path specified" do
    location = Location.new(:line => 'SL')
    format_platform_and_line(location).should eql('SL')
  end

  it "should return an icon and text for an 'OK' status" do
    status = Struct.new(:status, :message).new(:ok, "This is OK")
    status_data_for(status).should include('tick.png')
    status_data_for(status).should include('This is OK')
  end

  it "should return an icon and text for an 'error' status" do
    status = Struct.new(:status, :message).new(:error, "This is an error")
    status_data_for(status).should include('cross.png')
    status_data_for(status).should include('This is an error')
  end

  it "should return a question-mark and text for an 'unknown' status" do
    status = Struct.new(:status, :message).new(:unknown, "This is unknown")
    status_data_for(status).should include('question.png')
    status_data_for(status).should include('This is unknown')
  end


  # Time formatting

  it "should format a WTT departure time" do
    loc = Location.new(:departure => '1000')
    format_location_time(loc, :departure).should eql('<span class="wtt">1000</span>')
  end

  it "should format a public and WTT departure time" do
    loc = Location.new(:departure => '1000')
    format_location_time(loc, :departure).should eql('<span class="gbtt">1000</span> (<span class="wtt">1000</span>)')
  end

  it "should format a WTT arrival time" do
    loc = Location.new(:arrival => '1000')
    format_location_time(loc, :arrival).should eql('<span class="wtt">1000</span>')
  end

  it "should format a public and WTT arrival time" do
    loc = Location.new(:arrival => '1000')
    format_location_time(loc, :arrival).should eql('<span class="gbtt">1000</span> (<span class="wtt">1000</span>)')
  end

end
