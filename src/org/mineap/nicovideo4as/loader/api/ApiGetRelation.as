package org.mineap.nicovideo4as.loader.api
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class ApiGetRelation extends URLLoader
	{
		
		public static const NICO_API_GET_RELATION:String = "http://flapi.nicovideo.jp/api/getrelation";
		
		/**
		 * 
		 * @param request
		 * 
		 */
		public function ApiGetRelation(request:URLRequest=null)
		{
			super(request);
		}
		
		/**
		 * 指定された動画IDに対するオススメ動画情報を取得します。
		 * @param videoId 動画ID
		 * @param page 取得するページ
		 * @param sort ソートの方法。p(オススメ),r(コメント),v(再生数),f(投稿日時)を指定。
		 * @param order 降順(d)か昇順(a)かを指定する
		 * 
		 */
		public function getRelation(videoId:String, 
									page:int = 1, 
									sort:String = "p", 
									order:String = "d"):void{
			
			var request:URLRequest = new URLRequest(NICO_API_GET_RELATION);
			
			var variables:URLVariables = new URLVariables();
			variables.page = String(page);
			variables.sort = sort;
			variables.order = order;
			variables.video = videoId;
			
			request.data = variables;
			
			this.load(request);
		}
		
		
	}
}