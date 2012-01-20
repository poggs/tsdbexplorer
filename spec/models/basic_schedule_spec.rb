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

describe BasicSchedule do

  it "should return the origin and termating locations of a BasicSchedule" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    schedule = BasicSchedule.runs_on_by_uid_and_date('C43391', Date.parse('2010-12-12')).first
    schedule.origin.tiploc.tiploc_code.should eql('EUSTON')
    schedule.terminate.tiploc.tiploc_code.should eql('NMPTN')
  end

  it "should have a 'terminate' method which returns the Location object of the terminating location" do
    object = BasicSchedule.new
    object.should respond_to(:terminate)
  end

  it "should have a method which returns a train schedule for a specific date" do
    BasicSchedule.should respond_to(:runs_on_by_uid_and_date)
  end

  it "should return a specific train schedule for a specific date" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    schedule = BasicSchedule.runs_on_by_uid_and_date('C43391', Date.parse('2010-12-12')).first
    schedule.should_not be_nil
    schedule[:train_uid].should eql('C43391')
    schedule.is_stp_cancelled?.should_not be_true
  end

  it "should not return a schedule on a day for which it is not valid" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    schedule = BasicSchedule.runs_on_by_uid_and_date('C43391', Date.parse('2010-12-13')).first
    schedule.should be_nil
  end

  it "should return a cancellation record for a schedule which is cancelled" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_cancel.cif')
    schedule = BasicSchedule.runs_on_by_uid_and_date('C43391', Date.parse('2011-01-09')).first
    schedule.should_not be_nil
    schedule.is_stp_cancelled?.should be_true
  end

  it "should have a method which returns a schedule and all alterations to it" do
    BasicSchedule.should respond_to(:all_schedules_by_uid)
  end

  it "should return only a schedule where no alterations exist" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    schedule = BasicSchedule.all_schedules_by_uid('C43391')
    schedule.count.should eql(1)
    schedule.first.stp_indicator.should eql('P')
  end

  it "should return a schedule and all alterations where a permanent schedule and an overlay exists" do
    result_1 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_stp_overlay_part1.cif')
    result_1.status.should eql(:ok)
    result_2 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_stp_overlay_part2.cif')
    result_2.status.should eql(:ok)
    schedule = BasicSchedule.all_schedules_by_uid('C43158')
    schedule.count.should eql(2)
    schedule.first.stp_indicator.should eql('P')
    schedule.last.stp_indicator.should eql('O')
  end

  it "should return only a schedule where an STP schedule and no alterations exist" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_stp_schedule.cif')
    result.status.should eql(:ok)
    schedule = BasicSchedule.all_schedules_by_uid('C43158')
    schedule.count.should eql(1)
    schedule.first.stp_indicator.should eql('O')
  end

  it "should return an STP schedule and all alterations where they exist" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_train_with_overlays.cif')
    schedule = BasicSchedule.all_schedules_by_uid('G31158')
    schedule.count.should eql(33)
    count = 0
    schedule.each do |s|
      if count == 0
        s.stp_indicator.should eql('P')
      else
        s.stp_indicator.should eql('O')
      end
      count = count + 1
    end
  end

  it "should have a method which identifies if this schedule is for a passenger service" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    BasicSchedule.first.should respond_to(:is_passenger?)
  end

  it "should identify if a schedule is for a passenger service" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    schedule = BasicSchedule.runs_on_by_uid_and_date('C43391', Date.parse('2010-12-12')).first
    schedule.is_passenger?.should be_true
  end

  it "should identify if a schedule is for a non-passenger service"

  it "should identify if a schedule is for a train" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    schedule = BasicSchedule.runs_on_by_uid_and_date('C43391', Date.parse('2010-12-12')).first
    schedule.is_a_train?.should be_true
    schedule.is_a_bus?.should be_false
    schedule.is_a_ship?.should be_false
  end

  it "should identify if a schedule is for a bus" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_bus.cif')
    schedule = BasicSchedule.runs_on_by_uid_and_date('G39152', Date.parse('2011-05-22')).first
    schedule.is_a_train?.should be_false
    schedule.is_a_bus?.should be_true
    schedule.is_a_ship?.should be_false
  end

  it "should identify if a schedule is for a ship" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_ship.cif')
    schedule = BasicSchedule.runs_on_by_uid_and_date('P87065', Date.parse('2011-05-22')).first
    schedule.is_a_train?.should be_false
    schedule.is_a_bus?.should be_false
    schedule.is_a_ship?.should be_true
  end


  # Schedule retrieval

  it "should return all the dates a schedule is valid for, with the STP indicator" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/permanent_schedule_with_overlays.cif')
    expected_data = { '2011-11-28' => 'P', '2011-11-29' => 'O', '2011-11-30' => 'O', '2011-12-01' => 'P', '2011-12-02' => 'P' }
    schedule_run_dates = BasicSchedule.find_by_train_uid('L06806').date_array
    schedule_run_dates.each do |d|
      iso_date = d.date.to_s(:iso)
      d.type.should eql(expected_data[iso_date]) if expected_data.has_key? iso_date
    end
  end

end
