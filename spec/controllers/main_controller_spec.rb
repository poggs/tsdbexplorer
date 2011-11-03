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
#  $Id: main_controller_spec.rb 108 2011-04-19 20:25:19Z pwh $
#

require 'spec_helper'

describe MainController do

  render_views

  it "should redirect to a setup page when called with an empty database" do
    get :index
    response.should redirect_to :action => :setup
  end

  it "should show an informational page when called with an empty database" do
    get :setup
    response.code.should eql("200")
    response.body.should =~ /You will need some CIF timetable data/
  end

end
