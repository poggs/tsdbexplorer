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
    location = DailyScheduleLocation.new
    location.should respond_to(:is_public?)
  end

  it "should mark a location with a public departure time as public" do
    location = DailyScheduleLocation.new(:departure => Time.parse('2011-10-31 10:00:00'), :public_departure => Time.parse('2011-10-31 10:00:00'))
    location.is_public?.should be_true
  end

  it "should not mark a passing location as public" do
    location = DailyScheduleLocation.new(:pass => Time.parse('2011-10-31 10:00:00'))
    location.is_public?.should_not be_true
  end

  it "should mark a location with a public arrival time as public" do
    location = DailyScheduleLocation.new(:arrival => Time.parse('2011-10-31 10:00:00'), :public_arrival => Time.parse('2011-10-31 10:00:00'))
    location.is_public?.should be_true
  end

  it "should mark a location with a public arrival time but no public departure time as public" do
    location = DailyScheduleLocation.new(:arrival => Time.parse('2011-10-31 10:00:00'), :public_arrival => Time.parse('2011-10-31 10:00:00'), :departure => Time.parse('2011-10-31 10:01:00'))
    location.is_public?.should be_true
  end

  it "should mark a location with a no public arrival time and a public departure time as public" do
    location = DailyScheduleLocation.new(:arrival => Time.parse('2011-10-31 10:00:00'), :departure => Time.parse('2011-10-31 10:01:00'), :public_departure => Time.parse('2011-10-31 10:01:00'))
    location.is_public?.should be_true
  end

  it "should have a method which identifies if a location is for picking up passengers" do
    location = DailyScheduleLocation.new
    location.should respond_to(:pickup_only?)
  end

  it "should mark a location with a 'U' activity as for picking up passengers" do
    location = DailyScheduleLocation.new(:activity_u => true)
    location.pickup_only?.should be_true
  end

  it "should have a method which identifies if a location is for setting down passengers" do
    location = DailyScheduleLocation.new
    location.should respond_to(:setdown_only?)
  end

  it "should mark a location with a 'D' activity set as for setting down passengers" do
    location = DailyScheduleLocation.new(:activity_d => true)
    location.setdown_only?.should be_true
  end

  it "should have a method which identifies if this is the originating location in the schedule" do
    location = DailyScheduleLocation.new
    location.should respond_to(:is_origin?)
  end

  it "should mark a location with a 'TB' activity set as the originating location" do
    location = DailyScheduleLocation.new(:activity_tb => true)
    location.is_origin?.should be_true
  end

  it "should have a method which identifies if this is the terminating location in the schedule" do
    location = DailyScheduleLocation.new
    location.should respond_to(:is_destination?)
  end

  it "should mark a location with a 'TF' activity set as the terminating location" do
    location = DailyScheduleLocation.new(:activity_tf => true)
    location.is_destination?.should be_true
  end

end
