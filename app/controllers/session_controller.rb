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

class SessionController < ApplicationController

  def show
    render :text => session.inspect
  end

  def reset
    reset_session
    if request.referer.blank?
      render :text => nil
    else
      redirect_to :back
    end
  end

  def set
    session[params[:key]] = params[:value] unless params[:key].nil?
    if request.referer.blank?
      render :text => nil
    else
      redirect_to :back
    end
  end

  def clear
    session.delete(params[:key]) unless params[:key].nil?
    if request.referer.blank?
      render :text => nil
    else
      redirect_to :back
    end
  end

  def toggle
    if session[params[:key]] && [true, false].include?(session[params[:key]])
      session[params[:key]] = !(session[params[:key]])
    else
      session[params[:key]] = true
    end
    if request.referer.blank?
      render :text => nil
    else
      redirect_to :back
    end
  end

  def toggle_on
    session[params[:key]] = true
    if request.referer.blank?
      render :text => advanced_mode?
    else
      redirect_to :back
    end
  end

  def toggle_off
    session[params[:key]] = false
    if request.referer.blank?
      render :text => advanced_mode?
    else
      redirect_to :back
    end
  end

end
