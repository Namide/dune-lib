package dl.input ;
import dl.physic.body.Body;
import haxe.Timer;
import flash.events.KeyboardEvent;

@:enum
abstract Keys(UInt)
{
	var keyLeft = 37; //  flash.ui.Keyboard.LEFT;
	var keyRight = 39; //flash.ui.Keyboard.RIGHT;
	var keyTop = 38; //flash.ui.Keyboard.UP;
	var keyBottom = 40; //flash.ui.Keyboard.DOWN;
	var keyB1 = 32; //flash.ui.Keyboard.SPACE;
	var keyB2 = 17; // Ctrl enter flash.ui.Keyboard.SHIFT;
	var keyStart = 13; //flash.ui.Keyboard.ENTER;
	var keySelect = 27; //flash.ui.Keyboard.DELETE;
	
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
 * ...
 * @author Namide
 */
class Keyboard
{
	/*public var keyLeft(default, default):UInt = 37; //  flash.ui.Keyboard.LEFT;
	public var keyRight(default, default):UInt = 39; //flash.ui.Keyboard.RIGHT;
	public var keyTop(default, default):UInt = 38; //flash.ui.Keyboard.UP;
	public var keyBottom(default, default):UInt = 40; //flash.ui.Keyboard.DOWN;
	public var keyB1(default, default):UInt = 32; //flash.ui.Keyboard.SPACE;
	public var keyB2(default, default):UInt = 17; // Ctrl enter flash.ui.Keyboard.SHIFT;
	public var keyStart(default, default):UInt = 13; //flash.ui.Keyboard.ENTER;
	public var keySelect(default, default):UInt = 27; //flash.ui.Keyboard.DELETE;*/
	
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
	
	public function getKeyPressed( keyCode:UInt ):Bool
	{
		return Lambda.has( _listKeyPressed, keyCode );
	}
	
	public function dispose():Void
	{
		flash.Lib.current.stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDown );
		flash.Lib.current.stage.removeEventListener( KeyboardEvent.KEY_UP, keyUp );
		
		_listKeyPressed = [];
		_listKeyPressedTime = [];
	}
	
	function keyDown( e:KeyboardEvent ):Void
	{
		_listKeyPressed.push( e.keyCode );
		_listKeyPressedTime.push( haxe.Timer.stamp() );
	}
	
	function keyUp( e:KeyboardEvent ):Void
	{
		while ( Lambda.has( _listKeyPressed, e.keyCode ) )
		{
			var i:Int = Lambda.indexOf( _listKeyPressed, e.keyCode );
			_listKeyPressed.splice( i, 1 );
			_listKeyPressedTime.splice( i, 1 );
		}
	}
}