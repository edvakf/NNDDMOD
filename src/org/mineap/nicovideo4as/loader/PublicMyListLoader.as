package org.mineap.nicovideo4as.loader
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;

	/**
	 * 公開マイリストの取得を行うクラスです。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class PublicMyListLoader extends URLLoader
	{
		
		public static const MYLIST_PAGE_URL:String = "http://www.nicovideo.jp/mylist/";
		
		/**
		 * 
		 * @param request
		 * 
		 */
		public function PublicMyListLoader(request:URLRequest = null)
		{
			if (request != null)
			{
				this.load(request);
			}
		}
		
		/**
		 * 指定されたマイリストIDのマイリスト情報を取得します。
		 * 指定するマイリストは公開マイリストである必要があります。
		 * 
		 * @param myListId 公開マイリストID
		 * @see org.mineap.nicovideo4as.analyzer.MyListAnalyzer
		 */
		public function getMyList(myListId:String):void{
			
			var url:String = MYLIST_PAGE_URL + myListId;
			
			var variables:URLVariables = new URLVariables();
			variables.rss = "2.0";
			
			var request:URLRequest = new URLRequest(url);
			request.data = variables;
			
			this.load(request);
			
		}
		
	}
}