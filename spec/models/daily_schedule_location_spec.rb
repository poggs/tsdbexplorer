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

describe DailyScheduleLocation do

  it "should not be valid when first created" do
    record = DailyScheduleLocation.new
    record.should_not be_valid
  end

  it "should have a method which identifies if the location should be publicly advertised" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/pickup_and_setdown.cif')
    activation = TSDBExplorer::TDnet::process_trust_message('000120110717075016TRUST               TSIA                                721G02MD17201107170750167241020110717085000P644372022051100000020041211000000CO1G02M000007241020110717085000AN6522100001   ')

    euston_to_wolverhampton = DailySchedule.runs_on_by_uid_and_date('P64437', '2011-07-17').first
    watford_junction = euston_to_wolverhampton.locations.find_by_tiploc_code('WATFDJ')
    watford_junction.is_public?.should be_true
    watford_junction.pickup_only?.should be_true
    watford_junction.setdown_only?.should be_false
  end

  it "should identify locations in a schedule which are to pick up passengers only" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/pickup_and_setdown.cif')
    activation = TSDBExplorer::TDnet::process_trust_message('000120110717075016TRUST               TSIA                                721G02MD17201107170750167241020110717085000P644372022051100000020041211000000CO1G02M000007241020110717085000AN6522100001   ')

    euston_to_wolverhampton = DailySchedule.runs_on_by_uid_and_date('P64437', '2011-07-17').first
    ledburn_junction = euston_to_wolverhampton.locations.find_by_tiploc_code('LEDBRNJ')
    ledburn_junction.is_public?.should be_false
  end

  it "should identify locations in a schedule which are to set down passengers only" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/pickup_and_setdown.cif')
    activation = TSDBExplorer::TDnet::process_trust_message('000120110717070514TRUST               TSIA                                321A02MC17201107170705143200020110717080500P640242022051100000020041211000000CO1A02M000003200020110717080500AN6522108001   ')

    manchester_to_euston = DailySchedule.runs_on_by_uid_and_date('P64024', '2011-07-17').first
    watford_junction = manchester_to_euston.locations.find_by_tiploc_code('WATFDJ')
    watford_junction.is_public?.should be_true
    watford_junction.pickup_only?.should be_false
    watford_junction.setdown_only?.should be_true
  end

  it "should have a method which reports if this is the originating location in the schedule" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/pickup_and_setdown.cif')
    activation = TSDBExplorer::TDnet::process_trust_message('000120110717070514TRUST               TSIA                                321A02MC17201107170705143200020110717080500P640242022051100000020041211000000CO1A02M000003200020110717080500AN6522108001   ')

    manchester_to_euston = DailySchedule.runs_on_by_uid_and_date('P64024', '2011-07-17').first
    manchester_piccadilly = manchester_to_euston.locations.find_by_tiploc_code('MNCRPIC')
    manchester_to_euston.origin.tiploc_code.should eql(manchester_piccadilly.tiploc_code)    
  end

  it "should have a method which reports if this is the terminating location in the schedule" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/pickup_and_setdown.cif')
    activation = TSDBExplorer::TDnet::process_trust_message('000120110717070514TRUST               TSIA                                321A02MC17201107170705143200020110717080500P640242022051100000020041211000000CO1A02M000003200020110717080500AN6522108001   ')

    manchester_to_euston = DailySchedule.runs_on_by_uid_and_date('P64024', '2011-07-17').first
    london_euston = manchester_to_euston.locations.find_by_tiploc_code('EUSTON')
    manchester_to_euston.terminate.tiploc_code.should eql(london_euston.tiploc_code)    
  end

end
