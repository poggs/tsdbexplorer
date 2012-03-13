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

describe AdminController do

  render_views
  fixtures :users

  before(:each) do
    @user = users(:user)
    @admin_user = users(:admin_user)
    @pills = [ 'Overview', 'Timetable', 'Real-Time', 'Memory' ]
    $REDIS.flushdb
  end

  it "should not be accessible if not logged in" do
    get :index
    response.should redirect_to :root
  end

  it "should not be accessible if logged in as a normal user" do
    sign_in @user
    get :index
    response.should redirect_to :root
  end

  it "should be accessible if logged in as an admin user" do
    sign_in @admin_user
    get :index
    response.should_not redirect_to :root
  end

  it "should redirect to the overview page" do
    sign_in @admin_user
    get :index
    response.should redirect_to :action => 'overview'
  end

  it "should display an overview page" do
    sign_in @admin_user
    get :overview
    response.code.should eql('200')
    @pills.each do |pill|
      response.body.should match(/#{pill}/)
    end
  end

  it "should display the last time static timetable data was imported" do
    CifFile.create!(:start_date => Date.parse('2011-11-01'), :end_date => Date.parse('2011-12-31'), :update_indicator => 'F', :file_ref => 'DFTESTA', :extract_timestamp => Time.now, :file_mainframe_identity => 'TPS.FDFTEST.PD110101')
    sign_in @admin_user
    get :overview
    response.body.should =~ /Static timetable data/
    response.body.should =~ /icon-ok/
    response.body.should =~ /Last extract imported was TPS.FDFTEST.PD110101 on #{Time.now.to_s(:human)}/
  end

  it "should indicate if static timetable data is stale" do
    CifFile.create!(:start_date => Date.parse('2011-11-01'), :end_date => Date.parse('2011-12-31'), :update_indicator => 'F', :file_ref => 'DFTESTA', :extract_timestamp => Time.now - 7.days, :file_mainframe_identity => 'TPS.FDFTEST.PD110101')
    sign_in @admin_user
    get :overview
    response.body.should =~ /Static timetable data/
    response.body.should =~ /icon-remove/
    response.body.should =~ /Last extract imported was TPS.FDFTEST.PD110101 on #{(Time.now - 7.days).to_s(:human)}/
  end

  it "should display a timetable page" do
    sign_in @admin_user
    get :timetable
    response.code.should eql('200')
    @pills.each do |pill|
      response.body.should include pill
    end
  end

  it "should display a notice if the data import path is not set in tsdbexplorer.yml" do
    original_value = $CONFIG['DATA']
    $CONFIG.delete('DATA')
    sign_in @admin_user
    get :import
    $CONFIG['DATA'] = original_value
    response.body.should =~ /No import directory has been specified in the configuration file/
  end

  it "should show 0 when no CIF files have been imported" do
    sign_in @admin_user
    get :timetable
    response.body.should =~ /CIF files imported.+0/
  end

  it "should show the number of CIF files imported" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    sign_in @admin_user
    get :timetable
    response.body.should =~ /CIF files imported.+1/
  end

  it "should show 0 when no TIPLOCs are known" do
    sign_in @admin_user
    get :timetable
    response.body.should =~ /TIPLOCs known.+0/
  end

  it "should show the number of TIPLOCs known" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    sign_in @admin_user
    get :timetable
    response.body.should =~ /TIPLOCs known.+18/
  end

  it "should show 0 when no Basic Schedules are known" do
    sign_in @admin_user
    get :timetable
    response.body.should =~ /Schedules.+0/
  end

  it "should show the number of Basic Schedules known" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    sign_in @admin_user
    get :timetable
    response.body.should =~ /Schedules.+1/
  end

  it "should display a real-time information page" do
    sign_in @admin_user
    get :realtime
    response.code.should eql('200')
    @pills.each do |pill|
      response.body.should include pill
    end
  end

  it "should show 0 when no TRUST messages have been processed" do
    $REDIS.del('STATS:TRUST:PROCESSED')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Total TRUST messages.+0/
  end

  it "should show 0 when no TRUST messages have been processed" do
    $REDIS.set('STATS:TRUST:PROCESSED', 0)
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Total TRUST messages.+0/
  end

  it "should show the number of TRUST messages processed" do
    $REDIS.set('STATS:TRUST:PROCESSED', 1)
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Total TRUST messages.+1/
  end

  it "should show the number of TRUST activations processed" do
    TSDBExplorer::TDnet::process_trust_message('000120060208122136TRUST               TOPS                NETWORK9E00000001214567890200702081221060725720070208100000C126642005121200000020060609000000VP1M99M002300725720060208110000AN6522112001001')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Activations.+1/
  end

  it "should show the number of TRUST cancellations processed" do
    TSDBExplorer::TDnet::process_trust_message('000220110701065918TRUST               TRUST DA            #QHPA004LWED    522W10M601201107010659005274120110701063000     00000000000000C522W10M60121940001M52121C   ')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Cancellations.+1/
  end

  it "should show the number of TRUST movements processed" do
    TSDBExplorer::TDnet::process_trust_message('000320060105100109TRUST               SDR                 #CF1CV26VDVF    121456789020070104101525421402007010410152620060104101527     00000000000000TAM    AA01214567890223400007171000      000YY7JK42140Y')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Movements.+1/
  end

  it "should show the number of TRUST unidentified train reports processed" do
    TSDBExplorer::TDnet::process_trust_message('000420060105100109ABCDEFGHIJKLMNOPQMMMABCDEFGHIJKLMNOPQNNNAAAABBCCCCCCDDEE12342007030210152512345AUF12AA  ')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Unidentified trains.+1/
  end

  it "should show the number of TRUST train reinstatement reports processed" do
    TSDBExplorer::TDnet::process_trust_message('000520060208160404TRUST               SDR                 #CF1CV26VDVF    1214567890200703061604004214020070306144800     00000000000000651F45MN08223000036671R899')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Reinstatements.+1/
  end

  it "should show the number of TRUST change-of-origin reports processed" do
    TSDBExplorer::TDnet::process_trust_message('000620060208162531TRUST               TRUST DA            #CF1CV26LUAM    1214567890200703021625006531120060302151800     20070302162500129456789922108001AA0671O8MV')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Change of Origin.+1/
  end

  it "should show the number of TRUST change-of-identity reports processed" do
    TSDBExplorer::TDnet::process_trust_message('000720060209060142TRUST               TOPS                        CY99996 121456789020070302152714422X112Q08422P182Q0822320003005')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Change of Identity.+1/
  end

  it "should show the number of TRUST change-of-location reports processed" do
    TSDBExplorer::TDnet::process_trust_message('000820060105100109ABCDEFGHIJKLMNOPQMMMABCDEFGHIJKLMNOPQNNNAAAABBCCCCCCDDEE121456789020070302101525123452007030210152612345200601041015261214567890ABCDEFGHABC')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Change of Location.+1/
  end

  it "should show 0 when no TD messages have been processed" do
    $REDIS.del('STATS:TD:PROCESSED')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Total TD messages.+0/
  end

  it "should show 0 when no TD messages have been processed" do
    $REDIS.set('STATS:TD:PROCESSED', 0)
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Total TD message.+0/
  end

  it "should show the number of TD messages processed" do
    TSDBExplorer::TDnet::process_smart_message('<CT_MSG>ZZCT0000000000</CT_MSG>')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Total TD messages.+1/
    TSDBExplorer::TDnet::process_smart_message('<CT_MSG>ZZCT0001000100</CT_MSG>')
    get :realtime
    response.body.should =~ /Total TD messages.+2/
  end

  it "should show the number of TD areas for which information has been received" do
    TSDBExplorer::TDnet::process_smart_message('<CA_MSG>ZZCA000100029Z99000001</CA_MSG>')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Number of TD areas seen.+1/
    TSDBExplorer::TDnet::process_smart_message('<CA_MSG>YYCA100110028Z88000002</CA_MSG>')
    get :realtime
    response.body.should =~ /Number of TD areas seen.+2/
  end

  it "should show 0 when no CA, CB, CC or CT messages have been processed" do
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Berth Step \(CA\) messages.+0/
    response.body.should =~ /Berth Cancel \(CB\) messages.+0/
    response.body.should =~ /Berth Interpose \(CC\) messages.+0/
    response.body.should =~ /Berth Heartbeat \(CT\) messages.+0/
  end

  it "should show the number of CA messages processed" do
    TSDBExplorer::TDnet::process_smart_message('<CA_MSG>ZZCA000100029Z99000001</CA_MSG>')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Berth Step \(CA\) messages.+1/
    TSDBExplorer::TDnet::process_smart_message('<CA_MSG>YYCA100110028Z88000002</CA_MSG>')
    get :realtime
    response.body.should =~ /Berth Step \(CA\) messages.+2/
  end

  it "should show the number of CB messages processed" do
    TSDBExplorer::TDnet::process_smart_message('<CB_MSG>ZZCB00019Z99000001</CB_MSG>')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Berth Cancel \(CB\) messages.+1/
    TSDBExplorer::TDnet::process_smart_message('<CB_MSG>ZZCB00028Z88000002</CB_MSG>')
    get :realtime
    response.body.should =~ /Berth Cancel \(CB\) messages.+2/
  end

  it "should show the number of CC messages processed" do
    TSDBExplorer::TDnet::process_smart_message('<CC_MSG>ZZCCFOO00001000001</CC_MSG>')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Berth Interpose \(CC\) messages.+1/
    TSDBExplorer::TDnet::process_smart_message('<CC_MSG>ZZCCBAR00002000002</CC_MSG>')
    get :realtime
    response.body.should =~ /Berth Interpose \(CC\) messages.+2/
  end

  it "should show the number of CT messages processed" do
    TSDBExplorer::TDnet::process_smart_message('<CT_MSG>ZZCT0001000100</CT_MSG>')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Berth Heartbeat \(CT\) messages.+1/
    TSDBExplorer::TDnet::process_smart_message('<CT_MSG>ZZCT0002000200</CT_MSG>')
    get :realtime
    response.body.should =~ /Berth Heartbeat \(CT\) messages.+2/
  end

  it "should show 0 when no VSTP messages have been processed" do
    $REDIS.del('STATS:VSTP:PROCESSED')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Total VSTP messages.+0/
  end

  it "should show 0 when no VSTP messages have been processed" do
    $REDIS.set('STATS:VSTP:PROCESSED', 0)
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Total VSTP messages.+0/
  end

  it "should show the number of VSTP messages processed" do
    $REDIS.set('STATS:VSTP:PROCESSED', 1)
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Total VSTP messages.+1/
  end

  it "should show 0 when no TSR messages have been processed" do
    $REDIS.del('STATS:TSR:PROCESSED')
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Total TSR messages.+0/
  end

  it "should show 0 when no TSR messages have been processed" do
    $REDIS.set('STATS:TSR:PROCESSED', 0)
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Total TSR messages.+0/
  end

  it "should show the number of TSR messages processed" do
    $REDIS.set('STATS:TSR:PROCESSED', 1)
    sign_in @admin_user
    get :realtime
    response.body.should =~ /Total TSR messages.+1/
  end

  it "should display an in-memory database information page" do
    sign_in @admin_user
    get :memory
    response.code.should eql('200')
    @pills.each do |pill|
      response.body.should include pill
    end
  end

  it "should show the daemon version and architecture type" do
    sign_in @admin_user
    get :memory
    response.body.should =~ /Redis daemon version/
    response.body.should =~ /Architecture/
  end

  it "should show the daemon uptime" do
    sign_in @admin_user
    get :memory
    response.body.should =~ /Uptime/
  end

  it "should show the amount of memory in use" do
    sign_in @admin_user
    get :memory
    response.body.should =~ /Memory usage/
  end

  it "should show the number of commands processed" do
    sign_in @admin_user
    get :memory
    response.body.should =~ /Commands processed/
  end

  it "should include a link to the user administration page" do
    sign_in @admin_user
    get :overview
    response.body.should =~ /Manage users/
  end

end
