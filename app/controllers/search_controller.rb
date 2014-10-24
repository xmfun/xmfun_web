require 'util/search_manager'

class SearchController < ApplicationController
  def search
    search_result = SearchManager.search(params[:query])

    render :json => search_result

    #respond_to do |format|
      #format.json{ render :json => search_result}
    #end
  end
end
