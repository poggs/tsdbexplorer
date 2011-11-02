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
    get :index, :location => 'BLY', :date => '2010-12-12', :time => '1300'
    response.code.should eql('200')
    response.body.should =~ /Bletchley/
    response.body.should =~ /Sunday 12 December 2010/
  end

  it "should display services at a location given a TIPLOC code, date and time" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index, :location => 'BLTCHLY', :date => '2010-12-12', :time => '1300'
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

end
