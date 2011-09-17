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

class ApplicationController < ActionController::Base

  protect_from_forgery

  helper_method :advanced_mode?

  # Return true if advanced mode has been selected
  
  def advanced_mode?
    return session[:mode] == 'advanced'
  end


  # Toggle between normal and advanced mode
   
  def toggle_mode
      
    session[:mode] = (session[:mode] == 'advanced' ? 'normal' : 'advanced')
    redirect_to :back
              
  end

end
