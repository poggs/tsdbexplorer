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
#  $Id: tiploc_spec.rb 109 2011-04-19 21:03:03Z pwh $
#

require 'spec_helper'

describe Tiploc do

  it "should not be valid when first created" do
    tiploc = Tiploc.new
    tiploc.should_not be_valid
  end

  it "should be valid with valid attributes" do
    tiploc = Tiploc.new(:tiploc_code => "EUSTON", :nalco => "144400", :tps_description => "LONDON EUSTON", :crs_code => "EUS", :description => "LONDON EUSTON")
    tiploc.should be_valid
  end
  
  it "should not be valid without a TIPLOC code" do
    tiploc = Tiploc.new(:nalco => "144400", :tps_description => "LONDON EUSTON", :crs_code => "EUS", :description => "LONDON EUSTON")
    tiploc.should_not be_valid
  end

  it "should not be valid without a NLC" do
    tiploc = Tiploc.new(:tiploc_code => "EUSTON", :tps_description => "LONDON EUSTON", :crs_code => "EUS", :description => "LONDON EUSTON")
    tiploc.should_not be_valid
  end

  it "should enforce an all-numeric NLC" do
    tiploc = Tiploc.new(:tiploc_code => "EUSTON", :nalco => "1444ZZ", :tps_description => "LONDON EUSTON", :crs_code => "EUS", :description => "LONDON EUSTON")
    tiploc.should_not be_valid
  end

  it "should not be valid without a TPS Description" do
    tiploc = Tiploc.new(:tiploc_code => "EUSTON", :nalco => "144400", :crs_code => "EUS", :description => "LONDON EUSTON")
    tiploc.should_not be_valid
  end

  it "should be valid with a blank CRS code" do
    tiploc = Tiploc.new(:tiploc_code => "EUSTON", :nalco => "144400", :crs_code => "   ", :tps_description => "LONDON EUSTON", :description => "LONDON EUSTON")
    tiploc.should be_valid
  end

  it "should be valid with a nil CRS code" do
    tiploc = Tiploc.new(:tiploc_code => "EUSTON", :nalco => "144400", :crs_code => nil, :tps_description => "LONDON EUSTON", :description => "LONDON EUSTON")
    tiploc.should be_valid
  end

  it "should enforce a three-letter CRS code" do
    tiploc = Tiploc.new(:tiploc_code => "EUSTON", :nalco => "144400", :tps_description => "LONDON EUSTON", :crs_code => "Z", :description => "LONDON EUSTON")
    tiploc.should_not be_valid
  end

  it "should enforce an all-alphabetic CRS code" do
    tiploc = Tiploc.new(:tiploc_code => "EUSTON", :nalco => "144400", :tps_description => "LONDON EUSTON", :crs_code => "000", :description => "LONDON EUSTON")
    tiploc.should_not be_valid
  end

  it "should be valid with a blank description" do
    tiploc = Tiploc.new(:tiploc_code => "EUSTON", :nalco => "144400", :tps_description => "LONDON EUSTON", :crs_code => "EUS", :description => "")
    tiploc.should be_valid
  end

  it "should be valid with a nil description" do
    tiploc = Tiploc.new(:tiploc_code => "EUSTON", :nalco => "144400", :tps_description => "LONDON EUSTON", :crs_code => "EUS", :description => nil)
    tiploc.should be_valid
  end

end
