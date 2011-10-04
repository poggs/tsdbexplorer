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
    @valid_data = { :main_train_uid => 'A12345', :assoc_train_uid => 'B23456', :association_start_date => Date.parse('2011-01-01'), :association_end_date => Date.parse('2011-12-31'), :valid_mo => 1, :valid_tu => 1, :valid_we => 1, :valid_th => 1, :valid_fr => 1, :valid_sa => 0, :valid_su => 0, :category => 'VV', :date_indicator => 'S', :location => 'EUSTON', :base_location_suffix => '', :assoc_location_suffix => '', :diagram_type => 'T', :assoc_type => 'P', :stp_indicator => 'P' }
  end

  it "should not be valid when first created" do
    assoc = Association.new
    assoc.should_not be_valid
  end

  it "should be valid with acceptable inputs" do
    assoc = Association.new(@valid_data)
    assoc.should be_valid
  end

  it "should validate the format of the main train UID" do
    assoc = Association.new(@valid_data)
    ['A12345', 'Z99999'].each do |valid_uid|
      assoc[:main_train_uid] = valid_uid
      assoc.should be_valid
    end
    [nil, '', '123456', 'AAAAAA', 'A1234567', '______'].each do |invalid_uid|
      assoc[:main_train_uid] = invalid_uid
      assoc.should_not be_valid
    end
  end

  it "should validate the format of the associated train UID" do
    assoc = Association.new(@valid_data)
    ['A12345', 'Z99999'].each do |valid_uid|
      assoc[:assoc_train_uid] = valid_uid
      assoc.should be_valid
    end
    [nil, '', '123456', 'AAAAAA', 'A1234567', '______'].each do |invalid_uid|
      assoc[:assoc_train_uid] = invalid_uid
      assoc.should_not be_valid
    end
  end

  it "should require an association start date" do
    assoc = Association.new(@valid_data)
    assoc.association_start_date = nil
    assoc.should_not be_valid
  end

  it "should require an association end date" do
    assoc = Association.new(@valid_data)
    assoc.association_end_date = nil
    assoc.should_not be_valid
  end

  it "should not allow the association end date to occur before the association start date" do
    assoc = Association.new(@valid_data)
    assoc.association_start_date = Date.parse('2011-01-02')
    assoc.association_end_date = Date.parse('2011-01-01')
    assoc.should_not be_valid
  end

  it "should require the association be valid on at least one day" do
    assoc = Association.new(@valid_data)
    assoc[:valid_mo] = 0
    assoc[:valid_tu] = 0
    assoc[:valid_we] = 0
    assoc[:valid_th] = 0
    assoc[:valid_fr] = 0
    assoc[:valid_sa] = 0
    assoc[:valid_su] = 0
    assoc.should_not be_valid
  end

  it "should require a valid association type" do
    assoc = Association.new(@valid_data)
    ['P','O'].each do |valid_type|
      assoc[:assoc_type] = valid_type
      assoc.should be_valid
    end
    [nil, '', ' '].each do |invalid_type|
      assoc[:assoc_type] = invalid_type
      assoc.should_not be_valid
    end
  end

  it "should require a valid STP indicator" do
    assoc = Association.new(@valid_data)
    ['C','N','P','O'].each do |valid_stp_indicator|
      assoc[:stp_indicator] = valid_stp_indicator
      assoc.should be_valid
    end
    [nil, '', ' ', '0', 'Z', 'CC', 'NN', 'PP', 'OO'].each do |invalid_stp_indicator|
      assoc[:stp_indicator] = invalid_stp_indicator
      assoc.should_not be_valid
    end
  end

end
