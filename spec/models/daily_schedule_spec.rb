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

describe DailySchedule do

  it "should have a method which returns a train schedule for a specific date" do
    DailySchedule.should respond_to(:runs_on_by_uid_and_date)
  end

  it "should have a method which returns the originating location of a schedule" do
    DailySchedule.new.should respond_to(:origin)
  end

  it "should have a method which returns the terminating location of a schedule" do
    DailySchedule.new.should respond_to(:terminate)
  end

  it "should return the originating and terminating locations of a schedule" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    activation = TSDBExplorer::TDnet::process_trust_message('000120110123163441TRUST               TSIA                                722N53MX21201101231634417241020110123183400C433912022051100000020280811000000CO2N53M000007241020110123183400AN2922209000   ')
    activation.status.should eql(:ok)
    movement = TSDBExplorer::TDnet::process_trust_message('000320110123193610TRUST               SMART                               722N53MX2120110123193600702010000000000000020110123193700     00000000000000DDA  DNF 3722N53MX17222090002929001E70100009 Y   70201Y')
    movement.status.should eql(:ok)
    daily_schedule = DailySchedule.runs_on_by_uid_and_date('C43391', '2011-01-23').first
    schedule_origin = daily_schedule.origin
    schedule_origin.tiploc.tiploc_code.should eql('EUSTON')
    schedule_terminate = daily_schedule.terminate
    schedule_terminate.tiploc.tiploc_code.should eql('NMPTN')
  end

  it "should return the originating location of a schedule which has had its origin changed via a TRUST COO message" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/trust_coo_schedule.cif')

    activation = TSDBExplorer::TDnet::process_trust_message('000120110723163915TRUST               TSIA                                512O03MX23201107231639155170220110723183900L059852028051100000020101211000000CO2O03M000005170220110723183900AN2121920000   ')
    activation.status.should eql(:ok)
    activation.message.should include('Activated train UID L05985 on 2011-07-23')

    coo_broxbourne = TSDBExplorer::TDnet::process_trust_message('000620110723185333TRUST               TRUST DA                    LSHH    512O03MX23201107231853005172220110723185430                   512O03MX2321920000XR2121O   ')
    train = DailySchedule.runs_on_by_uid_and_date('L05985', '2011-07-23').first
    train.origin.tiploc_code.should eql('BROXBRN')
  end

  it "should have a method which returns the last location details for this train" do
    DailySchedule.new.should respond_to(:last_location)
  end

  it "should return the originating location when reporting the last location of a train which has not yet departed its origin" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/dalston_junction_to_new_cross.cif')
    TSDBExplorer::TDnet::process_trust_message('000120111114085058TRUST               TSIA                                529E19MF14201111140850585207420111114095000L966952023051100000020091211000000CO9E19M000005207420111114095000AN3022218000   ')
    daily_schedule = DailySchedule.runs_on_by_uid_and_date('L96695', '2011-11-14').first
    daily_schedule.last_location.should be_nil
  end

  it "should return the originating location when reporting the last location of a train which has left its origin" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/dalston_junction_to_new_cross.cif')
    TSDBExplorer::TDnet::process_trust_message('000120111114085058TRUST               TSIA                                529E19MF14201111140850585207420111114095000L966952023051100000020091211000000CO9E19M000005207420111114095000AN3022218000   ')
    TSDBExplorer::TDnet::process_trust_message('000320111114095018TRUST               SMART                               529E19MF1420111114095000520742011111409500020111114095000     00000000000000DDA  D  31529E19MF14222180003030000 52078001 Y   52074Y')
    daily_schedule = DailySchedule.runs_on_by_uid_and_date('L96695', '2011-11-14').first
    daily_schedule.last_location.should eql(daily_schedule.locations.where(:tiploc_code => 'DALS').first)
  end

  it "should return the first calling point when reporting the last location of a train which has arrived at its first calling point" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/dalston_junction_to_new_cross.cif')
    TSDBExplorer::TDnet::process_trust_message('000120111114085058TRUST               TSIA                                529E19MF14201111140850585207420111114095000L966952023051100000020091211000000CO9E19M000005207420111114095000AN3022218000   ')
    TSDBExplorer::TDnet::process_trust_message('000320111114095018TRUST               SMART                               529E19MF1420111114095000520742011111409500020111114095000     00000000000000DDA  D  31529E19MF14222180003030000 52078001 Y   52074Y')
    TSDBExplorer::TDnet::process_trust_message('000320111114095057TRUST               SMART                               529E19MF1420111114095100520782011111409510020111114095100     00000000000000AAA  D   0529E19MF14222180003030000 52080001     00000Y')
    daily_schedule = DailySchedule.runs_on_by_uid_and_date('L96695', '2011-11-14').first
    daily_schedule.last_location.should eql(daily_schedule.locations.where(:tiploc_code => 'HAGGERS').first)
  end

  it "should return the first calling point when reporting the last location of a train which has departed its first calling point" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/dalston_junction_to_new_cross.cif')
    TSDBExplorer::TDnet::process_trust_message('000120111114085058TRUST               TSIA                                529E19MF14201111140850585207420111114095000L966952023051100000020091211000000CO9E19M000005207420111114095000AN3022218000   ')
    TSDBExplorer::TDnet::process_trust_message('000320111114095018TRUST               SMART                               529E19MF1420111114095000520742011111409500020111114095000     00000000000000DDA  D  31529E19MF14222180003030000 52078001 Y   52074Y')
    TSDBExplorer::TDnet::process_trust_message('000320111114095057TRUST               SMART                               529E19MF1420111114095100520782011111409510020111114095100     00000000000000AAA  D   0529E19MF14222180003030000 52080001     00000Y')
    TSDBExplorer::TDnet::process_trust_message('000320111114095219TRUST               SMART                               529E19MF1420111114095100520782011111409510020111114095130     00000000000000DDA  D   1529E19MF14222180003030000 52080002     00000Y')
    daily_schedule = DailySchedule.runs_on_by_uid_and_date('L96695', '2011-11-14').first
    daily_schedule.last_location.should eql(daily_schedule.locations.where(:tiploc_code => 'HAGGERS').first)
  end

  it "should return the terminating location when reporting the last location of a train which has terminated" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/dalston_junction_to_new_cross.cif')
    TSDBExplorer::TDnet::process_trust_message('000120111114085058TRUST               TSIA                                529E19MF14201111140850585207420111114095000L966952023051100000020091211000000CO9E19M000005207420111114095000AN3022218000   ')
    TSDBExplorer::TDnet::process_trust_message('000320111114100847TRUST               SMART                               529E19MF1420111114101000883922011111410120020111114101100     00000000000000TAA  D   0529E19MF14222180003030001E     000YY   88392Y')
    daily_schedule = DailySchedule.runs_on_by_uid_and_date('L96695', '2011-11-14').first
    daily_schedule.last_location.should eql(daily_schedule.locations.where(:tiploc_code => 'NWCRELL').first)
  end

end
