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

  it "should have an 'origin' method which returns the Location object of the originating location" do
    object = BasicSchedule.new
    object.should respond_to(:origin)
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
  end

end
