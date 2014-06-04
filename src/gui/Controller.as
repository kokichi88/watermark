package gui
{
	import by.blooddy.crypto.image.PNGEncoder;
	import com.as3xls.xls.ExcelFile;
	import com.as3xls.xls.Sheet;
	import ext.ExLoader;
	import ext.ExUrlLoader;
	import ext.RowData;
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
	import flash.html.HTMLLoader;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import org.aswing.event.AWEvent;
	import org.aswing.JButton;
	import org.aswing.util.ArrayList;
	import org.aswing.util.HashMap;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Controller
	{
		public static const CHAR_SET:String = "gb2312";
		public static const BT_LOAD_WATERMARK:String = "Load watermark";
		public static const BT_LOAD_IMAGE:String = "Load image";
		public static const BT_SAVE_PATH:String = "Save path";
		public static const BT_OFFSET:String = "Set offset";
		public static const BT_COMPRESS:String = "Set compress quality";
		public static const BT_HMTL_LOAD:String = "load html";
		private static var _loadFile:FileReference;
		private static var _loadFiles:FileReferenceList;
		private static var watermark:Bitmap;
		private static var savedPath:String = File.cacheDirectory.nativePath;
		private static var offset:Point = new Point(0, 0);
		private static var default_quality:int = 80;
		private static var map:HashMap = new HashMap();
		private static var dic:HashMap = new HashMap();
		private static var global_counter:int = 0;
		public function Controller()
		{
			
		}
		
		public static function init():void {
			dic.put("肩宽", "Vai");
			dic.put("胸围", "Nguc");
			dic.put("袖长", "Dai tay");
			dic.put("袖口", "Tay áo");
			dic.put("下摆围", "Rong nhat");
			dic.put("衣长", "Dai ao");
			dic.put("腰围", "Eo");
			dic.put("臀围", "Mong");
			dic.put("前档", "Dai dung truoc");
			dic.put("后档", "Dai dung sau");
			dic.put("裤口", "Rong ong");
			dic.put("裤长", "Dai quan");
			dic.put("裤口围", "Đui");
			dic.put("小腿围", "Rong bap chan");
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
				case BT_HMTL_LOAD:
					htmlLoad();
					break;
					
			}
		
		}
		
		static private function htmlLoad():void 
		{
			++global_counter;
			if (dic.size() == 0) {
				init();
			}
			map.clear();
			
			//var url:String = "http://item.taobao.com/item.htm?spm=a1z10.1.w5003-6411951231.70.xHugg7&id=39338349357&scene=taobao_shop";
			var urls:Array = View.paramOne.getText().split(",");
			if (urls.length > 0) {
				for ( var i:int = 0; i < urls.length; ++i) {
					var loader:ExUrlLoader = new ExUrlLoader();
					loader.addEventListener(Event.COMPLETE, completeHandler);
					var url:String = urls[i] as String;
					var request:URLRequest = new URLRequest(url);
					loader.load(request);
					var row:RowData = new RowData(i);
					map.put(url, row);
				}
				
			}
		
		}
		
		static private function completeHandler(e:Event):void 
		{
			var loader:ExUrlLoader = ExUrlLoader(e.currentTarget);
			if (map.containsKey(loader.url)) {
				var row:RowData = map.getValue(loader.url) as RowData;
				var sPrice:String = "price:";
				var sPic:String = "pic:"
				var rawString:String = loader.data as String;
				row.price =  parsePrice(rawString,sPrice);
				row.picUrl = parsePic(rawString,sPic);
				var sG_Config:String =  "g_config.dynamicScript(\"";
				var url:String = parseBody(rawString, sG_Config)
				//trace(sG_Config + ":  " + url);
				var loaderBody:ExUrlLoader = new ExUrlLoader();
				loaderBody.dataFormat = URLLoaderDataFormat.BINARY;
				var request:URLRequest = new URLRequest(url);
				loaderBody.load(request);
				loaderBody.url = loader.url;
				loaderBody.addEventListener(Event.COMPLETE, completeUrlBody);
				
				// load image
				var imageLoader:ExLoader = new ExLoader();
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompLoadImageFoxExport);
				imageLoader.load(new URLRequest(row.picUrl));
				imageLoader.refUrl = loader.url;
			}
			
		}
		
		static private function onCompLoadImageFoxExport(e:Event):void 
		{
			var loaderInfo:LoaderInfo = LoaderInfo(e.currentTarget);
			var loader:ExLoader = loaderInfo.loader as ExLoader;
			if (map.containsKey(loader.refUrl)) {
				var row:RowData = map.getValue(loader.refUrl) as RowData;
				var buffer:ByteArray = new ByteArray();
				var curBm:Bitmap = loaderInfo.content as Bitmap;
				curBm.bitmapData.encode(new Rectangle(0,0,curBm.width,curBm.height), new flash.display.JPEGEncoderOptions(default_quality), buffer); 
				row.picContent = buffer;
				createFile(buffer, row.id + ".jpg");
				if (checkDownloadComp()) {
					createExcel();
				}
			}
		}
		
		static private function completeUrlBody(e:Event):void 
		{
			var loader:ExUrlLoader = ExUrlLoader(e.currentTarget);
			if (map.containsKey(loader.url)) {
				var row:RowData = map.getValue(loader.url) as RowData;
				var rawString:String;
				if (loader.dataFormat == URLLoaderDataFormat.TEXT) {
					rawString = String(loader.data);
				}else {
					var buffer:ByteArray = loader.data as ByteArray;
					rawString = buffer.readMultiByte(buffer.bytesAvailable, CHAR_SET);
					
				}
				// translate chinese -> vietnamese
				var keys:Array = dic.keys();
				var minIndx:int = int.MAX_VALUE;
				for (var i:int = 0; i < keys.length; ++i) {
					var chineseW:String = keys[i];
					var curIndex:int = rawString.indexOf(chineseW);
					if (minIndx > curIndex && curIndex != -1) {
						minIndx = curIndex;
					}
				}
				var temp:String = rawString.substr(minIndx);
				var lastIdx:int = temp.indexOf("<");
				temp = temp.substr(0, lastIdx);
				for (var i:int = 0; i < keys.length; ++i) {
					var chineseW:String = keys[i];
					var vnW:String = dic.getValue(chineseW);
					temp = temp.replace(chineseW, vnW);
				}
				row.desc = temp;
				if (checkDownloadComp()) {
					createExcel();
				}
				
			}
		}
		
	
		
		private static function parseBody(rawString:String, sConfig:String):String {
			var index1:int = rawString.lastIndexOf(sConfig);
			var ret:String = "not found";
			if (index1 > -1) {
				var temp1:String = rawString.substr(index1);
				var index2:int = temp1.indexOf("(\"") + 2;
				var index3:int = temp1.indexOf("\")");
				ret = temp1.substr(index2,index3-index2);
			}
			return ret;
		}
	
		private static function parsePrice(rawString:String, sPrice:String):String {
			var indexPrice:int = rawString.indexOf(sPrice) ;
			var price:String = "not found";
			if (indexPrice > -1) {
				var temp1:String = rawString.substr(indexPrice);
				var indexColon:int = temp1.indexOf(",");
				price = (temp1.substring(0, indexColon).split(":")[1]);
				
			}
			return price;
		
		}
		
		private static function parsePic(rawString:String, sPic:String):String {
			var indexPrice:int = rawString.indexOf(sPic) ;
			var pic:String = "not found";
			if (indexPrice > -1) {
				var temp1:String = rawString.substr(indexPrice);
				var indexColon:int = temp1.indexOf(",");
				var index2Colon:int = temp1.indexOf("\"") + 1;
				pic = temp1.substr(index2Colon, indexColon - index2Colon);
				var lastIndexColon:int = pic.lastIndexOf("_");
				pic = pic.substr(0, lastIndexColon);
			}
			return pic;
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
			newBitmap.encode(new Rectangle(0, 0, newBitmap.width, newBitmap.height), new flash.display.JPEGEncoderOptions(default_quality), buffer); 
			createFile(buffer, loader.loader.name);		
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
		
		
		static private function createExcel():void 
		{
			var sheet:Sheet = new Sheet();
			sheet.name = global_counter.toString();
			var values:Array = map.values();
			sheet.resize(values.length+1, 4);
			values.sortOn("id", Array.NUMERIC); 
			sheet.setCell(0, 0, "id");
			sheet.setCell(0, 1, "price");
			sheet.setCell(0, 2, "desc");
			sheet.setCell(0, 3, "url");
			for (var i:int = 0; i < values.length; ++i) {
				var data:RowData = values[i];
				sheet.setCell(i+1, 0, data.id);
				sheet.setCell(i+1, 1, data.price);
				sheet.setCell(i+1, 2, data.desc);
				sheet.setCell(i+1, 3, data.picUrl);
			}
			var xls:ExcelFile = new ExcelFile();
			xls.sheets.addItem(sheet);
			var buffer:ByteArray = xls.saveToByteArray("windows-1258");
			createFile(buffer, global_counter + ".xls");
		}
		
		public static function createFile(buffer:ByteArray, fName:String):void {
			try{
				var file:File = new File();
				file = file.resolvePath(savedPath + File.separator + fName);
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
		
		public static function createDirectory(fName:String) :File {
			try{
				var file:File = new File();
				file = file.resolvePath(savedPath + File.separator + fName);
				file.createDirectory();
				View.txMsg.setText("created directory " + file.nativePath);
				return file;
			}catch (e:Error) 
			{
				View.txMsg.setText("created error " + e.message);
			}
			return null;
		}
		
		private static function checkDownloadComp():Boolean {
			var values:Array = map.values();
			for (var i:int = 0; i < values.length; ++i) {
				var checkRow:RowData = values[i] as RowData;
				if (!checkRow.isSetData()) {
					return false;
				}
			}
			return true;
				
		}
	}

}