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
	
	var _menuEnabled:Bool;
	var _onMenuPrev:Void->Void;
	var _onMenuNext:Void->Void;
	var _onMenuValid:Void->Void;
	var _onMenuCancel:Void->Void;
	
	public function new( accTimeSec:Float = 0.08 )
	{
		_accTime = accTimeSec;
		
		_listKeyPressed = [];
		_listKeyPressedTime = [];
		
		flash.Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDown );
		flash.Lib.current.stage.addEventListener( KeyboardEvent.KEY_UP, keyUp );
		
		_menuEnabled = false;
	}
	
	public function addListener( onPrev:Void->Void, onNext:Void->Void, onValid:Void->Void, onCancel:Void->Void )
	{
		#if debug
			
			if ( _menuEnabled )
				throw "You can't add more than 1 listener";
		
		#end
		
		_onMenuPrev = onPrev;
		_onMenuNext = onNext;
		_onMenuValid = onValid;
		_onMenuCancel = onCancel;
		_menuEnabled = true;
	}
	
	public function removeListener()
	{
		_onMenuPrev = _onMenuNext = _onMenuValid = _onMenuCancel = null;
		_menuEnabled = false;
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
		var key = e.keyCode;
		var i:Int = _listKeyPressed.indexOf(key);
		while ( i > -1 )
		{
			_listKeyPressed.splice( i, 1 );
			_listKeyPressedTime.splice( i, 1 );
			i = _listKeyPressed.indexOf(key);
		}
		
		if ( _menuEnabled )
		{
			if ( key == Keys.keyRight || key == Keys.keyBottom )
			{
				if ( _onMenuNext != null )
					_onMenuNext();
			}
			else if ( key == Keys.keyLeft || key == Keys.keyTop )
			{
				if ( _onMenuPrev != null )
					_onMenuPrev();
			}
			else if ( key == Keys.keyB1 || key == Keys.keyStart )
			{
				if ( _onMenuValid != null )
					_onMenuValid();
			}
			else if ( key == Keys.keyB2 || key == Keys.keySelect )
			{
				if ( _onMenuCancel != null )
					_onMenuCancel();
			}
		}
	}
}