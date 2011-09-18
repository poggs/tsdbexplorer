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

class Location < ActiveRecord::Base

  belongs_to :basic_schedule, :primary_key => :uuid, :foreign_key => :basic_schedule_uuid
  has_one :tiploc, :primary_key => :tiploc_code, :foreign_key => :tiploc_code

  # The 'between' scope will ignore passing times.  The 'passes_between' scope will include passing times.

  scope :between, lambda { |from_time,to_time| where('(arrival BETWEEN ? AND ?) OR (departure BETWEEN ? AND ?) AND pass IS NULL AND (public_arrival IS NOT NULL AND public_departure IS NOT NULL)', from_time, to_time, from_time, to_time) }
  scope :passes_between, lambda { |from_time,to_time| where('(arrival BETWEEN ? AND ?) OR (pass BETWEEN ? AND ?) OR (departure BETWEEN ? AND ?)', from_time, to_time, from_time, to_time, from_time, to_time) }

  scope :runs_on, lambda { |date| joins('JOIN basic_schedules ON locations.basic_schedule_uuid = basic_schedules.uuid').where('? BETWEEN basic_schedules.runs_from AND basic_schedules.runs_to', date).where([ 'basic_schedules.runs_su', 'basic_schedules.runs_mo', 'basic_schedules.runs_tu', 'basic_schedules.runs_we', 'basic_schedules.runs_th', 'basic_schedules.runs_fr', 'basic_schedules.runs_sa' ][Date.parse(date).wday] => true ) }


  # Returns true if this location is a publically advertised location, for
  # example, the origin or destination, calling points and pick-up or
  # set-down points

  def is_public?
    ['TB','TF','T','D','U'].include? self.activity
  end


  # Returns true if this location is to pick up passengers only

  def pickup_only?
    self.activity == "U"
  end


  # Returns true if this location is to set down passengers only

  def setdown_only?
    self.activity == "D"
  end

end
