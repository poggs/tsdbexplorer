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
    activation = TSDBExplorer::TDnet::process_trust_activation('C43391', '2011-01-16', '722N53MW16')
    activation.status.should eql(:ok)
    movement = TSDBExplorer::TDnet::process_trust_movement('722N53MW16', 'A', Time.parse('2011-01-19 18:50:00'), '70100', ' ')
    movement.status.should eql(:ok)
    daily_schedule = DailySchedule.runs_on_by_uid_and_date('C43391', '2011-01-16').first
    schedule_origin = daily_schedule.origin
    schedule_origin.tiploc.tiploc_code.should eql('EUSTON')
    schedule_terminate = daily_schedule.terminate
    schedule_terminate.tiploc.tiploc_code.should eql('NMPTN')
  end

end
