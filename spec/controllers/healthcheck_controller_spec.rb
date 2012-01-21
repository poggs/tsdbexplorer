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

describe HealthcheckController do

  render_views

  it "should return a healthcheck page" do
    get :index
    response.code.should eql("200")
    response.body.should =~ /200 OK/
  end

  it "should return a 200 even if the site is in maintenance mode" do
    TSDBExplorer::Realtime::set_maintenance_mode("test")
    get :index
    response.code.should eql("200")
    response.body.should =~ /200 OK/
    TSDBExplorer::Realtime::clear_maintenance_mode
  end

end
