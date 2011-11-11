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
    schedule = BasicSchedule.runs_on_by_uid_and_date('C43391', '2010-12-12').first
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
    schedule = BasicSchedule.runs_on_by_uid_and_date('C43391', '2010-12-12').first
    schedule.should_not be_nil
    schedule[:train_uid].should eql('C43391')
    schedule.is_stp_cancelled?.should_not be_true
  end

  it "should not return a schedule on a day for which it is not valid" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    schedule = BasicSchedule.runs_on_by_uid_and_date('C43391', '2010-12-13').first
    schedule.should be_nil
  end

  it "should return a cancellation record for a schedule which is cancelled" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_cancel.cif')
    schedule = BasicSchedule.runs_on_by_uid_and_date('C43391', '2011-01-09').first
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
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_stp_overlay_part1.cif')
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_stp_overlay_part2.cif')
    schedule = BasicSchedule.all_schedules_by_uid('C43158')
    schedule.count.should eql(2)
    schedule.first.stp_indicator.should eql('P')
    schedule.last.stp_indicator.should eql('O')
  end

  it "should return only a schedule where an STP schedule and no alterations exist" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_stp_overlay_part2.cif')
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
    schedule = BasicSchedule.runs_on_by_uid_and_date('C43391', '2010-12-12').first
    schedule.is_passenger?.should be_true
  end

  it "should identify if a schedule is for a non-passenger service"

end
