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

class TemporarySpeedRestriction < ActiveRecord::Base

  validates_presence_of :tsr_id
  validates_presence_of :route_group_name
  validates_presence_of :tsr_id
  validates_presence_of :route_group_name
  validates_presence_of :route_code
  validates_presence_of :route_order
  validates_presence_of :tsr_reference
  validates_presence_of :from_location
  validates_presence_of :to_location
  validates_presence_of :line_name
  validates_presence_of :subunit_type
  validates_presence_of :mileage_from
  validates_presence_of :subunit_from
  validates_presence_of :mileage_to
  validates_presence_of :subunit_to
  validates_presence_of :moving_mileage
  validates_presence_of :passenger_speed
  validates_presence_of :freight_speed
  validates_presence_of :valid_from_date
  validates_presence_of :valid_to_date
  validates_presence_of :reason
  validates_presence_of :requestor
  validates_presence_of :comments
  validates_presence_of :direction

end
