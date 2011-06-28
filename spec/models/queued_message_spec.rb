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

describe QueuedMessage do

  it "should not be valid when first created" do
    QueuedMessage.new.should_not be_valid
  end

  it "should require a valid queue name" do

    model = QueuedMessage.new({ :message => 'FOO' })

    [ 'TD_DATA', 'TR_DATA', 'VSTP_DATA', 'TSR_DATA' ].each do |valid_data|
      model.queue_name = valid_data
      model.should be_valid
    end 

  end

  it "should not be valid with an invalid queue name" do

    model = QueuedMessage.new({ :message => 'FOO' })

    [ nil, '', ' ', 'FOOBARBAZQUX' ].each do |invalid_data|
      model.queue_name = invalid_data
      model.should_not be_valid
    end 

  end

end
