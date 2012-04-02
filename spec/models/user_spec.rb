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

describe User do

  # Validity

  it "should not be valid when first created" do
    u = User.new
    u.should_not be_valid
  end

  it "should not be valid with only an email address" do
    u = User.new(:email => 'nobody@example.com')
    u.should_not be_valid
  end

  it "should not be valid with only a full name" do
    u = User.new(:full_name => 'Full Name')
    u.should_not be_valid
  end

  it "should not be valid with an email address, full name and a password of fewer than six characters" do
    u = User.new(:email => 'nobody@example.com', :full_name => 'Full Name', :password => 'FOO')
    u.should_not be_valid
  end

  it "should be valid with an email address, full name and a password of at least six characters" do
    u = User.new(:email => 'nobody@example.com', :full_name => 'Full Name', :password => 'FOOBARBAZ')
    u.should be_valid
  end

end
