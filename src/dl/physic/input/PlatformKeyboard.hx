package dl.physic.input;
import dl.physic.body.Body;
import hxd.Key;

/**
 * ...
 * @author Namide
 */
class PlatformKeyboard
{

	//var _accTimeSec:Float;
	var _delta:Float;
	
	public var x:Float;
	var _xTime:Float;
	
	public function new( body:Body, fps:Float = 50, accTimeSec:Float = 0.8 )
	{
		_delta = 1 / (accTimeSec * fps);
		init();
	}
	
	function init()
	{
		hxd.Key.initialize();
		
	}
	
	function getAxisX()
	{
		if (  hxd.Key. hxd.Key.LEFT )
		{
			
		}
	}
	
	public function refresh()
	{
		
	}
	
	function getFloat( isPressed:Bool, time:Float ):Float
	{
		var i = Lambda.indexOf( _listKeyPressed, key );
		if ( i > -1 )
		{
			var t:Float = ( DTime.getRealMS() - _listKeyPressedTime[i] ) / _accTime;
			return ( t > 1 ) ? 1 : ( t < 0 ) ? 0 : t;
		}
		return 0;
	}

}