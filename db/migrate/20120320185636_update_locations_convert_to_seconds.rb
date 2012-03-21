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

class UpdateLocationsConvertToSeconds < ActiveRecord::Migration

  def up
    add_column :locations, :arrival_secs, :integer
    add_column :locations, :departure_secs, :integer
    add_column :locations, :pass_secs, :integer
    add_column :locations, :public_arrival_secs, :integer
    add_column :locations, :public_departure_secs, :integer
    add_index :locations, :arrival_secs
    add_index :locations, :departure_secs
    add_index :locations, :pass_secs
    add_index :locations, :public_arrival_secs
    add_index :locations, :public_departure_secs
  end

  def down
    remove_column :locations, :arrival_secs
    remove_column :locations, :departure_secs
    remove_column :locations, :pass_secs
    remove_column :locations, :public_arrival_secs
    remove_column :locations, :public_departure_secs
  end

end
