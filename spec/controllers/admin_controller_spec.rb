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

  before(:each) do
    @pills = [ 'Overview', 'Timetable', 'Real-Time', 'Memory' ]
  end

  it "should redirect to the overview page" do
    get :index
    response.should redirect_to :action => 'overview'
  end

  it "should display an overview page" do
    get :overview
    response.code.should eql('200')
    @pills.each do |pill|
      response.body.should match(/#{pill}/)
    end
  end

  it "should display the last time static timetable data was imported" do
    CifFile.create!(:start_date => Date.parse('2011-11-01'), :end_date => Date.parse('2011-12-31'), :update_indicator => 'F', :file_ref => 'DFTESTA', :extract_timestamp => Time.now, :file_mainframe_identity => 'TPS.FDFTEST.PD110101')
    get :overview
    response.body.should =~ /Static timetable data/
    response.body.should =~ /tick.png/
    response.body.should =~ /Last extract imported was TPS.FDFTEST.PD110101 on #{Time.now.to_s}/
  end

  it "should indicate if static timetable data is stale" do
    CifFile.create!(:start_date => Date.parse('2011-11-01'), :end_date => Date.parse('2011-12-31'), :update_indicator => 'F', :file_ref => 'DFTESTA', :extract_timestamp => Time.now - 7.days, :file_mainframe_identity => 'TPS.FDFTEST.PD110101')
    get :overview
    response.body.should =~ /Static timetable data/
    response.body.should =~ /cross.png/
    response.body.should =~ /Last extract imported was TPS.FDFTEST.PD110101 on #{(Time.now - 7.days).to_s}/
  end

  it "should display a timetable page" do
    get :timetable
    response.code.should eql('200')
    @pills.each do |pill|
      response.body.should include pill
    end
  end

  it "should show 0 when no CIF files have been imported" do
    get :timetable
    response.body.should =~ /0 CIF files have been imported/
  end

  it "should show the number of CIF files imported" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :timetable
    response.body.should =~ /1 CIF files have been imported/
  end

  it "should show 0 when no TIPLOCs are known" do
    get :timetable
    response.body.should =~ /0 timing point locations are known/
  end

  it "should show the number of TIPLOCs known" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :timetable
    response.body.should =~ /18 timing point locations are known/
  end

  it "should show 0 when no Basic Schedules are known" do
    get :timetable
    response.body.should =~ /0 schedules are known/
  end

  it "should show the number of Basic Schedules known" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :timetable
    response.body.should =~ /1 schedules are known/
  end

  it "should show the date of the earliest and latest basic schedules" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :timetable
    response.body.should =~ /covering the period from Sunday 12th December 2010 to Sunday 15th May 2011/
  end

  it "should display a real-time information page" do
    get :realtime
    response.code.should eql('200')
    @pills.each do |pill|
      response.body.should include pill
    end
  end

  it "should show 0 when no TRUST messages have been processed" do
    $REDIS.del('STATS:TRUST:PROCESSED')
    get :realtime
    response.body.should =~ /0 TRUST messages processed/
  end

  it "should show 0 when no TRUST messages have been processed" do
    $REDIS.set('STATS:TRUST:PROCESSED', 0)
    get :realtime
    response.body.should =~ /0 TRUST messages processed/
  end

  it "should show the number of TRUST messages processed" do
    $REDIS.set('STATS:TRUST:PROCESSED', 1)
    get :realtime
    response.body.should =~ /1 TRUST messages processed/
  end

  it "should show 0 when no TD messages have been processed" do
    $REDIS.del('STATS:TD:PROCESSED')
    get :realtime
    response.body.should =~ /0 train describer messages processed/
  end

  it "should show 0 when no TD messages have been processed" do
    $REDIS.set('STATS:TD:PROCESSED', 0)
    get :realtime
    response.body.should =~ /0 train describer messages processed/
  end

  it "should show the number of TD messages processed" do
    $REDIS.set('STATS:TD:PROCESSED', 1)
    get :realtime
    response.body.should =~ /1 train describer messages processed/
  end

  it "should show 0 when no VSTP messages have been processed" do
    $REDIS.del('STATS:VSTP:PROCESSED')
    get :realtime
    response.body.should =~ /0 VSTP messages processed/
  end

  it "should show 0 when no VSTP messages have been processed" do
    $REDIS.set('STATS:VSTP:PROCESSED', 0)
    get :realtime
    response.body.should =~ /0 VSTP messages processed/
  end

  it "should show the number of VSTP messages processed" do
    $REDIS.set('STATS:VSTP:PROCESSED', 1)
    get :realtime
    response.body.should =~ /1 VSTP messages processed/
  end

  it "should show 0 when no TSR messages have been processed" do
    $REDIS.del('STATS:TSR:PROCESSED')
    get :realtime
    response.body.should =~ /0 TSR messages processed/
  end

  it "should show 0 when no TSR messages have been processed" do
    $REDIS.set('STATS:TSR:PROCESSED', 0)
    get :realtime
    response.body.should =~ /0 TSR messages processed/
  end

  it "should show the number of TSR messages processed" do
    $REDIS.set('STATS:TSR:PROCESSED', 1)
    get :realtime
    response.body.should =~ /1 TSR messages processed/
  end

  it "should display an in-memory database information page" do
    get :memory
    response.code.should eql('200')
    @pills.each do |pill|
      response.body.should include pill
    end
  end

  it "should show the daemon version and architecture type" do
    get :memory
    response.body.should =~ /Daemon version/
    response.body.should =~ /bit architecture/
  end

  it "should show the daemon uptime" do
    get :memory
    response.body.should =~ /Up for \d+ seconds/
  end

  it "should show the amount of memory in use" do
    get :memory
    response.body.should =~ /Holding .+K memory/
  end

  it "should show the number of commands processed" do
    get :memory
    response.body.should =~ /Processed \d+ commands/
  end

end
	