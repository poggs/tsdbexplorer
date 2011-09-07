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

describe CifFile do

  before(:each) do
    @valid_data = { :file_ref => 'DFTESTA', :extract_timestamp => Time.parse('2011-01-01 19:00:00'), :start_date => Date.parse('2011-01-01'), :end_date => Date.parse('2011-12-31'), :update_indicator => 'F' }
  end

  it "should not be valid when first created" do
    CifFile.new.should_not be_valid
  end

  it "should be valid with correct data" do
    CifFile.new(@valid_data).should be_valid
  end

  it "should not be valid without a file reference" do
    @valid_data[:file_ref] = nil
    CifFile.new(@valid_data).should_not be_valid
  end

  it "should not be valid with an incorrectly formatted file reference" do
    ['', 'FOO', 'ZZFOOOA', 'DFTEST0', 'DFTEST'].each do |invalid_file_ref|
      @valid_data[:file_ref] = invalid_file_ref
      CifFile.new(@valid_data).should_not be_valid
    end
  end

  it "should not be valid without an extract timestamp" do
    @valid_data[:extract_timestamp] = nil
    CifFile.new(@valid_data).should_not be_valid
  end

  it "should not be valid without a start date" do
    @valid_data[:start_date] = nil
    CifFile.new(@valid_data).should_not be_valid
  end

  it "should not be valid without an end date" do
    @valid_data[:end_date] = nil
    CifFile.new(@valid_data).should_not be_valid
  end

  it "should not be valid without an update indicator" do
    @valid_data[:update_indicator] = nil
    CifFile.new(@valid_data).should_not be_valid
  end

  it "should be valid with an update indicator of either F or U" do
    ['F', 'U'].each do |valid_update_indicator|
      @valid_data[:update_indicator] = valid_update_indicator
      CifFile.new(@valid_data).should be_valid
    end
  end

  it "should not be valid with an invalid update indicator" do
    ['', '0', 'Z'].each do |invalid_update_indicator|
      @valid_data[:update_indicator] = invalid_update_indicator
      CifFile.new(@valid_data).should_not be_valid
    end
  end

end
