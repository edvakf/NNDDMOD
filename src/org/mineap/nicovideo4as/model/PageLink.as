package org.mineap.nicovideo4as.model
{
	public class PageLink
	{
		
		private var _page:int = 0;
		private var _url:String = null;
		
		public function PageLink(page:int, url:String)
		{
			this._page = page;
			this._url = url;
		}
		
		public function get page():int{
			return this._page;
		}
		
		public function get url():String{
			return this._url;
		}
	}
}