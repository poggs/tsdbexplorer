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

class DailyScheduleLocation < ActiveRecord::Base

  belongs_to :daily_schedule, :primary_key => :uuid, :foreign_key => :daily_schedule_uuid
  has_one :tiploc, :primary_key => :tiploc_code, :foreign_key => :tiploc_code

  def origin
    self.locations.first
  end

  def terminate
    self.locations.last
  end

end
