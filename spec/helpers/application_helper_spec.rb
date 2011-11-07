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
    decode_reservations(' ').should eql('Not available')
    decode_reservations(nil).should eql('Not available')
    decode_reservations('A').should eql('A: Reservations compulsory')
    decode_reservations('S').should eql('S: Reservations possible')
  end

  it "should gracefully handle an unknown reservation status" do
    decode_reservations('$').should eql('$: Unknown')
  end

  it "should convert a Tiploc object in to text" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ti.cif')
    decode_tiploc(Tiploc.first).should eql('London Euston')
  end

  it "should convert a Tiploc object in to text" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ti.cif')
    decode_tiploc(Tiploc.first).should eql('London Euston')
  end

  it "should return the description for a Location object referencing a known TIPLOC"

  it "should return the Tiploc code for a Location object referring to an unknown TIPLOC" do
    location = Location.new(:tiploc_code => 'EUSTON')
    decode_tiploc(location).should eql('EUSTON')
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

  it "should return the days of the week a service runs as text"

  it "should display the simplest representation of the time between two dates" do
    date_range(Time.parse('2011-01-01 09:00:00'), Time.parse('2011-01-01 10:00:00')).should eql('between 0900 and 1000 on Saturday 01 January 2011')
    date_range(Time.parse('2011-01-01 23:00:00'), Time.parse('2011-01-02 01:00:00')).should eql('between 2300 on Saturday 01 January 2011 and 0100 on Sunday 02 January 2011')
  end

end
