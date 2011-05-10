package org.mineap.nicovideo4as.analyzer
{
	import org.mineap.nicovideo4as.model.MyListItem;

	public class MyListAnalyzer
	{
		public function MyListAnalyzer()
		{
		}
		
		/**
		 * 
		 * @param xml
		 * 
		 */
		public function analyzer(xml:XML):Vector.<MyListItem>
		{
			
			var vector:Vector.<MyListItem> = new Vector.<MyListItem>();
			
			if (xml == null)
			{
				return vector;
			}
			
			if (xml.channel == null)
			{
				return vector;
			}
			
			var items:XMLList = (xml.channel as XMLList).child("item");
			
			for each(var xml:XML in items)
			{
				var myListItem:MyListItem = new MyListItem();
				
				myListItem.title = xml.title;
				myListItem.link = xml.link;
				myListItem.guid = xml.guid;
				if(xml.guid.@isPermaLink == "true"){
					myListItem.isPermaLink = true;
				}
				myListItem.pubDate = getDate(xml.pubDate);
				myListItem.description = xml.description;
				
				vector.push(myListItem);
			}
			
			return vector;
		}
		
		private function getDate(string:String):Date
		{
		
			//Thu, 13 Sep 2007 15:59:30 +0900
			var pattern:RegExp = new RegExp("(\\S+), (\\d\\d) (\\S+) (\\d\\d\\d\\d) (\\d\\d):(\\d\\d):(\\d\\d)");
			
			var newDate:Date = new Date();
			
			try{
				
				var array:Array = string.match(pattern);
				
				var dayOfTheWeek:String = array[1];
				var year:String = array[4];
				var month:String = array[3];
				var date:String = array[2];
				var h:String = array[5];
				var m:String = array[6];
				var s:String = array[7];
				
				//曜日 月 日 年 時:分:秒
				newDate = new Date(String(dayOfTheWeek + " " + month + " " + date + " " + year + " " + h + ":" + m + ":" + s));
				
			}catch(e:Error){
				trace(e + "\n" + e.getStackTrace());
			}
			
			return newDate;
			
			
		}
		
		
	}
}