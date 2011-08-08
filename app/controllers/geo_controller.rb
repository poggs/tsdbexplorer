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

class GeoController < ApplicationController

  def index

    redirect_to :action => 'setup' if GeoElr.count == 0

    if params[:elr_code]
      @elr = GeoElr.find_by_elr_code(params[:elr_code])
      @points = GeoPoint.all(:conditions => { :elr_code => params[:elr_code] }, :order => [ :miles, :chains ])
    end

  end


  # Display a setup page if no ELRs exist

  def setup

    redirect_to :action => 'index' if GeoElr.count > 0

  end


  # Search the ELR records for a value

  def search

    if params[:term].length == 4
      conditions = [ 'elr_code = ?', params[:term] ]
    else
      conditions = [ 'elr_code LIKE ? OR line_name LIKE ?', '%' + params[:term].upcase + '%', '%' + params[:term].upcase + '%' ]
    end

    matches = GeoElr.find(:all, :conditions => conditions, :limit => 25).collect { |m| { :id => m.elr_code, :label => m.line_name + " (" + m.elr_code + ")", :value => m.elr_code } }

    render :json => matches

  end

end
