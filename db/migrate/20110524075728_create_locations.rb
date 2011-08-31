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

class CreateLocations < ActiveRecord::Migration

  def self.up
    create_table :locations do |t|
      t.string     :basic_schedule_uuid, :limit => 36
      t.string     :location_type, :limit => 2
      t.string     :tiploc_code, :limit => 7
      t.integer    :tiploc_instance
      t.string     :arrival, :limit => 5
      t.string     :public_arrival, :limit => 5
      t.string     :pass, :limit => 5
      t.string     :departure, :limit => 5
      t.string     :public_departure, :limit => 5
      t.string     :platform, :limit => 3
      t.string     :line, :limit => 3
      t.string     :path, :limit => 3
      t.integer    :engineering_allowance
      t.integer    :pathing_allowance
      t.integer    :performance_allowance
      t.string     :activity, :limit => 12
      t.timestamps
    end
    add_index(:locations, :basic_schedule_uuid)
    add_index(:locations, :tiploc_code)
    add_index(:locations, :arrival)
    add_index(:locations, :pass)
    add_index(:locations, :departure)
  end

  def self.down
    drop_table :locations
  end

end
