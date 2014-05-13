package gui
{
	import by.blooddy.crypto.image.PNGEncoder;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.utils.ByteArray;
	import org.aswing.event.AWEvent;
	import org.aswing.JButton;
	import org.aswing.util.ArrayList;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Controller
	{
		
		public static const BT_LOAD_WATERMARK:String = "Load watermark";
		public static const BT_LOAD_IMAGE:String = "Load image";
		public static const BT_SAVE_PATH:String = "Save path";
		public static const BT_OFFSET:String = "Set offset";
		public static const BT_COMPRESS:String = "Set compress quality";
		private static var _loadFile:FileReference;
		private static var _loadFiles:FileReferenceList;
		private static var watermark:Bitmap;
		private static var savedPath:String = File.cacheDirectory.nativePath;
		private static var offset:Point = new Point(0, 0);
		private static var default_quality:int = 80;
		public function Controller()
		{
		
		}
		
		static public function onButtonPress(e:AWEvent):void
		{
			var bt:JButton = (JButton)(e.currentTarget);
			var cmdId:String = bt.getName();
			switch (cmdId)
			{
				case BT_LOAD_WATERMARK:
					loadWaterMark();
					break;
				case BT_LOAD_IMAGE:
					loadImages();
					break;
				case BT_SAVE_PATH:
					savePath();
					break;
				case BT_OFFSET:
					setOffset();
					break;
				case BT_COMPRESS:
					setCompressQuality();
					break;
					
			}
		
		}
		
		static private function setCompressQuality():void 
		{
			default_quality = int(View.paramOne.getText());
		}
		
		static private function setOffset():void 
		{
			offset.x = int( View.paramOne.getText());
			offset.y = int( View.paramTwo.getText());
		}
		
		static private function savePath():void 
		{
			savedPath = View.paramOne.getText();

		}
		
		static private function loadImages():void 
		{
			_loadFiles = new FileReferenceList();
			var fileFilter:FileFilter = new FileFilter("load images: (*.jpg)", "*.jpg");
			_loadFiles.browse([fileFilter]);
			_loadFiles.addEventListener(Event.SELECT, onLoadImages);
		}
		
		static private function onLoadImages(e:Event):void 
		{
			if (watermark != null) {
				var fileRef:Array = e.currentTarget.fileList as Array;
				var file:FileReference;
				for(var i:int = 0; i < fileRef.length; i++) {
					file = fileRef[i];
					file.addEventListener(Event.COMPLETE,onLoadImage);
					file.load();
				}
			}else {
				View.txMsg.setText("not have watermark");
			}
			
		}
		
		static private function onLoadImage(e:Event):void 
		{
			var file:FileReference = e.currentTarget as FileReference;
			var buffer:ByteArray = new ByteArray();
			file.data.readBytes(buffer);
			var loader:Loader  = new Loader();
			loader.name = file.name;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoadImage);
			loader.loadBytes(buffer);
		}
		
		static private function handleLoadImage(e:Event):void 
		{
			var loader:LoaderInfo = e.currentTarget as LoaderInfo;
			var curBm:Bitmap = loader.content as Bitmap;
			var newBitmap:BitmapData = new BitmapData(curBm.width, curBm.height);
			newBitmap.copyPixels(curBm.bitmapData, new Rectangle(0, 0, newBitmap.width, newBitmap.height), new Point(0, 0));
			newBitmap.copyPixels(watermark.bitmapData, new Rectangle(0, 0, watermark.width, watermark.height), new Point(offset.x, newBitmap.height - watermark.height - offset.y),null,null,true);
			var buffer:ByteArray = new ByteArray();
			newBitmap.encode(new Rectangle(0,0,newBitmap.width,newBitmap.height), new flash.display.JPEGEncoderOptions(default_quality), buffer); 
			try{
				var file:File = new File();
				file = file.resolvePath(savedPath + File.separator + loader.loader.name);
				var fileStream:FileStream = new FileStream();
				fileStream.openAsync(file, FileMode.WRITE);
				fileStream.writeBytes(buffer);
				fileStream.close();
				View.txMsg.setText("saved file " + file.nativePath);
			}catch (e:Error) 
			{
				View.txMsg.setText("save error " + e.message);
			}
		
		}
		
	
		
		static private function loadWaterMark():void
		{
			_loadFile = new FileReference();
		
			_loadFile.addEventListener(Event.SELECT, selectHandler);
			var fileFilter:FileFilter = new FileFilter("load watermark: (*.png)", "*.png");
			_loadFile.browse([fileFilter]);
		}
		
		static private function selectHandler(e:Event):void
		{
			_loadFile.removeEventListener(Event.SELECT, selectHandler);
			
			_loadFile.addEventListener(Event.COMPLETE, loadCompleteHandler);
			_loadFile.load();
		}
		
		static private function loadCompleteHandler(e:Event):void
		{
			_loadFile.removeEventListener(Event.SELECT, loadCompleteHandler);
			var buffer:ByteArray = new ByteArray();
			_loadFile.data.readBytes(buffer);
			var loader:Loader  = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoad)
			loader.loadBytes(buffer);
		}
		
		static private function handleLoad(e:Event):void 
		{
			var loader:LoaderInfo = e.currentTarget as LoaderInfo;
			watermark = loader.content as Bitmap;
			View.txMsg.setText("Load watermark successfully");
		}
		
		
		
		
		
	}

}