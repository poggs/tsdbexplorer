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

require 'spec_helper'

describe Location do

  it "should allow only origin, intermediate and terminating locations"
  it "should require a valid set of fields for an origin location"
  it "should require a valid set of fields for an intermediate location"
  it "should require a valid set of fields for a terminating location"

  it "should not allow an arrival time for an origin location"
  it "should not allow a departure time for a terminating location"

  it "should not allow a path for an origin location"
  it "should not allow a line for a terminating location"

  it "should allow only valid activities to occur at a location"

end
