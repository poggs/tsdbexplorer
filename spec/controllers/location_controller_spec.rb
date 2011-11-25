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

  it "should display services at a location when given a CRS code" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLY'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
  end

  it "should display services at a location when given a CRS code in lower-case" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'bly'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
  end

  it "should display services at a location when given a TIPLOC code" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLTCHLY'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
  end

  it "should display services at a location when given a TIPLOC code in lower-case" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'bltchly'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
  end

  it "should display an error if passed an invalid CRS code" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'ZZZ'
    response.code.should eql('404')
  end

  it "should display an error if passed an invalid TIPLOC" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'ZZZZZZZ'
    response.code.should eql('404')
  end

  it "should display services at a location given a CRS code and date" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLY', :date => '2010-12-12'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
    response.body.should =~ /Sunday 12 December 2010/
  end

  it "should display services at a location given a TIPLOC code and date" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLTCHLY', :date => '2010-12-12'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
    response.body.should =~ /Sunday 12 December 2010/
  end

  it "should display services at a location if the date range spans midnight" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/train_over_midnight.cif')
    get :index, :location => 'LST', :date => '2011-05-22', :time => '23:30'
    response.body.should =~ /Between/
    response.body.should =~ /2300 on Sunday 22 May 2011/
    response.body.should =~ /0030 on Monday 23 May 2011/
    response.body.should =~ /L02600/
  end

  it "should display an error if passed an incorrectly formatted date" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLY', :date => 'FOOBARBAZ999'
    response.code.should eql('400')
    response.body.should =~ /date/
    response.body.should =~ /FOOBARBAZ/
  end

  it "should display an error if passed an invalid date" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLY', :date => '2010-12-32'
    response.code.should eql('400')
    response.body.should =~ /date/
    response.body.should =~ /2010-12-32/
  end

  it "should display services at a location given a CRS code, date and time" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLY', :date => '2010-12-12', :time => '13:00'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
    response.body.should =~ /Sunday 12 December 2010/
  end

  it "should display services at a location given a TIPLOC code, date and time" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLTCHLY', :date => '2010-12-12', :time => '13:00'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
    response.body.should =~ /Sunday 12 December 2010/
  end

  it "should display an error if passed an incorrectly formatted time" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLY', :date => '2010-12-12', :time => 'FOOBAR'
    response.code.should eql('400')
    response.body.should =~ /date/
    response.body.should =~ /2010-12-12/
  end

  it "should display an error if passed an invalid time" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLY', :date => '2010-12-12', :time => '2405'
    response.code.should eql('400')
    response.body.should =~ /date/
    response.body.should =~ /2010-12-12/
    response.body.should =~ /time/
    response.body.should =~ /2405/
  end


  # Location search

  it "should not return any location matches unless a search string is passed" do
    get :search
    response.body.should redirect_to(:controller => 'main', :action => 'index')
  end


  # Station groupings

  it "should include associated TIPLOCs when given a CRS code where the base NLC matches several locations" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/watford_junction_and_dc.cif')
    get :index, :location => 'WFJ', :date => '2011-05-23', :time => '09:00'
    response.body.should =~ /St. Albans Abbey/
    response.body.should =~ /London Euston/
  end

end
