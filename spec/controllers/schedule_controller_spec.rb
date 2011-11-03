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

describe ScheduleController do

  render_views

  it "should display a planned schedule" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :schedule_by_uid, :uid => 'C43391'
  end

  it "should return an error if passed an invalid schedule" do
    get :schedule_by_uid, :uid => 'Z99999'
    response.code.should eql("404")
    response.body.should =~ /schedule Z99999/
  end

  it "should return an error if passed a valid schedule and invalid run date" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :schedule_by_uid_and_run_date, :uid => 'C43391', :date => '2010-12-13'
    response.code.should eql("404")
    response.body.should =~ /schedule C43391/
    response.body.should =~ /running on 2010-12-13/
  end

  it "should return an error if passed an invalid schedule and invalid run date" do
    get :schedule_by_uid_and_run_date, :uid => 'Z99999', :date => '2011-01-01'
    response.code.should eql("404")
    response.body.should =~ /schedule Z99999/
  end

  it "should allow a searching for a train by a train UID or train identity" do
    get :search, :target_date => '2011-01-01', :schedule => '1Z99'
  end

  it "should display an as-run schedule"
  it "should return an error if passed an invalid as-run schedule"

end
