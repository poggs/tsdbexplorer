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

  it "should highlight a train that has not yet been activated by TRUST" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/euston_to_glasgow.cif')
    get :schedule_by_uid_and_run_date, :uid => 'P64836', :date => '2011-11-02'
    response.code.should eql("200")
    response.body.should =~ /Real-time information/
    response.body.should =~ /not yet available/
  end

  it "should highlight a train that has been activated by TRUST, but not left its origin" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/euston_to_glasgow.cif')
    TSDBExplorer::TDnet::process_trust_message('000120111102183031TRUST               TSIA                                721S06MY02201111021830317241020111102193000P648362017101100000020091211000000CP1S06M000007241020111102193000AN6522112001   ')
    get :schedule_by_uid_and_run_date, :uid => 'P64836', :date => '2011-11-02'
    response.code.should eql("200")
    response.body.should =~ /Real-time information/
    response.body.should =~ /departed London Euston/
  end

  it "should highlight a train that has been activated by TRUST, and departed from its origin" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/euston_to_glasgow.cif')
    get :schedule_by_uid_and_run_date, :uid => 'P64836', :date => '2011-11-02'
    TSDBExplorer::TDnet::process_trust_message('000120111102183031TRUST               TSIA                                721S06MY02201111021830317241020111102193000P648362017101100000020091211000000CP1S06M000007241020111102193000AN6522112001   ')
    TSDBExplorer::TDnet::process_trust_message('000320111102193006TRUST               SMART                               721S06MY0220111102192900724102011110219300020111102193000     00000000000000DDA  DE131721S06MY02221120016565001E72316002 Y   72410Y')
    response.code.should eql("200")
    response.body.should =~ /Real-time information/
    response.body.should =~ /available for this train/
  end

  it "should not display real-time information for bus services" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_bus.cif')
    get :schedule_by_uid_and_run_date, :uid => 'G39152', :date => '2011-05-22'
    response.code.should eql("200")
    response.body.should_not =~ /Real-time information/
  end

  it "should not display real-time information for ship services" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_ship.cif')
    get :schedule_by_uid_and_run_date, :uid => 'P87065', :date => '2011-05-22'
    response.code.should eql("200")
    response.body.should_not =~ /Real-time information/
  end

end
