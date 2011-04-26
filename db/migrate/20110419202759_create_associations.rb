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
#  $Id: 20110419202759_create_associations.rb 109 2011-04-19 21:03:03Z pwh $
#

class CreateAssociations < ActiveRecord::Migration

  def self.up
    create_table :associations do |t|
      t.string     :main_train_uid, :length => 6
      t.string     :assoc_train_uid, :length => 6
      t.date       :date
      t.string     :category, :length => 2
      t.string     :date_indicator, :length => 1
      t.string     :location, :length => 7
      t.string     :base_location_suffix, :length => 1
      t.string     :assoc_location_suffix, :length => 1
      t.string     :diagram_type, :length => 1
      t.string     :assoc_type, :length => 1
      t.string     :stp_indicator, :length => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :associations
  end

end
