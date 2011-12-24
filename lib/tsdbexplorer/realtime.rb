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

module TSDBExplorer

  module Realtime

    # Put the site in to maintenance mode

    def Realtime.set_maintenance_mode(reason)
      $REDIS.set('OTT:SYSTEM:MAINT', reason)
    end


    # Take the site out of maintenance mode

    def Realtime.clear_maintenance_mode
      $REDIS.del('OTT:SYSTEM:MAINT')
    end

  end

end

