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

class SearchController < ApplicationController

  caches_page :index, :advanced, :location, :identity


  # Search

  def index
    redirect_to root_url
  end


  # Advanced search

  def advanced

    @pills = [ [ "Search options", [ 'Location', 'Identity' ] ] ]

  end


  # Search by location and calling points

  def location

    @pills = [ [ "Search options", [ 'Location', 'Identity' ] ] ]

  end


  # Search by train identity or schedule UID

  def identity

    @pills = [ [ "Search options", [ 'Location', 'Identity' ] ] ]

  end

end
