package
{
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import utils.NMPostroll;
	import utils.VIADController;
	
	public class NMVideoFullscreen extends Sprite
	{
		
		public static var playerObjects:NMPlayerObjects;
		public static var videoConstructor:NMVideoConstructor;
		public static var viad:VIADController;
		public static var postroll:NMPostroll;
		
		private var _stage:Stage;
		
		private var fullTimer:Timer;
		private var fullCount:int;
		public var fullState:String;
		
		public function NMVideoFullscreen(st:Stage)
		{
			
			this._stage = st;
			
			NMPlayerObjects.videoFullscreen = this;
			
			fullTimer = new Timer(200);
			fullTimer.addEventListener(TimerEvent.TIMER, detectTimer);
			
			fullState = "NORMAL";
			
		}
		
		public function gotoFullScreen():void
		{
			
			fullCount = 0;
			fullTimer.start();
			
			_stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullOpen);
			
			if (_stage.displayState == StageDisplayState.NORMAL) {
					
				_stage.displayState = StageDisplayState.FULL_SCREEN;
				
			} else {
				
				_stage.displayState = StageDisplayState.NORMAL;
				
			}
			
		}
		
		private function fullOpen(event:FullScreenEvent):void
		{
			
			_stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullOpen);
			
			if (_stage.displayState == StageDisplayState.FULL_SCREEN) {
				
				fullState = "FULL";
				
			}
			
			if (_stage.displayState == StageDisplayState.NORMAL) {
				
				fullState = "NORMAL";
				
			}
			
		}
		
		private function detectTimer(event:TimerEvent):void
		{
			
			alignObjects();
			
			if (fullState == "NORMAL") {
				
				fullCount ++;
				
				if (fullCount >= 10) {
					
					fullTimer.stop();
					
				}
				
			}
			
		}
		
		private function alignObjects():void
		{
			
			try {
				
				viad.resizePostroll(_stage.stageWidth, _stage.stageHeight);
				
				
			} catch (err:Error) {
				
				fullTimer.stop();
				
			}
			
			try {
				
				postroll.resizePostroll(_stage.stageWidth, _stage.stageHeight);
				
			} catch (err:Error) {
				
				fullTimer.stop();
				
			}
			
			
			playerObjects.alignObjects();
			videoConstructor.resizeBarLoadAndTime();
			
		}
		
		
	}
}