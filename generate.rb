#!/usr/bin/ruby
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

require 'config/environment'


# Ensure we have two days of schedules

run_date = Date.today # + 1.days

puts "Generating schedules for #{run_date}"

# Find all the schedules that run today

cif_day_pos = run_date.wday
cif_day_pos = 7 if cif_day_pos == 0

runs_today = BasicSchedule.where("? BETWEEN runs_from AND runs_to", run_date).where("MID(days_run,#{cif_day_pos},1) = '1'").order('runs_to - runs_from').group('train_uid')

daily_attributes = DailySchedule.new.attributes.keys
loc_attributes = DailyScheduleLocation.new.attributes.keys

runs_today.each do |schedule|


  # If this schedule has been cancelled, skip it

  next if schedule[:stp_indicator] == "C"


  # Prepare the daily schedule

  ds_attr = Hash.new

  daily_attributes.each do |attr|
    ds_attr[attr] = schedule[attr]
  end

  ds_attr[:runs_on] = run_date


  # Exclude non-trains (e.g. ships, buses)

  if ['P', 'F', 'T', '1', '2'].include? schedule[:status]
    ds_attr[:train_identity_unique] = schedule[:train_identity_unique] + run_date.day.to_s.rjust(2, "0")
  end

  # Prepare the calling points

  location_list = Array.new

  schedule.locations.each do |location|

    loc_attr = Hash.new

    loc_attributes.each do |attr|
      loc_attr[attr] = location[attr]
    end

    loc_attr[:train_uid] = schedule[:train_uid]

    [ :arrival, :public_arrival, :pass, :departure, :public_departure ].each do |time_attr|
      loc_attr[time_attr] = Time.parse(run_date.to_s + " " + TSDBExplorer::normalise_time(location[time_attr])) unless location[time_attr].nil?
    end

    location_list << DailyScheduleLocation.new(loc_attr)    
    
  end

  # Do the work

  DailySchedule.create!(ds_attr)
  DailyScheduleLocation.import(location_list)

end
