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

describe SessionController do

  # Setting

  it "should allow a specific variable to be set" do
    get :set, :key => 'foo', :value => 'bar'
    session['foo'].should eql('bar')
  end

  it "should allow a specific variable to be un-set" do
    get :set, :key => 'foo', :value => 'bar'
    session['foo'].should eql('bar')
    get :clear, :key => 'foo'
    session['foo'].should be_nil
  end

  it "should not raise an error if asked to un-set a variable that doesn't exist" do
    get :clear, :key => 'foo'
    response.should be_success
    session['foo'].should be_nil
  end


  # Toggling

  describe "Variable toggling" do

    it "should toggle a nonexistent variable to true" do
      get :toggle, :key => 'foo'
      session['foo'].should be_true
    end

    it "should toggle a true value to false" do
      session['foo'] = true
      get :toggle, :key => 'foo'
      session['foo'].should be_false
    end

    it "should toggle a false value to true" do
      session['foo'] = false
      get :toggle, :key => 'foo'
      session['foo'].should be_true
    end

    it "should toggle a value to true even if it does not exist" do
      get :toggle_on, :key => 'foo'
      session['foo'].should be_true
    end

    it "should toggle a value to false even if it does not exist" do
      get :toggle_off, :key => 'foo'
      session['foo'].should be_false
    end

    it "should toggle a value to true even if it is already true" do
      session['foo'] = true
      get :toggle_on, :key => 'foo'
      session['foo'].should be_true
    end

    it "should toggle a value to false even if it is already false" do
      session['foo'] = false
      get :toggle_off, :key => 'foo'
      session['foo'].should be_false
    end

    it "should toggle a value to true regardless of whether it's false" do
      session['foo'] = false
      get :toggle_on, :key => 'foo'
      session['foo'].should be_true
    end

    it "should toggle a value to false regardless of whether it's true" do
      session['foo'] = true
      get :toggle_off, :key => 'foo'
      session['foo'].should be_false
    end

  end

end
