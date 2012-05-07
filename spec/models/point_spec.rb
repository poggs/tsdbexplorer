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

describe Point do

  it "should not be valid when first created" do
    p = Point.new
    p.should_not be_valid
  end

  it "should be valid with the minimum fields populated" do
    p = Point.create(:full_name => 'Foo', :stanox => '00000', :stanme => 'FOOBARBAZ', :tiploc => 'FOOBARB')
    p.should be_valid
  end

end
