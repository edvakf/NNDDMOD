package org.mineap.nicovideo4as.analyzer
{
	import org.mineap.nicovideo4as.model.RelationResultItem;

	public class GetRelationResultAnalyzer
	{
		
		/**
		 * 応答のステータス
		 */
		public var status:String = null;
		
		/**
		 * 検索されたオススメ動画の総数
		 */
		public var total_count:int = 0;
		
		/**
		 * ページ分けした結果、できたページの数
		 */
		public var page_count:int = 0;
		
		/**
		 * レスポンスに含まれる動画データの個数
		 */
		public var data_count:int = 0;
		
		/**
		 * レスポンスに含まれる動画情報の一覧
		 */
		public var videos:Vector.<RelationResultItem> = new Vector.<RelationResultItem>();
		
		public function GetRelationResultAnalyzer()
		{
		}
		
		/**
		 * 
		 * @param result
		 * @return 
		 * 
		 */
		public function analyze(result:Object):Boolean{
			try{
				
				var related_video:XML = new XML(result);
				
				this.status = related_video.@status;
				
				if(status == "ok"){
					
					this.total_count = related_video.total_count;
					
					this.page_count = related_video.page_count;
					
					this.data_count = related_video.data_count;
					
					for each(var video:XML in related_video.elements("video")){
						
						var url:String = video.url;
						var thumbnail:String = video.thumbnail;
						var title:String = decodeURIComponent(video.title);
						var view:int = video.view;
						var comment:int = video.comment;
						var mylist:int = video.mylist;
						var length:int = video.length;
						var time:Number = video.time;	//TODO 投稿日を表していると思われるこの時間がどうやったら正しい日時に変換できるか不明
						
						var item:RelationResultItem = new RelationResultItem(url, thumbnail, title, view, comment, mylist, length, time);
						
						videos.push(item);
						
					}
					
					return true;
				}else{
					return false;
				}
				
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			return false;
		}
		
	}
}