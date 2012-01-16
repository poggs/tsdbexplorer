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

  default_scope :order => 'seq'

  # The 'between' scope will ignore passing times.  The 'passes_between' scope will include passing times.

  scope :between, lambda { |from_time,to_time| where('(locations.arrival BETWEEN ? AND ?) OR (locations.departure BETWEEN ? AND ?)', from_time, to_time, from_time, to_time) }
  scope :passes_between, lambda { |from_time,to_time| where('(locations.arrival BETWEEN ? AND ?) OR (locations.pass BETWEEN ? AND ?) OR (locations.departure BETWEEN ? AND ?)', from_time, to_time, from_time, to_time, from_time, to_time) }

  scope :runs_on, lambda { |date| joins('JOIN basic_schedules ON locations.basic_schedule_uuid = basic_schedules.uuid').where('? BETWEEN basic_schedules.runs_from AND basic_schedules.runs_to', date).where([ 'basic_schedules.runs_su', 'basic_schedules.runs_mo', 'basic_schedules.runs_tu', 'basic_schedules.runs_we', 'basic_schedules.runs_th', 'basic_schedules.runs_fr', 'basic_schedules.runs_sa' ][Date.parse(date).wday] => true ).where('stp_indicator IN (SELECT MIN(stp_indicator) FROM basic_schedules AS bs2 WHERE train_uid = basic_schedules.train_uid AND ? BETWEEN runs_from AND runs_to)', date) }
  scope :only_passenger, lambda { where("category IN ('OL', 'OU', 'OO', 'OW', 'XC', 'XD', 'XI', 'XR', 'XU', 'XX', 'XD', 'XZ', 'BR', 'BS')") }


  # Returns true if this location is a publically advertised location, for
  # example, the origin or destination, calling points and pick-up or
  # set-down points

  def is_public?
    [:activity_tb, :activity_tf, :activity_t, :activity_d, :activity_u].each do |a|
      return true if self.send(a) == true
    end
    return false
  end


  # Returns true if this location is to pick up passengers only

  def pickup_only?
    self.activity_u == true
  end


  # Returns true if this location is to set down passengers only

  def setdown_only?
    self.activity_d == true
  end


  # Returns true if the schedule starts at this location

  def is_origin?
    self.activity_tb == true
  end


  # Returns true if the schedule finishes at this location

  def is_destination?
    self.activity_tf == true
  end


  # Return trains arriving or departing between the specified times

  scope :calls_between, lambda { |from_time,to_time|
    where('(locations.arrival BETWEEN ? AND ?) OR (locations.departure BETWEEN ? AND ?)', from_time, to_time, from_time, to_time)
  }

  scope :passes_between, lambda { |from_time,to_time|
    where('(locations.arrival BETWEEN ? AND ?) OR (locations.pass BETWEEN ? AND ?) OR (locations.departure BETWEEN ? AND ?)', from_time, to_time, from_time, to_time, from_time, to_time)
  }


  # Limits search to trains travelling to or from a particular location

  scope :runs_to, lambda { |loc|
    joins('LEFT JOIN locations loc_to ON locations.basic_schedule_uuid = loc_to.basic_schedule_uuid').where('loc_to.tiploc_code IN (?) AND locations.seq < loc_to.seq', loc)
  }

  scope :runs_from, lambda { |loc|
    joins('LEFT JOIN locations loc_from ON locations.basic_schedule_uuid = loc_from.basic_schedule_uuid').where('loc_from.tiploc_code IN (?) AND locations.seq > loc_from.seq', loc)
  }

end
