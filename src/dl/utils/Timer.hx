package dl.utils ;

/**
 * ...
 * @author Namide
 */
class Timer
{
	var _realT:Float;
	
	public var frameRest( default, null ):Float;
	public var frameTime( default, null ):Float;
	
	public var pause( default, default ):Bool;
	public var dtSec( default, null ):Float;
	
	public var distord( default, default ):Float;
	
	public var onFrameUpdate:Float->Bool->Void;
	
	public function new( FPS:Int = 50, sec:Float = 0 ) 
	{
		_realT = getRealSec();
		
		dtSec = 0;
		pause = false;
		frameRest = 0;
		
		distord = 1;
		frameTime = 1 / FPS;
	}
	
	public function update():Void
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
		
		if ( onFrameUpdate != null )
		{
			while ( !(frameRest < 1) )
			{
				frameRest--;
				onFrameUpdate( frameTime, (frameRest < 1) );
			}
		}
	}
	
	public function restart():Void { _realT = getRealSec(); dtSec = 0; frameRest = 0; };
	
	//public inline function getDtSec():Float { return dtMs * 0.001; }
	//public inline function getSec():Float { return tMs * 0.001; }
	
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