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

describe ScheduleHelper do

  it "should convert a set of catering codes to icons" do
    # TODO: Fix wheelchair-only restaurant reservations
    expected_data = { 'C' => ['Buffet'], 'F' => ['Restaurant', '1st Class'], 'H' => ['Hot food'], 'M' => ['Meal', '1st Class'], 'P' => [], 'R' => ['Restaurant'], 'T' => ['Trolley'] }
    expected_data.each do |k,v|
      v.each do |expected_text|
        catering_icon(k).should include(expected_text)
      end
    end
  end

  it "should handle a null catering code" do
    [ nil, '', ' ' ].each do |catering_code|
      catering_icon(catering_code).should be_nil
    end
  end

  it "should handle an invalid catering code" do
    [ '!', '0' ].each do |catering_code|
      catering_icon(catering_code).should be_nil
    end
  end

  it "should convert a train category in to text" do
    decode_train_category('XX').should eql('Express Passenger')
    decode_train_category('OO').should eql('Ordinary Passenger')
  end

  it "should gracefully handle an unknown train category" do
    decode_train_category('$$').should eql('Unknown')
  end

  it "should return an appropriately named mode icon for a transport mode" do
    expected_data = { 'P' => 'train', 'F' => 'train', 'T' => 'train', '1' => 'train', '2' => 'train', '3' => 'train', 'B' => 'bus', '5' => 'bus', 'S' => 'ship', '4' => 'ship'  }
    expected_data.each do |k,v|
      mode_icon_for(k).should_not be_nil
      mode_icon_for(k).should include(v)
    end
  end

  it "should return nil if given an undefined transport mode" do
    ['_', '!', '', nil].each do |transport_mode|
      mode_icon_for(transport_mode).should be_nil
    end
  end

  it "should convert operating characteristics in to text" do
    decode_operating_characteristics('B').should eql('Vacuum Braked')
    decode_operating_characteristics('Q').should eql('Runs as required')
    decode_operating_characteristics('BQ').should eql('Vacuum Braked, Runs as required')
  end

  it "should gracefully handle an unknown operatic characteristic" do
    decode_operating_characteristics('$').should eql('Unknown ($)')
  end

  it "should return nil if passed a blank set of operating characteristics" do
    decode_operating_characteristics('').should be_nil
    decode_operating_characteristics(nil).should be_nil
    decode_operating_characteristics('        ').should be_nil
  end

  it "should output a list of days on which a schedule is valid" do

    expected_data = { 'every day' => [ :runs_mo, :runs_tu, :runs_we, :runs_th, :runs_fr, :runs_sa, :runs_su, :bh_running ],
                      'every weekday' => [ :runs_mo, :runs_tu, :runs_we, :runs_th, :runs_fr ],
                      'weekends' => [ :runs_sa, :runs_su ],
                      'Monday only' => [ :runs_mo ],
                      'Tuesday only' => [ :runs_tu ],
                      'Wednesday only' => [ :runs_we ],
                      'Thursday only' => [ :runs_th ],
                      'Friday only' => [ :runs_fr ],
                      'Saturday only' => [ :runs_sa ],
                      'Sunday only' => [ :runs_su ],
                      'Monday and Tuesday' => [ :runs_mo, :runs_tu ],
                      'Tuesday and Wednesday' => [ :runs_tu, :runs_we ],
                      'Monday, Tuesday and Wednesday' => [ :runs_mo, :runs_tu, :runs_we ],
                      'Tuesday, Wednesday and Thursday' => [ :runs_tu, :runs_we, :runs_th ],
                      'Monday, Tuesday, Wednesday and Thursday' => [ :runs_mo, :runs_tu, :runs_we, :runs_th ],
                      'Tuesday, Wednesday, Thursday and Friday' => [ :runs_tu, :runs_we, :runs_th, :runs_fr ] }

    expected_data.each do |expected_text,run_days|
      bs = BasicSchedule.new
      run_days.each do |day|
        bs[day] = true
      end
      runs_on_days(bs).should eql(expected_text)
    end

  end

  it "should return the scheduled time for a location when no predicted or actual time is known" do
    location = DailyScheduleLocation.new(:arrival => Time.parse('2011-10-30 09:00:00'), :expected_arrival => nil, :actual_arrival => nil)
    output = format_time(location, 'arrival')
    output.should include('0900')
    output.should match(/class=".*scheduled.*"/)
  end

  it "should return the expected time for a location where it is available and no actual time is known" do
    location = DailyScheduleLocation.new(:arrival => Time.parse('2011-10-30 09:00:00'), :expected_arrival => Time.parse('2011-10-30 09:00:00'), :actual_arrival => nil)
    output = format_time(location, 'arrival')
    output.should include('0900')
    output.should match(/class=".*expected.*"/)
  end

  it "should return the actual time for a location where it is available" do
    location = DailyScheduleLocation.new(:arrival => Time.parse('2011-10-30 09:00:00'), :expected_arrival => Time.parse('2011-10-30 09:00:00'), :actual_arrival => Time.parse('2011-10-30 09:00:00'))
    output = format_time(location, 'arrival')
    output.should include('0900')
    output.should match(/class=".*actual.*"/)
  end

  it "should identify where the actual time for a location is more than -3m from the scheduled time" do
    location = DailyScheduleLocation.new(:arrival => Time.parse('2011-10-30 09:00:00'), :expected_arrival => Time.parse('2011-10-30 09:00:00'), :actual_arrival => Time.parse('2011-10-30 08:50:00'))
    output = format_time(location, 'arrival')
    output.should include('0850')
    output.should match(/class="actual early"/)
  end

  it "should identify where the actual time for a location is between -3m and +3m of the scheduled time" do
    location = DailyScheduleLocation.new(:arrival => Time.parse('2011-10-30 09:00:00'), :expected_arrival => Time.parse('2011-10-30 09:00:00'), :actual_arrival => Time.parse('2011-10-30 08:58:00'))
    output = format_time(location, 'arrival')
    output.should include('0858')
    output.should match(/class="actual ontime"/)
  end

  it "should identify where the actual time for a location is more than +3m from the scheduled time" do
    location = DailyScheduleLocation.new(:arrival => Time.parse('2011-10-30 09:00:00'), :expected_arrival => Time.parse('2011-10-30 09:00:00'), :actual_arrival => Time.parse('2011-10-30 09:04:00'))
    output = format_time(location, 'arrival')
    output.should include('0904')
    output.should match(/class="actual late"/)
  end

  it "should display 'Departed 2 minutes late' for a location where the actual departure time is 2 minutes later than the public departure time" do
    location = DailyScheduleLocation.new(:public_departure => Time.parse('2011-10-30 09:00:00'), :actual_departure => Time.parse('2011-10-30 09:02:00'))
    output = calculate_variation(location)
    output.should eql('Departed 2 minutes late')
  end

  it "should display 'Departed 1 minute late' for a location where the actual departure time is 1 minute later than the public departure time" do
    location = DailyScheduleLocation.new(:public_departure => Time.parse('2011-10-30 09:00:00'), :actual_departure => Time.parse('2011-10-30 09:01:00'))
    output = calculate_variation(location)
    output.should eql('Departed 1 minute late')
  end

  it "should display 'Departed on-time' for a location where the actual departure time is half a minute later than public departure time" do
    location = DailyScheduleLocation.new(:public_departure => Time.parse('2011-10-30 09:00:00'), :actual_departure => Time.parse('2011-10-30 09:00:30'))
    output = calculate_variation(location)
    output.should eql('Departed on-time')
  end

  it "should display 'Departed on-time' for a location where the actual departure time is the same as the public departure time" do
    location = DailyScheduleLocation.new(:public_departure => Time.parse('2011-10-30 09:00:00'), :actual_departure => Time.parse('2011-10-30 09:00:00'))
    output = calculate_variation(location)
    output.should eql('Departed on-time')
  end

  it "should display 'Departed on-time' for a location where the actual departure time is half a minute earlier than public departure time" do
    location = DailyScheduleLocation.new(:public_departure => Time.parse('2011-10-30 09:00:00'), :actual_departure => Time.parse('2011-10-30 08:59:30'))
    output = calculate_variation(location)
    output.should eql('Departed on-time')
  end

  it "should display 'Departed 1 minute early' for a location where the actual departure time is 1 minute earlier than the public departure time" do
    location = DailyScheduleLocation.new(:public_departure => Time.parse('2011-10-30 09:00:00'), :actual_departure => Time.parse('2011-10-30 08:59:00'))
    output = calculate_variation(location)
    output.should eql('Departed 1 minute early')
  end

  it "should display 'Departed 2 minutes early' for a loction where the actual departure time is 2 minutes earlier than the public departure time'" do
    location = DailyScheduleLocation.new(:public_departure => Time.parse('2011-10-30 09:00:00'), :actual_departure => Time.parse('2011-10-30 08:58:00'))
    output = calculate_variation(location)
    output.should eql('Departed 2 minutes early')
  end

  it "should display 'Arrived 2 minutes early' for a location where the actual arrival time is 2 minutes earlier then the public arrival time" do
    location = DailyScheduleLocation.new(:public_arrival => Time.parse('2011-10-30 09:00:00'), :actual_arrival => Time.parse('2011-10-30 08:58:00'))
    output = calculate_variation(location)
    output.should eql('Arrived 2 minutes early')
  end

  it "should display 'Arrived 1 minute early' for a location where the actual arrival time is 1 minute earlier than the public arrival time" do
    location = DailyScheduleLocation.new(:public_arrival => Time.parse('2011-10-30 09:00:00'), :actual_arrival => Time.parse('2011-10-30 08:59:00'))
    output = calculate_variation(location)
    output.should eql('Arrived 1 minute early')
  end

  it "should display 'Arrived on-time' for a location where the actual arrival time is half a minute earlier than the public arrival time" do
    location = DailyScheduleLocation.new(:public_arrival => Time.parse('2011-10-30 09:00:00'), :actual_arrival => Time.parse('2011-10-30 08:59:30'))
    output = calculate_variation(location)
    output.should eql('Arrived on-time')
  end

  it "should display 'Arrived on-time' for a location where the actual arrival time is the same as the public arrival time" do
    location = DailyScheduleLocation.new(:public_arrival => Time.parse('2011-10-30 09:00:00'), :actual_arrival => Time.parse('2011-10-30 09:00:00'))
    output = calculate_variation(location)
    output.should eql('Arrived on-time')
  end

  it "should display 'Arrived on-time' for a location where the actual arrival time is half a minute later than the public arrival time" do
    location = DailyScheduleLocation.new(:public_arrival => Time.parse('2011-10-30 09:00:00'), :actual_arrival => Time.parse('2011-10-30 09:00:30'))
    output = calculate_variation(location)
    output.should eql('Arrived on-time')
  end

  it "should display 'Arrived 1 minute late' for a location where the actual arrival time is 1 minute later than the public arrival time" do
    location = DailyScheduleLocation.new(:public_arrival => Time.parse('2011-10-30 09:00:00'), :actual_arrival => Time.parse('2011-10-30 09:01:00'))
    output = calculate_variation(location)
    output.should eql('Arrived 1 minute late')
  end

  it "should display 'Arrived 2 minutes late' for a location where the actual arrival time is 2 minutes later than the public arrival time" do
    location = DailyScheduleLocation.new(:public_arrival => Time.parse('2011-10-30 09:00:00'), :actual_arrival => Time.parse('2011-10-30 09:02:00'))
    output = calculate_variation(location)
    output.should eql('Arrived 2 minutes late')
  end

  it "should display the arrival performance when there is no departure performance"
  it "should display 'No report' when no information has been received for a location"

  it "should display 'Cancelled' for a location where the train no longer calls at this location" do
    location = DailyScheduleLocation.new(:cancelled => true)
    output = calculate_variation(location)
    output.should =~ /Cancelled/
  end

end
