package ext 
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author kokichi88
	 */
	public class ExUrlLoader extends URLLoader 
	{
		public var url:String;
		public function ExUrlLoader(request:URLRequest=null) 
		{
			super(request);
			if(request != null)
				url = request.url;
		}
		
		override public function load(request:URLRequest):void 
		{
			super.load(request);
			url = request.url;
		}
		
	}

}