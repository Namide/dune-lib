package dl.utils ;

/**
 * ...
 * @author Namide
 */
class Timer
{
	static var STAGE:flash.display.Stage;
	var _realT:Float;
	
	public var frameRest( default, null ):Float;
	public var frameTime( default, null ):Float;
	
	public var pause( default, default ):Bool;
	public var dtSec( default, null ):Float;
	
	public var distord( default, default ):Float;
	
	public var onFrameUpdate:Float->Void;
	public var onDisplayUpdate:Float->Void;
	
	public function new( FPS:Int = 50, sec:Float = 0 ) 
	{
		_realT = getRealSec();
		
		dtSec = 0;
		pause = false;
		frameRest = 0;
		
		distord = 1;
		frameTime = 1 / FPS;
		
		STAGE = flash.Lib.current.stage;
		STAGE.addEventListener( flash.events.Event.ENTER_FRAME, update );
	}
	
	public function dispose():Void
	{
		STAGE.removeEventListener( flash.events.Event.ENTER_FRAME, update );
	}
	
	function update( ?e:Dynamic ):Void
	{
		if ( pause )
		{
			dtSec = 0;
			_realT = getRealSec();
			return;
		}
		
		dtSec = (getRealSec() - _realT) * distord;
		if ( dtSec <= 0 ) return;
		
		frameRest += ( dtSec / frameTime );
		_realT = getRealSec();
		
		var t:Float = 0;
		if ( onFrameUpdate != null || onDisplayUpdate != null )
		{
			while ( frameRest > 0 )
			{
				frameRest--;
				t += frameTime;
				if ( onFrameUpdate != null )
					onFrameUpdate( frameTime/*, (frameRest < 1)*/ );
			}
		}
		
		if ( t > 0 && onDisplayUpdate != null )
		{
			onDisplayUpdate( t );
		}
	}
	
	public function restart():Void { _realT = getRealSec(); dtSec = 0; frameRest = 0; };
	
	public static inline function getRealSec():Float
	{
		return haxe.Timer.stamp();
		
		/*#if (flash || openfl)
			return flash.Lib.getTimer();
		#elseif (neko || php)
			return Sys.time() * 1000;
		#elseif js
			return Math.round( Date.now().getTime() );
		#elseif cpp
			return untyped __global__.__time_stamp() * 1000;
		#else
			return 0;
		#end*/
	}
	
}