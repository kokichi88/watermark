package
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import gui.View;


	public class Main extends Sprite
	{
		public static var instance:Main;
		public function Main():void
		{
			addEventListener(Event.ADDED_TO_STAGE, this.onInit);
			return;
		} // end function
		
	
		
		private function onInit(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, this.onInit);
			instance = this;
			var _view:View = new View();
			_view.init(this);
		} // end function
		
	
	
	}

}