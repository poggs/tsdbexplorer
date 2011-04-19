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

describe "lib/tsdbexplorer.rb" do

  it "should validate a correctly formatted train identity" do
  
    TSDBExplorer.validate_train_identity("1A99").should be_true
    TSDBExplorer.validate_train_identity("2Z00").should be_true
    TSDBExplorer.validate_train_identity("3C01").should be_true
    TSDBExplorer.validate_train_identity("9O10").should be_true

  end

  it "should reject an incorrectly formed train identity" do

    TSDBExplorer.validate_train_identity(nil).should be_false
    TSDBExplorer.validate_train_identity("").should be_false
    TSDBExplorer.validate_train_identity("0000").should be_false
    TSDBExplorer.validate_train_identity("AAAA").should be_false
    TSDBExplorer.validate_train_identity("foobarbaz").should be_false

  end

  it "should validate a correctly formatted train UID" do

    TSDBExplorer.validate_train_uid("A00000").should be_true
    TSDBExplorer.validate_train_uid("C11111").should be_true
    TSDBExplorer.validate_train_uid("Z99999").should be_true

  end

  it "should reject an incorrectly formatted train UID" do

    TSDBExplorer.validate_train_uid(nil).should be_false
    TSDBExplorer.validate_train_uid("").should be_false
    TSDBExplorer.validate_train_uid("000000").should be_false
    TSDBExplorer.validate_train_uid("AAAAAA").should be_false
    TSDBExplorer.validate_train_uid("foobarbaz").should be_false

  end

  it "should convert a date in YYMMDD format to YYYY-MM-DD" do

    TSDBExplorer.ddmmyy_to_date("010160").should eql("1960-01-01")
    TSDBExplorer.ddmmyy_to_date("311299").should eql("1999-12-31")
    TSDBExplorer.ddmmyy_to_date("010100").should eql("2000-01-01")
    TSDBExplorer.ddmmyy_to_date("311259").should eql("2059-12-31")

  end

end
