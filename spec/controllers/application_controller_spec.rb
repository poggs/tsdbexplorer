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

describe ApplicationController do

  render_views

  controller do
    def index
      render :text => nil and return
    end
  end

  describe "date and time parsing" do

    it "should set the @today instance variable to the current date and time" do
      get :index
      assigns[:today].should be_within(1.minute).of(Time.now)
    end

    it "should allow dates in the format YYYY-MM-DD, YYYYMMDD, DD-MM-YYYY or DD/MM/YYYY" do
      get :index, :date => '2012-01-01'
      assigns[:date].should eql(Date.parse('2012-01-01'))
      get :index, :date => '20120101'
      assigns[:date].should eql(Date.parse('2012-01-01'))
      get :index, :date => '01-01-2012'
      assigns[:date].should eql(Date.parse('2012-01-01'))
      get :index, :date => '01/01/2012'
      assigns[:date].should eql(Date.parse('2012-01-01'))
    end

    it "should identify if a date has been passed in the date parameter or in the year/month/day parameters" do
      get :index
      assigns[:date_passed].should be_false
      get :index, :date => '2012-01-01'
      assigns[:date_passed].should be_true
      get :index, :year => '2012', :month => '01', :day => '01'
      assigns[:date_passed].should be_true
    end

    it "should set the @date instance variable to nil and not set the @date_passed instance variable if no date was passed" do
      get :index, :date => nil
      assigns[:date].should be_nil
      get :index, :date => ''
      assigns[:date].should be_nil
    end

    it "should not allow an invalid date" do
      get :index, :date => '2012-01-32'
      response.code.should_not eql('200')
    end

    it "should allow times in the format HHMM, HH:MM or HH.MM" do
      get :index, :time => '1200'
      assigns[:time_passed].should be_true
      assigns[:time].should eql(Time.parse('12:00'))
      get :index, :time => '12:00'
      assigns[:time_passed].should be_true
      assigns[:time].should eql(Time.parse('12:00'))
      get :index, :time => '12.00'
      assigns[:time_passed].should be_true
      assigns[:time].should eql(Time.parse('12:00'))
    end

    it "should not allow an invalid time" do
      get :index, :time => '56:78'
      response.code.should_not eql('200')
    end

    it "should parse the date and time in to the @datetime instance variable" do
      get :index, :year => '2012', :month => '01', :day => '01', :time => '1200'
      assigns[:date_passed].should be_true
      assigns[:time_passed].should be_true
      assigns[:datetime].should eql(Time.parse('2012-01-01 12:00:00'))
      get :index, :date => '2012-01-01', :time => '1200'
      assigns[:date_passed].should be_true
      assigns[:time_passed].should be_true
      assigns[:datetime].should eql(Time.parse('2012-01-01 12:00:00'))
    end

    it "should set the @datetime instance variable to the date passed and current time if no time was passed" do
      get :index, :year => '2010', :month => '12', :day => '12'
      expected_time = Time.parse('2010-12-12 ' + Time.now.to_s(:hhmm_colon))
      assigns[:datetime].should be_within(1.minute).of(expected_time)
    end

    it "should set the @datetime instance variable to now if the date and time were not passed" do
      get :index
      assigns[:datetime].should be_within(1.minute).of(Time.now)
    end

  end

end
