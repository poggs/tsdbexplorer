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
    expected_data = { 'P' => 'train', 'B' => 'bus', '5' => 'bus' }
    expected_data.each do |k,v|
      mode_icon_for(k).should include(v)
    end
  end

  it "should return nil if given an undefined transport mode" do
    ['_', '!', '', nil].each do |transport_mode|
      mode_icon_for(transport_mode).should be_nil
    end
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

end
