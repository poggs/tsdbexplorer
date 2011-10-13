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

class ModifyDailyScheduleLocationAddSource < ActiveRecord::Migration

  def self.up

    add_column :daily_schedule_locations, :arrival_system, :string, :limit => 20
    add_column :daily_schedule_locations, :arrival_device_id, :string, :limit => 8
    add_column :daily_schedule_locations, :arrival_username, :string, :limit => 8

    add_column :daily_schedule_locations, :pass_system, :string, :limit => 20
    add_column :daily_schedule_locations, :pass_device_id, :string, :limit => 8
    add_column :daily_schedule_locations, :pass_username, :string, :limit => 8

    add_column :daily_schedule_locations, :departure_system, :string, :limit => 20
    add_column :daily_schedule_locations, :departure_device_id, :string, :limit => 8
    add_column :daily_schedule_locations, :departure_username, :string, :limit => 8

  end

  def self.down

    remove_column :daily_schedule_locations, :arrival_system
    remove_column :daily_schedule_locations, :arrival_device_id
    remove_column :daily_schedule_locations, :arrival_username

    remove_column :daily_schedule_locations, :pass_system
    remove_column :daily_schedule_locations, :pass_device_id
    remove_column :daily_schedule_locations, :pass_username

    remove_column :daily_schedule_locations, :departure_system
    remove_column :daily_schedule_locations, :departure_device_id
    remove_column :daily_schedule_locations, :departure_username

  end

end
