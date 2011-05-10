package org.mineap.nicovideo4as.analyzer
{
	import flash.html.HTMLLoader;
	
	import org.mineap.nicovideo4as.model.PageLink;
	import org.mineap.nicovideo4as.model.SearchResultItem;
	import org.mineap.nicovideo4as.util.VideoTypeUtil;
	import org.mineap.nicovideo4as.util.HtmlUtil;
	
	public class SearchResultAnalyzer
	{
		
		public var videoIds:Vector.<String> = new Vector.<String>();
		
		public var pageLinkList:Vector.<PageLink> = new Vector.<PageLink>();
		
		/**
		 * 
		 */
		private var _pattern_videoId:RegExp = new RegExp("(watch/" + VideoTypeUtil.VIDEO_ID_SEARCH_PATTERN_STRING + ")", "ig");
		
		/**
		 * 
		 */
		private var _pattern_pageLink:RegExp = new RegExp("<a href=\"(http://www.nicovideo.jp/[^/]+/[^\"]*)\">(\\d*)</a>[^</a>]*","ig");
		
		/**
		 * 
		 */
		private var _pattern_nowPage:RegExp = new RegExp("<span class=\"in\">(\\d+)</span>","ig");
		
		/**
		 * 
		 * @param pattern_pageLink_string
		 * @param pattern_nowPage_string
		 * 
		 */
		public function SearchResultAnalyzer(pattern_videoId_string:String = null,
											 pattern_pageLink_string:String = null, 
											 pattern_nowPage_string:String = null)
		{
			if(pattern_videoId_string != null){
				this._pattern_videoId = new RegExp(pattern_videoId_string, "ig");
			}
			if(pattern_pageLink_string != null){
				this._pattern_pageLink = new RegExp(pattern_pageLink_string, "ig");
			}
			if(pattern_nowPage_string != null){
				this._pattern_nowPage = new RegExp(pattern_nowPage_string, "ig");
			}
		}
		
		/**
		 * 
		 * @param data
		 * @return 
		 * 
		 */
		public function analyzer(data:String):Boolean{
			
			var videoIdList:Array = data.match(this._pattern_videoId);
			
			var nowPage:Array = this._pattern_nowPage.exec(data);
			if(nowPage != null){
				pageLinkList.push(new PageLink(nowPage[2], nowPage[1]));
			}
			
			var pageLinkAnalyzeResult:Array = this._pattern_pageLink.exec(data);
			
			while(pageLinkAnalyzeResult != null){
				
				var index:int = String(pageLinkAnalyzeResult[1]).lastIndexOf("?");
				
				if(index != -1){
					
					var url:String = String(pageLinkAnalyzeResult[1]).substring(0, index);
					var suffix:String = String(pageLinkAnalyzeResult[1]).substring(index);
					
					//HTML特殊文字を変換(&amp;→&)
					suffix = HtmlUtil.convertSpecialCharacterNotIncludedString(suffix);
					url = url + suffix;
					
				}else{
					url = pageLinkAnalyzeResult[1];
				}
				
				pageLinkList.push(new PageLink(pageLinkAnalyzeResult[2], url));
				pageLinkAnalyzeResult = this._pattern_pageLink.exec(data);
			}
			
			for each(var pageLink:PageLink in pageLinkList){
				trace(pageLink.page + ":" + pageLink.url);
			}
			
			var changeNicoGUI:Boolean = false;
			
			for(var i:int = 0; i<videoIdList.length; i++)
			{
				try{
					
					this.videoIds.push(videoIdList[i]);
					
				}catch(error:Error){
					trace("解析に失敗:" + i + "番目の解析" + "\n" + error.getStackTrace());
					changeNicoGUI = true;
				}
			}
			
			if(changeNicoGUI){
				return false;
			}
			
			return true;
		}
		
	}
}