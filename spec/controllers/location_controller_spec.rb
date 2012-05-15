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

  context "search in simple mode when called as JSON" do

    before do
      TSDBExplorer::Import.locations("test/fixtures/static/wfj-test-location.csv")
      TSDBExplorer::Import.crs_to_tiploc("test/fixtures/static/wfj-test-crs.csv")
    end

    it "should return an empty array when passed no search string" do
      get :search, :format => :json
      matches = JSON.parse(response.body)
      matches.should eql(Array.new)
    end

    it "should return an empty array when passed an empty query string" do
      get :search, :term => '', :format => :json
      matches = JSON.parse(response.body)
      matches.should eql(Array.new)
    end

    it "should return an empty array when passed an 1-character query string" do
      get :search, :term => 'W', :format => :json
      matches = JSON.parse(response.body)
      matches.should eql(Array.new)
    end

    it "should return an empty array when passed a 2-character query string" do
      get 'search', :term => 'WF', :format => :json
      matches = JSON.parse(response.body)
      matches.should eql(Array.new)
    end

    it "should return a single CRS code when passed 3 characters matching a CRS code" do
      get 'search', :term => 'WFJ', :format => :json
      matches = JSON.parse(response.body)
      data = [ { 'id' => 'WFJ', 'label' => 'Watford Junction [WFJ]', 'value' => 'WFJ' } ]
      matches.should eql(data)
    end

    it "should return an empty array when passed 3 characters not matching a CRS code" do
      get 'search', :term => 'EUS', :format => :json
      matches = JSON.parse(response.body)
      matches.should eql(Array.new)
    end

    it "should return a single match when passed more than three characters matching a location name" do
      get 'search', :term => 'Watford Junc', :format => :json
      matches = JSON.parse(response.body)
      data = [ { 'id' => 'WFJ', 'label' => 'Watford Junction [WFJ]', 'value' => 'WFJ' } ]
      matches.should =~ data
    end

    it "should return multiple matches when passed more than three characters matching multiple location names" do
      get 'search', :term => 'Watford', :format => :json
      matches = JSON.parse(response.body)
      data = [ { 'id' => 'WFJ', 'label' => 'Watford Junction [WFJ]', 'value' => 'WFJ' }, { 'id' => 'WFN', 'label' => 'Watford North [WFN]', 'value' => 'WFN' }, { 'id' => 'WFH', 'label' => 'Watford High Street [WFH]', 'value' => 'WFH' } ]
      matches.should =~ data
    end

    it "should return an empty array when passed more than 3 characters not matching a CRS code or location name" do
      get 'search', :term => 'Euston', :format => :json
      matches = JSON.parse(response.body)
      matches.should eql(Array.new)
    end

    it "should not match TIPLOCs" do
      get 'search', :term => 'WATFDJ', :format => :json
      matches = JSON.parse(response.body)
      matches.should eql(Array.new)
    end

  end

  describe "search in advanced mode when called as JSON" do

    before do
      session['advanced'] = true
      TSDBExplorer::Import.locations("test/fixtures/static/wfj-test-location.csv")
      TSDBExplorer::Import.crs_to_tiploc("test/fixtures/static/wfj-test-crs.csv")
    end

    it "should return an empty array when passed no search string" do
      get :search, :format => :json
      matches = JSON.parse(response.body)
      matches.should eql(Array.new)
    end

    it "should return an empty array when passed an empty query string" do
      get :search, :term => '', :format => :json
      matches = JSON.parse(response.body)
      matches.should eql(Array.new)
    end

    it "should return an empty array when passed an 1-character query string" do
      get :search, :term => 'W', :format => :json
      matches = JSON.parse(response.body)
      matches.should eql(Array.new)
    end

    it "should return an empty array when passed a 2-character query string" do
      get 'search', :term => 'WF', :format => :json
      matches = JSON.parse(response.body)
      matches.should eql(Array.new)
    end

    it "should return a single CRS code when passed 3 upper-case characters matching a CRS code" do
      get 'search', :term => 'WFJ', :format => :json
      matches = JSON.parse(response.body)
      data = [ { 'id' => 'WFJ', 'label' => 'Watford Junction [WFJ]', 'value' => 'WFJ' } ]
      matches.should eql(data)
    end

    it "should return a single CRS code when passed 3 lower-case characters matching a CRS code" do
      get 'search', :term => 'wfj', :format => :json
      matches = JSON.parse(response.body)
      data = [ { 'id' => 'WFJ', 'label' => 'Watford Junction [WFJ]', 'value' => 'WFJ' } ]
      matches.should eql(data)
    end

    it "should return a single CRS code when passed 3 mixed-case characters matching a CRS code" do
      get 'search', :term => 'wFj', :format => :json
      matches = JSON.parse(response.body)
      data = [ { 'id' => 'WFJ', 'label' => 'Watford Junction [WFJ]', 'value' => 'WFJ' } ]
      matches.should eql(data)
    end

    it "should return a single TIPLOC when passed characters matching a TIPLOC" do
      get 'search', :term => 'WATFDJ', :format => :json
      matches = JSON.parse(response.body)
      data = [ { 'id' => 'WATFDJ', 'label' => 'Watford Junction [WATFDJ]', 'value' => 'WATFDJ' } ]
      matches.should eql(data)
    end

    it "should return a single TIPLOC when passed mixed-case characters matching a TIPLOC" do
      get 'search', :term => 'wAtFdJ', :format => :json
      matches = JSON.parse(response.body)
      data = [ { 'id' => 'WATFDJ', 'label' => 'Watford Junction [WATFDJ]', 'value' => 'WATFDJ' } ]
      matches.should eql(data)
    end

    it "should return an empty array when passed 3 characters not matching a CRS code" do
      get 'search', :term => 'EUS', :format => :json
      matches = JSON.parse(response.body)
      matches.should eql(Array.new)
    end

    it "should return all matches when passed more than three characters matching a location name and TIPLOC location name" do
      get 'search', :term => 'Watford Junc', :format => :json
      matches = JSON.parse(response.body)
      data = [ { 'id' => 'WATFDJ', 'label' => 'Watford Junction [WATFDJ]', 'value' => 'WATFDJ' }, { 'id' => 'WFJ', 'label' => 'Watford Junction [WFJ]', 'value' => 'WFJ' } ]
      matches.should =~ data
    end

    it "should return all matches when passed more than three mixed-case characters matching a location name and TIPLOC location name" do
