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

describe GeoController do

  it "should render the index page when called with a non-empty database" do
    GeoElr.create!({ :elr_code => 'FOO1', :line_name => 'Foo to Bar' })
    get :index
    response.should render_template('index')
  end

  it "should render the setup page when called with an empty database" do
    get :setup
    response.should render_template('setup')
  end

  it "should redirect to a setup page when called with an empty database" do
    get :index
    response.should redirect_to :controller => 'geo', :action => 'setup'
  end

  it "should redirect to the index page when the setup page is called with a non-empty database" do
    GeoElr.create!({ :elr_code => 'FOO1', :line_name => 'Foo to Bar' })
    get :setup
    response.body.should redirect_to :controller => 'geo', :action => 'index'
  end

  it "should allow searching the ELRs" do
    get :search, :term => 'foo'
  end

end
