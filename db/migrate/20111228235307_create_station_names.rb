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

class CreateStationNames < ActiveRecord::Migration

  def change
    create_table :station_names do |t|
      t.string     :station_name, :limit => 30
      t.integer    :cate_type
      t.string     :tiploc_code, :limit => 7
      t.string     :subsid_crs_code, :limit => 3
      t.string     :crs_code, :limit => 3
      t.float      :loc_longitude
      t.float      :loc_latitude
      t.integer    :estimated_coords
      t.integer    :change_time
      t.timestamps
    end
  end

end
