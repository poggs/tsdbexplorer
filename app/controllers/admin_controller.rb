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

class AdminController < ApplicationController

  def index

    @stats = Hash.new
    @stats[:tiplocs] = Tiploc.count
    @stats[:basic_schedules] = BasicSchedule.count
    @stats[:earliest_schedule] = BasicSchedule.minimum(:runs_from)
    @stats[:latest_schedule] = BasicSchedule.maximum(:runs_to)
    @stats[:daily_schedules] = DailySchedule.count

    @stats[:cifs_imported] = CifFile.count
    @stats[:last_cif_import] = CifFile.maximum(:created_at)

    @stats[:redis_version] = $REDIS.info['redis_version']
    @stats[:td_berths] = $REDIS.keys('TD:*').count

  end

end
