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

class CreateGeoPoints < ActiveRecord::Migration

  def self.up
    create_table :geo_points do |t|
      t.text       :location_name
      t.string     :route_code, :limit => 6
      t.string     :elr_code, :limit => 4
      t.integer    :miles
      t.integer    :chains
      t.timestamps
    end
  end

  def self.down
    drop_table :geo_points
  end

end
