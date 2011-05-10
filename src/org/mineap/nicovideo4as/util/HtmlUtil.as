package org.mineap.nicovideo4as.util
{
	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class HtmlUtil
	{
		/**
		 * 
		 * 
		 */
		public function HtmlUtil()
		{
		}
		
		/**
		 * HTML特殊文字を使用していない動画のタイトルを返します。
		 * @param videoName
		 * @return 
		 * 
		 */
		public static function convertSpecialCharacterNotIncludedString(str:String):String{
			var temp:String = str;
			
			while(true){
				try{
					str = XML(str);
				}catch(error:Error){
					trace(error);
					return temp;
				}
				if(str == temp){
					break;
				}
				temp = str;
				
			}
			
			return temp;
		}
		
		/**
		 * 指定された文字列に含まれるエスケープされたユニコード文字( "\u([0-9a-f]{2,4})" )を元のユニコード文字に変換します。
		 * @param str
		 * @return 
		 * 
		 */
		public static function convertCharacterCodeToCharacter(str:String):String{
			
			var pattern:RegExp = new RegExp("(\\\\u([a-f0-9]{2,4}))", "ig");
			
			var result:String = str.replace(pattern, replaceFunc);
			
			function replaceFunc():String {
				if(arguments != null){
					if(arguments.length > 2){
						return String.fromCharCode(int("0x" + arguments[2]));
					}else{
						return arguments[0];
					}
				}else{
					return null;
				}
			}
			
			var count:int = 0;
			var temp:String = result.replace("\\/", "/");
			while(temp != result && count < 100)
			{
				result = temp;
				temp = result.replace("\\/", "/");
				count++;
			}
			
			count = 0;
			temp = result.replace("\\\"", "\"");
			while(temp != result && count < 100)
			{
				result = temp;
				temp = result.replace("\\\"", "\"");
				count++;
			}
				
			return result;
		}
		
	}
}