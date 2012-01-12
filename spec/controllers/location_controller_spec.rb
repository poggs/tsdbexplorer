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

describe LocationController do

  render_views

  it "should redirect to a URL which includes the current date and time" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLY'
    response.should redirect_to(:action => 'index', :year => Date.today.year.to_i, :month => Date.today.month.to_i, :day => Date.today.day.to_i, :time => Time.now.strftime('%H%M'))
  end

  it "should display services at a location when given a CRS code" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/record_bs_new_fullextract.msn')
    get :index, :location => 'BLY', :year => '2010', :month => '12', :day => '12', :time => '1800'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
  end

  it "should display services at a location when given a CRS code in lower-case" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/record_bs_new_fullextract.msn')
    get :index, :location => 'bly', :year => '2010', :month => '12', :day => '12', :time => '1800'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
  end

  it "should display services at a location when given a TIPLOC code in advanced mode" do
    pending
    session[:mode] = 'advanced'
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLTCHLY', :year => '2010', :month => '12', :day => '12', :time => '1800'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
  end

  it "should display services at a location when given a TIPLOC code in lower-case" do
    pending
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'bltchly', :year => '2010', :month => '12', :day => '12', :time => '1800'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
  end

  it "should redirect to the search page if passed an invalid CRS code" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/record_bs_new_fullextract.msn')
    get :index, :location => 'ZZZ', :year => '2010', :month => '12', :day => '12', :time => '1800'
    response.body.should redirect_to :controller => 'location', :action => 'search', :term => 'ZZZ'
  end

  it "should display an error if passed an invalid TIPLOC in advanced mode" do
    session[:mode] = 'advanced'
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'ZZZZZZZ', :year => '2010', :month => '12', :day => '12', :time => '1800'
    response.body.should redirect_to :controller => 'location', :action => 'search', :term => 'ZZZZZZZ'
  end

  it "should display services at a location given a CRS code and date" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/record_bs_new_fullextract.msn')
    get :index, :location => 'BLY', :year => '2010', :month => '12', :day => '12'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
    response.body.should =~ /Sunday 12 December 2010/
  end

  it "should display services at a location given a TIPLOC code and date in advanced mode" do
    session[:mode] = 'advanced'
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/record_bs_new_fullextract.msn')
    get :index, :location => 'BLTCHLY', :year => '2010', :month => '12', :day => '12'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
    response.body.should =~ /Sunday 12 December 2010/
  end

  it "should display services at a location if the date range spans midnight" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/train_over_midnight.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/train_over_midnight.msn')
    get :index, :location => 'LST', :year => '2011', :month => '05', :day => '22', :time => '2330'
    response.body.should =~ /Between/
    response.body.should =~ /2300 on Sunday 22 May 2011/
    response.body.should =~ /0030 on Monday 23 May 2011/
    response.body.should =~ /L02600/
  end

  it "should display an error if passed an incorrectly formatted date" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLY', :year => 'FOO', :month => 'BAR', :day => 'BAZ'
    response.code.should eql('400')
    response.body.should =~ /invalid date/
  end

  it "should display an error if passed an invalid date" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLY', :year => '2010', :month => '12', :day => '32'
    response.code.should eql('400')
    response.body.should =~ /invalid date/
  end

  it "should display services at a location given a CRS code, date and time" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/record_bs_new_fullextract.msn')
    get :index, :location => 'BLY', :year => '2010', :month => '12', :day => '12', :time => '1300'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
    response.body.should =~ /Sunday 12 December 2010/
  end

  it "should display services at a location given a TIPLOC code, date and time" do
    session[:mode] = 'advanced'
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/record_bs_new_fullextract.msn')
    get :index, :location => 'BLTCHLY', :year => '2010', :month => '12', :day => '12', :time => '1300'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
    response.body.should =~ /Sunday 12 December 2010/
  end

  it "should display an error if passed an incorrectly formatted time" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLY', :year => '2010', :month => '12', :day => '12', :time => 'FOOBAR'
    response.code.should eql('400')
    response.body.should =~ /invalid date/
  end

  it "should display an error if passed an invalid time" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLY', :year => '2010', :month => '12', :day => '12', :time => '2405'
    response.code.should eql('400')
    response.body.should =~ /invalid date/
  end


  # Location search

  it "should redirect to the main page when no search string is passed" do
    get :search
    response.body.should redirect_to(:controller => 'main', :action => 'index')
  end

  it "should return an empty JSON array when no search string is passed and the format is JSON" do
    get 'search.json'
    matches = JSON.parse(response.body)
    matches.should eql(Array.new)
  end

  it "should return a JSON array containing the exact match CRS code when passed a CRS code and the format is JSON" do
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/watford_junction.msn')
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/watford_junction_and_dc.cif')
    get 'search', :format => :json, :term => 'WFJ'
    matches = JSON.parse(response.body)
    matches.length.should eql(1)
    matches[0]['id'].should eql('WFJ')
    matches[0]['label'].should eql('Watford Junction')
    matches[0]['value'].should eql('Watford Junction')
  end


  it "should, in normal mode, report if no matches for a search string were found" do
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/watford_junction.msn')
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/watford_junction_and_dc.cif')
    get :search, :term => 'FOOBARBAZ'
    response.body.should =~ /We couldn't find any location that matched/
    response.body.should =~ /FOOBARBAZ/
  end

  it "should, in normal mode, report if more than one match was found for a search string" do
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/watford_junction.msn')
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/watford_junction_and_dc.cif')
    get :search, :term => 'WATF'
    response.body.should =~ /We couldn't find an exact match for/
    response.body.should =~ /WATF/
    response.body.should =~ /Watford High Street/
    response.body.should =~ /Watford Junction/
    response.body.should =~ /Watford North/
  end

  it "should, in normal mode, match CRS codes from the MSNF" do
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/watford_junction.msn')
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/watford_junction_and_dc.cif')
    get :search, :term => 'WFJ'
    response.body.should redirect_to :controller => 'location', :action => 'index', :location => 'WFJ'
  end

  it "should not, in normal mode, match CRS codes from the CIF file" do
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/empty.msn')
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/barking.cif')
    get :search, :term => 'ZBK'
    response.body.should_not =~ /BARKING/
  end

  it "should not, in normal mode, match TIPLOCs from the CIF file" do
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/watford_junction.msn')
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/watford_junction_and_dc.cif')
    get :search, :term => 'WATFDJ'
    response.body.should_not =~ /Watford Junction/
  end

  it "should match CRS codes from the MSNF in advanced mode" do
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/watford_junction.msn')
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/watford_junction_and_dc.cif')
    session[:mode] = 'advanced'
    get :search, :term => 'WFJ'
    response.body.should redirect_to :controller => 'location', :action => 'index', :location => 'WFJ'
  end

