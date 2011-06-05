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

  it "should convert a train category in to text" do
    decode_train_category('XX').should eql('XX: Express Passenger')
    decode_train_category('OO').should eql('OO: Ordinary Passenger')
  end

  it "should gracefully handle an unknown train category" do
    decode_train_category('$$').should eql('$$: Unknown')
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

  it "should convert a catering characteristic in to text" do
    decode_catering('').should eql('None')
    decode_catering('C').should eql('Buffet Service')
    decode_catering('R').should eql('Restaurant')
    decode_catering('HR').should eql('Hot Food service, Restaurant')
  end

  it "should gracefully handle an unknown catering code" do
    decode_catering('R$').should eql('Restaurant, Unknown facility $')
  end

  it "should convert operating characteristics in to text" do
    decode_operating_characteristics('B').should eql('B: Vacuum Braked')
    decode_operating_characteristics('Q').should eql('Q: Runs as required')
    decode_operating_characteristics('BQ').should eql('B: Vacuum Braked, Q: Runs as required')
  end

  it "should gracefully handle an unknown operatic characteristic" do
    decode_operating_characteristics(nil).should eql('None')
    decode_operating_characteristics('').should eql('None')
    decode_operating_characteristics('$').should eql('$: Unknown')
  end

  it "should convert a Tiploc object in to text" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ti.cif')
    decode_tiploc(Tiploc.first).should eql('LONDON EUSTON')
  end

  it "should convert a Tiploc object in to text" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ti.cif')
    decode_tiploc(Tiploc.first).should eql('LONDON EUSTON')
  end

  it "should return the description for a Location object referencing a known TIPLOC"

  it "should return the Tiploc code for a Location object referring to an unknown TIPLOC" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new.cif')
    location = Location.first
    decode_tiploc(location).should eql('EUSTON')
  end

end
