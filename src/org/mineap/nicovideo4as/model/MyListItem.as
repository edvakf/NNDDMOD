package org.mineap.nicovideo4as.model
{
	public class MyListItem
	{
		
		private var _title:String = null;
		
		private var _link:String = null;
		
		private var _guid:String = null;
		
		private var _isPermaLink:Boolean = false;
		
		private var _pubDate:Date = null;
		
		private var _description:String = null;
		
		public function MyListItem()
		{
		}

		public function toString():String
		{
			
			var str:String = "[";
			
			str += _title + ", " +
				_link + ", " +
					_guid + ", " +
						_isPermaLink + ", " +
							_pubDate + ", " +
								description + "]";
			
			return str;		
		}
		
		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;
		}

		public function get link():String
		{
			return _link;
		}

		public function set link(value:String):void
		{
			_link = value;
		}

		public function get guid():String
		{
			return _guid;
		}

		public function set guid(value:String):void
		{
			_guid = value;
		}

		public function get isPermaLink():Boolean
		{
			return _isPermaLink;
		}

		public function set isPermaLink(value:Boolean):void
		{
			_isPermaLink = value;
		}

		public function get pubDate():Date
		{
			return _pubDate;
		}

		public function set pubDate(value:Date):void
		{
			_pubDate = value;
		}

		public function get description():String
		{
			return _description;
		}

		public function set description(value:String):void
		{
			_description = value;
		}


	}
}