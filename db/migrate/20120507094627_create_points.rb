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

class CreatePoints < ActiveRecord::Migration

  def change
    create_table :points do |t|
      t.text       :full_name
      t.text       :short_name
      t.integer    :stanox
      t.string     :stanme, :limit => 9
      t.string     :tiploc, :limit => 7
      t.float      :latitude
      t.float      :longitude
      t.timestamps
    end
  end

end
