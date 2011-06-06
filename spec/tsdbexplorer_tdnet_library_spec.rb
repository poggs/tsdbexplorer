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

describe "lib/tsdbexplorer/tdnet.rb" do

  # Network Rail TD.net message parsing

  it "should parse a raw Train Describer CA message" do
    expected_data = { :message_type => 'CA', :td_identity => 'aa', :from_berth => 'bbbb', :to_berth => 'cccc', :train_description => 'dddd', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_message('<CA_MSG>aaCAbbbbccccddddeeeeee</CA_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer CB message" do
    expected_data = { :message_type => 'CB', :td_identity => 'aa', :from_berth => 'bbbb', :train_description => 'dddd', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_message('<CB_MSG>aaCBbbbbddddeeeeee</CB_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer CC message" do
    expected_data = { :message_type => 'CC', :td_identity => 'aa', :to_berth => 'cccc', :train_description => 'dddd', :timestamp => 'eeeeee'}
    TSDBExplorer::TDnet::parse_message('<CC_MSG>aaCCccccddddeeeeee</CC_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer CT message" do
    expected_data = { :message_type => 'CT', :td_identity => 'aa', :timestamp_four => 'hhmm', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_message('<CT_MSG>aaCThhmmeeeeee</CT_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer SF message" do
    expected_data = { :message_type => 'SF', :td_identity => 'aa', :address => 'ff', :data => 'gg', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_message('<SF_MSG>aaSFffggeeeeee</SF_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer SG message" do
    expected_data = { :message_type => 'SG', :td_identity => 'aa', :address => 'ff', :data => 'gggggggg', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_message('<SG_MSG>aaSGffggggggggeeeeee</SG_MSG>').should eql(expected_data)
  end

  it "should parse a raw Train Describer SH message" do
    expected_data = { :message_type => 'SH', :td_identity => 'aa', :address => 'ff', :data => 'gggggggg', :timestamp => 'eeeeee' }
    TSDBExplorer::TDnet::parse_message('<SH_MSG>aaSHffggggggggeeeeee</SH_MSG>').should eql(expected_data)
  end

  it "should raise an error if passed an invalid Train Describer message type" do
    lambda { TSDBExplorer::TDnet::parse_message('<ZZ_MSG>foobarbazqux</ZZ_MSG>') }.should raise_error
  end

  it "should parse a compact Train Describer CA message" do
    expected_data = { :message_type => 'CA', :td_identity => 'SU', :timestamp => '07:59:30Z', :from_berth => 'FROM', :to_berth => 'TOBH', :train_description => 'TDSC' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="CA" TDIdentity="SU" timestamp="07:59:30Z" fromBerthAddress="FROM" toBerthAddress="TOBH" trainIdentity="TDSC" />').should eql(expected_data)
  end

  it "should parse a compact Train Describer CB message" do
    expected_data = { :message_type => 'CB', :td_identity => 'SU', :timestamp => '07:59:30Z', :from_berth => 'FROM', :train_description => 'TDSC' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="CB" TDIdentity="SU" timestamp="07:59:30Z" fromBerthAddress="FROM" trainIdentity="TDSC" />').should eql(expected_data)
  end

  it "should parse a compact Train Describer CC message" do
    expected_data = { :message_type => 'CC', :td_identity => 'SU', :timestamp => '07:59:30Z', :to_berth => 'TOBH', :train_description => 'TDSC' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="CC" TDIdentity="SU" timestamp="07:59:30Z" toBerthAddress="TOBH" trainIdentity="TDSC" />').should eql(expected_data)
  end

  it "should parse a compact Train Describer CT message" do
    expected_data = { :message_type => 'CT', :td_identity => 'SU', :timestamp => '07:59:30Z', :timestamp_four => '0759' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="CT" TDIdentity="SU" timestamp="07:59:30Z" TDReportTime="0759" />').should eql(expected_data)
  end

  it "should parse a compact Train Describer SF message" do
    expected_data = { :message_type => 'SF', :td_identity => 'SU', :timestamp => '07:59:30Z', :address => '0C', :data => '66' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="SF" TDIdentity="SU" timestamp="07:59:30Z" equipmentStatusAddress="0C" equipmentStatus="66" />').should eql(expected_data)
  end

  it "should parse a compact Train Describer SG message" do
    expected_data = { :message_type => 'SG', :td_identity => 'SU', :timestamp => '07:59:30Z', :address => '0C', :data => '66666666' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="SG" TDIdentity="SU" timestamp="07:59:30Z" equipmentBaseScanAddress="0C" equipmentBaseScan="66666666" />').should eql(expected_data)
  end

  it "should parse a compact Train Describer SH message" do
    expected_data = { :message_type => 'SH', :td_identity => 'SU', :timestamp => '07:59:30Z', :address => '0C', :data => '66666666' }
    TSDBExplorer::TDnet::parse_compact_message('<?xml version="1.0" ?><TDCompact TDMessageType="SH" TDIdentity="SU" timestamp="07:59:30Z" equipmentBaseScanAddress="0C" equipmentBaseScan="66666666" />').should eql(expected_data)
  end

end
