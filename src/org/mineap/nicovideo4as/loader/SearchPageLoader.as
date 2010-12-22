package org.mineap.nicovideo4as.loader
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import org.mineap.nicovideo4as.model.SearchSortType;
	
	/**
	 * 
	 * @author shiraminekeisuke (MineAP)
	 * 
	 */
	public class SearchPageLoader extends URLLoader
	{
		
		public static const NICO_SEARCH_URL:String = "http://www.nicovideo.jp/search/";
		
		/**
		 * 
		 * @param urlRequest
		 * 
		 */
		public function SearchPageLoader(urlRequest:URLRequest = null)
		{
			if(urlRequest != null){
				this.load(urlRequest);
			}
		}
		
		/**
		 * 
		 * @param word
		 * @param sort
		 * @param order
		 * @param page
		 * 
		 */
		public function getSearchPage(word:String, 
									  sort:String = SearchSortType.COMMENT_TIME_STRING, 
									  order:String = SearchSortType.ORDER_D_STRING, 
									  page:int = 1):void{
			
			var request:URLRequest = new URLRequest(NICO_SEARCH_URL + encodeURIComponent(word));
			
			var variables:URLVariables = new URLVariables();
			variables.sort = sort;
			variables.order = order;
			variables.page = page;
			
			request.data = variables;
			
			this.load(request);
		}
	}
}