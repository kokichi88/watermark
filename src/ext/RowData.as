package ext 
{
	import adobe.utils.CustomActions;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import gui.Controller;
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
		public var extraPic:Array = new Array();
		public var is700Mode:Boolean;
		public var picNeededLoad:int = 0;
		public function RowData(id:int) 
		{
			this.id = id;
		}
		
		public function isSetData():Boolean 
		{
			return picUrl != null && price != null && desc != null && picContent != null && picNeededLoad == extraPic.length;
		}
		
		public function getVnPrice(rate:int, extra:int): int {
			var ret:int = parseInt(price);
			ret = ret * rate + extra;
			return ret;
		}
		
		public function makeImage(default_quality:int):void
		{
			var i:int = 0;
			extraPic.sortOn("id", Array.NUMERIC);
			if (is700Mode) {
				for ( i = 0; i < extraPic.length; ++i) {
					var buffer:ByteArray = new ByteArray();
					var curBm:ExBitmap = extraPic[i]  as ExBitmap;
					curBm.child.bitmapData.encode(new Rectangle(0,0,curBm.child.width,curBm.child.height), new flash.display.JPEGEncoderOptions(default_quality), buffer); 
					Controller.createFile(buffer, id + "_" + curBm.id +  ".jpg");
				}
			}else {
				var curId:int = 0;
				var curBitmapdata:BitmapData = new BitmapData(700, 700);
				var countImage:int = 0;
				i = 0;
				while (i < extraPic.length) {
					var curBm:ExBitmap = extraPic[i];
					if (curId < 2) {
						curBitmapdata.copyPixels(curBm.child.bitmapData, new Rectangle(0, 0, curBm.child.width, curBm.child.height), new Point(0, curId * curBm.child.height));
						++curId;
					}else  {
						curBitmapdata.copyPixels(curBm.child.bitmapData, new Rectangle(0, 0, curBm.child.width, curBm.child.height), new Point(0, curId * (curBm.child.height-1)));
						curId = 0;
						var buff:ByteArray = new ByteArray();
						curBitmapdata.encode(new Rectangle(0, 0, curBitmapdata.width, curBitmapdata.height), new flash.display.JPEGEncoderOptions(default_quality), buff); 
						Controller.createFile(buff, id + "_" + countImage +  ".jpg");
						++countImage;
						curBitmapdata = new BitmapData(700, 700);
					}
					
					++i;
					
				}
			}
		}
		
		public function loadImage(url:String):void {
			var imageLoader:ExLoader = new ExLoader();
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompLoadImageFoxExport);
			imageLoader.load(new URLRequest(url));
			imageLoader.refUrl = picNeededLoad.toString();
			trace("refUrl", url, picNeededLoad);
			++picNeededLoad;
		}
		
		private function onCompLoadImageFoxExport(e:Event):void 
		{
			var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
			var curBm:Bitmap = loaderInfo.content as Bitmap;
			var exBitmap:ExBitmap = new ExBitmap();
			exBitmap.child = curBm;
			exBitmap.id = parseInt((loaderInfo.loader as ExLoader).refUrl);
			extraPic.push(exBitmap);
			
			trace("loaded", loaderInfo.url, exBitmap.id);
		}
		
		
		
	}

}