package ext 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author kokichi88
	 */
	public class RowData 
	{
		public var id:int = -1;
		public var picUrl:String = null;
		public var price:String = null;
		public var desc:String = null;
		public var picContent:ByteArray = null;
		public function RowData(id:int) 
		{
			this.id = id;
		}
		
		public function isSetData():Boolean 
		{
			return picUrl != null && price != null && desc != null && picContent != null;
		}
		
	}

}