pending
      get 'search', :term => 'wAtFoRd JuNc', :format => :json
      matches = JSON.parse(response.body)
      data = [ { 'id' => 'WATFDJ', 'label' => 'Watford Junction [WATFDJ]', 'value' => 'WATFDJ' }, { 'id' => 'WFJ', 'label' => 'Watford Junction [WFJ]', 'value' => 'WFJ' } ]
      matches.should =~ data
    end

    it "should return multiple matches when passed more than three characters matching multiple location names" do
      get 'search', :term => 'Watford', :format => :json
      matches = JSON.parse(response.body)
      data = [ { 'id' => 'WFJ', 'label' => 'Watford Junction [WFJ]', 'value' => 'WFJ'  }, { 'id' => 'WATFDJ', 'label' => 'Watford Junction [WATFDJ]', 'value' => 'WATFDJ' }, { 'id' => 'WFN', 'label' => 'Watford North [WFN]', 'value' => 'WFN' }, { 'id' => 'WATFDN', 'label' => 'Watford North [WATFDN]', 'value' => 'WATFDN' }, { 'id' => 'WFH', 'label' => 'Watford High Street [WFH]', 'value' => 'WFH' }, { 'id' => 'WATFDHS', 'label' => 'Watford High Street [WATFDHS]', 'value' => 'WATFDHS' } ]
      matches.should =~ data
    end

    it "should return an empty array when passed more than 3 characters not matching a CRS code or location name" do
      get 'search', :term => 'Euston', :format => :json
      matches = JSON.parse(response.body)
      matches.should eql(Array.new)
    end

  end

  context "display services at a location in simple mode" do

    before do
      TSDBExplorer::Import.locations("test/fixtures/static/bly-test-location.csv")
      TSDBExplorer::Import.crs_to_tiploc("test/fixtures/static/bly-test-crs.csv")
    end

    # it "should redirect to the search page if passed an invalid CRS code" do
    #   TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    #   get :index, :location => 'ZZZ', :year => '2010', :month => '12', :day => '12', :time => '1800'
    #   response.body.should redirect_to :controller => 'location', :action => 'search', :term => 'ZZZ'
    # end

    it "should display services at a location when given a CRS code, year, month, day and time" do
      TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
      get :index, :location => 'BLY', :year => '2010', :month => '12', :day => '12', :time => '1800'
      response.code.should eql('200')
      response.body.should =~ /Bletchley/
    end

    it "should display services at a location when given a CRS code in lower-case, year, month, day and time" do
      TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
      get :index, :location => 'bly', :year => '2010', :month => '12', :day => '12', :time => '1800'
      response.code.should eql('200')
      response.body.should =~ /Bletchley/
    end

    it "should display services at a location when given a CRS code, year, month and day" do
      TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
      get :index, :location => 'BLY', :year => '2010', :month => '12', :day => '12'
      response.code.should eql('200')
      response.body.should =~ /Bletchley/
      response.body.should =~ /Sunday 12 December 2010/
    end

    it "should display services at a location when given a lower-case CRS code, year, month and day" do
      TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
      get :index, :location => 'bly', :year => '2010', :month => '12', :day => '12'
      response.code.should eql('200')
      response.body.should =~ /Bletchley/
      response.body.should =~ /Sunday 12 December 2010/
    end

    it "should display services at a location now when given a CRS code" do
      TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
      get :index, :location => 'BLY'
      response.code.should eql('200')
      response.body.should =~ /Bletchley/
    end

    it "should display services at a location now when given a lower-case CRS code" do
      TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
      get :index, :location => 'bly'
      response.code.should eql('200')
      response.body.should =~ /Bletchley/
    end

  end


  context "display a message if the location passed is not a TIPLOC or CRS code" do

    it "should show an error if the location passed in simple mode is not a valid CRS code" do
      get :index, :location => 'ZZZ'
      response.code.should eql('404')
      response.body.should =~ /We couldn't find the location/
      response.body.should =~ /ZZZ/
    end

    it "should show an error if the location passed in advanced mode is not a valid CRS code" do
      session[:mode] = 'advanced'
      get :index, :location => 'ZZZ'
      response.code.should eql('404')
      response.body.should =~ /We couldn't find the location/
      response.body.should =~ /ZZZ/
    end

    it "should show an error if the location passed in advanced mode is not a valid TIPLOC" do
      get :index, :location => 'ZZZQQ'
      response.code.should eql('404')
      response.body.should =~ /We couldn't find the location/
      response.body.should =~ /ZZZQQ/
    end

  end

  context "redirect to a location page or fuzzy-search for a location name" do

    before do
      session['advanced'] = true
      TSDBExplorer::Import.locations("test/fixtures/static/wfj-test-location.csv")
      TSDBExplorer::Import.crs_to_tiploc("test/fixtures/static/wfj-test-crs.csv")
    end

    it "should, in normal mode, report if more than one match was found for a mixed-case search string" do
      get :search, :term => 'Watf'
      response.body.should =~ /We couldn't find an exact match for/
      response.body.should =~ /WATF/
      response.body.should =~ /Watford High Street/
      response.body.should =~ /Watford Junction/
      response.body.should =~ /Watford North/
    end

    it "should, in normal mode, report if more than one match was found for a mixed-case search string" do
      get :search, :term => 'Watf'
      response.body.should =~ /We couldn't find an exact match for/
      response.body.should =~ /WATF/
      response.body.should =~ /Watford High Street/
      response.body.should =~ /Watford Junction/
      response.body.should =~ /Watford North/
    end

    it "should, in normal mode, report if more than one match was found for an upper-case search string" do
      session['advanced'] = true
      get :search, :term => 'WATF'
      response.body.should =~ /We couldn't find an exact match for/
      response.body.should =~ /WATF/
      response.body.should =~ /Watford High Street/
      response.body.should =~ /Watford Junction/
      response.body.should =~ /Watford North/
    end

    it "should, in normal mode, report if more than one match was found for an upper-case search string" do
      session['advanced'] = true
      get :search, :term => 'WATF'
      response.body.should =~ /We couldn't find an exact match for/
      response.body.should =~ /WATF/
      response.body.should =~ /Watford High Street/
      response.body.should =~ /Watford Junction/
      response.body.should =~ /Watford North/
    end

  end


  context "highlight specific types of train in advanced mode" do

    before do
      TSDBExplorer::Import.locations("test/fixtures/static/highlight-train-test-location.csv")
      TSDBExplorer::Import.crs_to_tiploc("test/fixtures/static/highlight-train-test-crs.csv")
    end

    it "should highlight trains which run as required when in advanced mode" do
      session['advanced'] = true
      TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/runs_as_required.cif')
      get :index, :location => 'PADTON', :year => '2011', :month => '12', :day => '11', :time => '0600'
      response.body.should =~ /\(Q\)/
    end

    it "should highlight trains which run as required to terminals/yards when in advanced mode" do
      session['advanced'] = true
      TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/runs_as_required.cif')
      get :index, :location => 'EDINBUR', :year => '2012', :month => '01', :day => '09', :time => '0900'
      response.body.should =~ /\(Y\)/
    end

  end

end
