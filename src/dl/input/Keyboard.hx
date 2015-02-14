package dl.input ;
import dl.physic.body.Body;
import haxe.Timer;
import flash.events.KeyboardEvent;

@:enum
abstract Keys(UInt)
{
	var keyLeft = 37; 		// left arrow
	var keyRight = 39; 		// right arrow
	var keyTop = 38; 		// up arrow
	var keyBottom = 40; 	// down arrow
	var keyB1 = 32; 		// space
	var keyB2 = 17; 		// ctrl
	var keyStart = 13; 		// enter
	var keySelect = 27; 	// escape
	
	inline function new( i:UInt ) { this = i; }
	
	@:from
	public static function fromInt(i:UInt):Keys {
		return new Keys(i);
	}
	
	@:to
	public function toUInt():UInt {
		return this;
	}
}

/**
 * Intermediate for keyboard inputs
 * 
 * @author Namide
 */
class Keyboard
{
	var _listKeyPressed:Array<UInt>;
	var _listKeyPressedTime:Array<Float>;
	var _accTime:Float = 0.08;
	
	public function new( accTimeSec:Float = 0.08 )
	{
		_accTime = accTimeSec;
		
		_listKeyPressed = [];
		_listKeyPressedTime = [];
		
		flash.Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDown );
		flash.Lib.current.stage.addEventListener( KeyboardEvent.KEY_UP, keyUp );
	}
	
	public inline function getAxisX():Float
	{
		var o:Float = getFloat( Keys.keyRight );
		if ( o <= 0 ) o = -getFloat( Keys.keyLeft );
		return o;
	}
	
	public inline function getAxisY():Float
	{
		var o:Float = -getFloat( Keys.keyTop );
		if ( o >= 0 ) o = getFloat( Keys.keyBottom );
		return o;
	}
	
	public inline function getB1():Float
	{
		return getFloat( Keys.keyB1 );
	}
	
	public inline function getB2():Float
	{
		return getFloat( Keys.keyB2 );
	}
	
	public inline function getStart():Bool
	{
		return getFloat( Keys.keyStart ) != 0;
	}
	
	public inline function getSelect():Bool
	{
		return getFloat( Keys.keySelect ) != 0;
	}
	
	public inline function getKeyPressed( keyCode:UInt ):Bool
	{
		return _listKeyPressed.indexOf( keyCode ) > -1;
	}
	
	public function dispose():Void
	{
		flash.Lib.current.stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDown );
		flash.Lib.current.stage.removeEventListener( KeyboardEvent.KEY_UP, keyUp );
		
		_listKeyPressed = [];
		_listKeyPressedTime = [];
	}
	
	function getFloat(key:UInt):Float
	{
		var i = Lambda.indexOf( _listKeyPressed, key );
		if ( i > -1 )
		{
			var t:Float = ( haxe.Timer.stamp() - _listKeyPressedTime[i] ) / _accTime;
			return ( t > 1 ) ? 1 : ( t < 0 ) ? 0 : t;
		}
		return 0;
	}
	
	function keyDown( e:KeyboardEvent ):Void
	{
		_listKeyPressed.push( e.keyCode );
		_listKeyPressedTime.push( haxe.Timer.stamp() );
	}
	
	function keyUp( e:KeyboardEvent ):Void
	{
		var i:Int = _listKeyPressed.indexOf( e.keyCode );
		while ( i > -1 )
		{
			_listKeyPressed.splice( i, 1 );
			_listKeyPressedTime.splice( i, 1 );
			i = _listKeyPressed.indexOf( e.keyCode );
		}
	}
}