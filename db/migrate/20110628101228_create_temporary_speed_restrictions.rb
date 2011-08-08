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

class CreateTemporarySpeedRestrictions < ActiveRecord::Migration

  def self.up
    create_table :temporary_speed_restrictions do |t|
      t.string     :tsr_id
      t.string     :route_group_name
      t.string     :route_code
      t.string     :route_order
      t.string     :tsr_reference
      t.string     :from_location
      t.string     :to_location
      t.string     :line_name
      t.string     :subunit_type
      t.integer    :mileage_from
      t.integer    :subunit_from
      t.integer    :mileage_to
      t.integer    :subunit_to
      t.string     :moving_mileage
      t.integer    :passenger_speed
      t.integer    :freight_speed
      t.datetime   :creation_date
      t.datetime   :valid_from_date
      t.datetime   :valid_to_date
      t.string     :reason
      t.string     :requestor
      t.string     :comments
      t.string     :direction
      t.timestamps
    end
    add_index(:temporary_speed_restrictions, :tsr_id)
    add_index(:temporary_speed_restrictions, :route_code)
    add_index(:temporary_speed_restrictions, :route_order)
  end

  def self.down
    drop_table :temporary_speed_restrictions
  end

end
