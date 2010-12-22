package org.mineap.nicovideo4as.loader
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import org.mineap.nicovideo4as.model.NicoRankingUrl;
	
	/**
	 * ニコニコ動画のランキングRSSへのアクセスを担当するクラスです。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 */
	public class RankingLoader extends URLLoader
	{
		
		/**
		 * 
		 * @param request
		 * 
		 */
		public function RankingLoader(request:URLRequest = null)
		{
			if(request != null){
				this.load(request);
			}
		}
		
		/**
		 * 指定された期間、種別からURLを生成し、ランキングにアクセスします。
		 * 期間、種別は{@link NicoRankingUrl}を参照してください。
		 * 
		 * @param period NicoRankingUrlクラスの期間に関するプロパティを参照してください。
		 * @param target NicoRankingUrlクラスの種別に関するプロパティを参照してください。
		 * @param pageCount ページ番号 「?page=」の後に付ける数字を指定します。0および1の場合は1ページ目です。デフォルトでは1です。
		 * @param category カテゴリを表す文字列を指定します。例えば"all"や"music"です。デフォルトではall（総合）です。
		 * 
		 */
		public function getRanking(period:int, 
								   target:int, 
								   pageCount:int = 1, 
								   category:String = "all"):void{
			
			var request:URLRequest = new URLRequest(NicoRankingUrl.NICO_RANKING_URLS[period][target] + category);
			
			var variables:URLVariables = new URLVariables();
			variables.page = pageCount;
			variables.rss = "2.0";
			
			request.data = variables;
			
			this.load(request);
			
		}

	}
}