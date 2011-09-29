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

class UpdateDailyScheduleLocationsAddSource < ActiveRecord::Migration

  def self.up
    add_column :daily_schedule_locations, :arrival_source, :string, :limit => 16
    add_column :daily_schedule_locations, :pass_source, :string, :limit => 16
    add_column :daily_schedule_locations, :departure_source, :string, :limit => 16
  end

  def self.down
    drop_column :daily_schedule_locations, :arrival_source
    drop_column :daily_schedule_locations, :pass_source
    drop_column :daily_schedule_locations, :departure_source
  end

end
