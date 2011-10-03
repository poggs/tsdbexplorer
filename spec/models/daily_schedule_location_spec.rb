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

  it "should have a method which identifies if the location should be publically advertised" do
  end

  it "should identify locations in a schedule which are to pick up passengers only" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/pickup_and_setdown.cif')
    euston_to_wolverhampton = BasicSchedule.runs_on_by_uid_and_date('P64437', '2011-05-22').first
    watford_junction = euston_to_wolverhampton.locations.find_by_tiploc_code('WATFDJ')
    watford_junction.pickup_only?.should be_true
    watford_junction.setdown_only?.should be_false
  end

  it "should identify locations in a schedule which are to set down passengers only" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/pickup_and_setdown.cif')
    manchester_to_euston = BasicSchedule.runs_on_by_uid_and_date('P64024', '2011-05-22').first
    watford_junction = manchester_to_euston.locations.find_by_tiploc_code('WATFDJ')
    watford_junction.pickup_only?.should be_false
    watford_junction.setdown_only?.should be_true
  end

  it "should have a method which reports if this is the originating location in the schedule" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/pickup_and_setdown.cif')
    euston_to_wolverhampton = BasicSchedule.runs_on_by_uid_and_date('P64437', '2011-05-22').first
    london_euston = euston_to_wolverhampton.locations.find_by_tiploc_code('EUSTON')
    london_euston.is_origin?.should be_true
    london_euston.is_destination?.should be_false
  end

  it "should have a method which reports if this is the terminating location in the schedule" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/pickup_and_setdown.cif')
    euston_to_wolverhampton = BasicSchedule.runs_on_by_uid_and_date('P64437', '2011-05-22').first
    wolverhampton = euston_to_wolverhampton.locations.find_by_tiploc_code('WVRMPTN')
    wolverhampton.is_origin?.should be_false
    wolverhampton.is_destination?.should be_true
  end

end
