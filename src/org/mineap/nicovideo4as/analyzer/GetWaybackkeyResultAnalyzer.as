package org.mineap.nicovideo4as.analyzer
{
	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class GetWaybackkeyResultAnalyzer
	{
		
		private var _waybackkey:String = null;
		
		private var WAYBACKKEY_PATTERN:RegExp = new RegExp("waybackkey=(.*)");
		
		/**
		 * 
		 * 
		 */
		public function GetWaybackkeyResultAnalyzer()
		{
		}
		
		/**
		 * 
		 * @param result
		 * @return 
		 * 
		 */
		public function analyzer(result:String):Boolean{
			
			if(result == null){
				return false;
			}
			
			var array:Array = WAYBACKKEY_PATTERN.exec(result);
			
			if(array != null && array.length > 1){
				this._waybackkey = array[array.length-1];
			}
			
			return true;
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get waybackkey():String{
			return this._waybackkey;
		}
		
		
	}
}