#  it "should match CRS codes from the CIF file in advanced mode" do
#    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/empty.msn')
#    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/barking.cif')
#    session[:mode] = 'advanced'
#    get :search, :term => 'ZBK'
#    response.body.should redirect_to :controller => 'location', :action => 'index', :location => 'ZBK'
#  end

#  it "should match TIPLOCS codes from the CIF file in advanced mode" do
#    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/watford_junction.msn')
#    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/watford_junction_and_dc.cif')
#    session[:mode] = 'advanced'
#    get :search, :term => 'WATFDJ'
#    response.body.should redirect_to :controller => 'location', :action => 'index', :location => 'WATFDJ'
#  end

#  it "should return an exact match for a CRS code from CIF even if a location with a longer matched name exists" do
#    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/accrington_and_acton_central.cif')
#    get :search, :term => 'ACC'
#    response.body.should redirect_to :controller => 'location', :action => 'index', :location => 'ACC'
#  end


#  it "should return an exact match for a CRS code from the MSNF even if a location with a longer matched name exists" do
#    pending
#    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/accrington_and_acton_central.cif')
#    get :search, :term => 'ACC'
#    response.body.should =~ /Acton Central/
#    response.body.should_not =~ /Accrington/
#  end

#  it "should match on both an exact CRS code and a matched name from the MSNF if the format is JSON" do
#    pending
#    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/accrington_and_acton_central.cif')
#    get 'search.json', :term => 'ACC'
#    response.body.should =~ /Acton Central/
#    response.body.should =~ /Accrington/
#  end


  # Station groupings

  it "should include associated TIPLOCs from the MSNF when given a CRS code in normal mode" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/watford_junction_and_dc.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/watford_junction.msn')
    get :index, :location => 'WFJ', :year => '2011', :month => '05', :day => '23', :time => '0900'
    response.body.should =~ /St. Albans Abbey/
    response.body.should =~ /London Euston/
  end

  it "should include associated TIPLOCs from the MSNF when given a CRS code in advanced mode" do
    session[:mode] = 'advanced'
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/watford_junction_and_dc.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/watford_junction.msn')
    get :index, :location => 'WFJ', :year => '2011', :month => '05', :day => '23', :time => '0900'
    response.body.should =~ /St. Albans Abbey/
    response.body.should =~ /London Euston/
  end

  it "should not include associated TIPLOCs from the MSNF when given a TIPLOC code in advanced mode" do
    session[:mode] = 'advanced'
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/watford_junction_and_dc.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/watford_junction.msn')
    get :index, :location => 'WATFJDC', :year => '2011', :month => '05', :day => '23', :time => '0900'
    response.body.should_not =~ /St. Albans Abbey/
    response.body.should =~ /London Euston/
  end


  # Show only trains to and from

  it "should only show trains which later call at at a specified location" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/abbey_line_sunday.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/abbey_line_sunday.msn')
    get :index, :location => 'WFJ', :year => '2011', :month => '12', :day => '18', :time => '0830', :to => 'HOWWOOD'
    response.body.should =~ /C51784/
    response.body.should_not =~ /C51786/
  end

  it "should only show trains which have called previously at a specified location" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/abbey_line_sunday.cif')
    TSDBExplorer::RSP::import_msnf('test/fixtures/msnf/abbey_line_sunday.msn')
    get :index, :location => 'HWW', :year => '2011', :month => '12', :day => '18', :time => '0830', :to => 'WATFDJ'
    response.body.should =~ /C51786/
    response.body.should_not =~ /C51784/
  end

end
