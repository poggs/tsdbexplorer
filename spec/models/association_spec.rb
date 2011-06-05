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
#  $Id: association_spec.rb 109 2011-04-19 21:03:03Z pwh $
#

require 'spec_helper'

describe Association do

  before(:each) do
    @valid_record = { :main_train_uid => 'U00000', :assoc_train_uid => 'U11111', :date => '2011-01-01', :category => 'NP', :date_indicator => 'S', :location => 'EUSTON', :base_location_suffix => ' ', :assoc_location_suffix => ' ', :diagram_type => 'T', :assoc_type => 'O', :stp_indicator => 'N' }
  end

  it "should not be valid when first created" do
    assoc = Association.new
    assoc.should_not be_valid
  end

  it "should be valid with valid attributes" do
    assoc = Association.new(@valid_record)
    assoc.should be_valid
  end

  it "should enforce the format of the main train UID" do

    [ 'U00000', 'A12345' ].each do |valid_data|
      @valid_record[:main_train_uid] = valid_data
      Association.new(@valid_record).should be_valid
    end

    [ nil, '', ' ', '      ', '       ', 'A12', 'A123456', '123456' ].each do |invalid_data|
      @valid_record[:main_train_uid] = invalid_data
      Association.new(@valid_record).should_not be_valid
    end

  end

  it "should enforce the format of the associated train UID" do

    [ 'U00000', 'A12345' ].each do |valid_data|
      @valid_record[:main_train_uid] = valid_data
      Association.new(@valid_record).should be_valid
    end

    [ nil, '', ' ', '      ', '       ', 'A12', 'A123456', '123456' ].each do |invalid_data|
      @valid_record[:main_train_uid] = invalid_data
      Association.new(@valid_record).should_not be_valid
    end

  end

  it "should only allow permitted association categories" do

    [ 'JJ', 'VV', 'NP', '  ' ].each do |valid_data|
      @valid_record[:category] = valid_data
      Association.new(@valid_record).should be_valid
    end

    [ nil, '', 'JJJ', '$$', '00' ].each do |invalid_data|
      @valid_record[:category] = invalid_data
      Association.new(@valid_record).should_not be_valid
    end

  end

  it "should only allow permitted date indicator values" do

    [ 'S', 'N', 'P', ' ' ].each do |valid_data|
      @valid_record[:date_indicator] = valid_data
      Association.new(@valid_record).should be_valid
    end

    [ nil, '', '$', '0', 'A', 'SS' ].each do |invalid_data|
      @valid_record[:date_indicator] = invalid_data
      Association.new(@valid_record).should_not be_valid
    end

  end

  it "should require a location" do

   [ 'EUSTON', 'WATFDJ', 'WATFDJ ' ].each do |valid_data|
     @valid_record[:location] = valid_data
     Association.new(@valid_record).should be_valid
   end

   [ nil, '', '       ' ].each do |invalid_data|
     @valid_record[:location] = invalid_data
     Association.new(@valid_record).should_not be_valid
   end

  end

  it "should require a blank or numeric base main location suffix" do

    [ '', ' ', '1', '9' ].each do |valid_data|
      @valid_record[:base_location_suffix] = valid_data
      Association.new(@valid_record).should be_valid
    end

    [ 'A', '$', '0' ].each do |invalid_data|
      @valid_record[:base_location_suffix] = invalid_data
      Association.new(@valid_record).should_not be_valid
    end

  end

  it "should require a blank or numeric base associated location suffix" do

    [ '', ' ', '1', '9' ].each do |valid_data|
      @valid_record[:assoc_location_suffix] = valid_data
      Association.new(@valid_record).should be_valid
    end

    [ 'A', '$', '0' ].each do |invalid_data|
      @valid_record[:assoc_location_suffix] = invalid_data
      Association.new(@valid_record).should_not be_valid
    end

  end

  it "should require a valid association type" do

    [ 'P', 'O', ' ' ].each do |valid_data|
      @valid_record[:assoc_type] = valid_data
      Association.new(@valid_record).should be_valid
    end

    [ nil, '', 'A', '0', '  ', '$$' ].each do |invalid_data|
      @valid_record[:assoc_type] = invalid_data
      Association.new(@valid_record).should_not be_valid
    end

  end

end
