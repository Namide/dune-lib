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
	public static function fromUInt(i:UInt):Keys {
		return new Keys(i);
	}
	
	@:to
	public function toUInt():UInt {
		return this;
	}
}

typedef Listener = {
	var key: Keys;
	@:optional var press: Void->Void;
	@:optional var release: Void->Void;
}

/**
 * Intermediate for keyboard inputs
 * 
 * @author Namide
 */
class Keyboard
{
	var _listener:Array<Listener>;
	
	var _listKeyPressed:Array<UInt>;
	var _listKeyPressedTime:Array<Float>;
	var _accTime:Float = 0.08;
	
	var _menuEnabled:Bool;
	var _onMenuPrev:Keys->Void;
	var _onMenuNext:Keys->Void;
	var _onMenuValid:Keys->Void;
	var _onMenuCancel:Keys->Void;
	
	public function new( accTimeSec:Float = 0.08 )
	{
		_accTime = accTimeSec;
		
		_listKeyPressed = [];
		_listKeyPressedTime = [];
		_listener = [];
		
		flash.Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDown );
		flash.Lib.current.stage.addEventListener( KeyboardEvent.KEY_UP, keyUp );
		
		_menuEnabled = false;
	}
	
	public function addKeyListener( key:Keys, pressCallback:Void->Void = null, releaseCallback:Void->Void = null )
	{
		var l:Listener = { key:key };
		
		if ( pressCallback != null )
			l.press = pressCallback;
		
		if ( releaseCallback != null )
			l.release = releaseCallback;
		
		_listener.push( l );
	}
	
	public function removeKeyListener( key:Keys, pressCallback:Void->Void = null, releaseCallback:Void->Void = null )
	{
		var e = Lambda.find( _listener, function( d:Listener ) { return d.key == key && d.press == pressCallback && d.release == releaseCallback; } );
		if ( e != null )
		{
			_listener.remove( e );
		}
	}
	
	public function removeAllKeyListener()
	{
		_listener = [];
	}
	
	public function addListener( onPrev:Keys->Void, onNext:Keys->Void, onValid:Keys->Void, onCancel:Keys->Void )
	{
		//removeListener();
		
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
		
		removeAllKeyListener();
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
		
		for ( l in _listener )
		{
			if ( l.key == e.keyCode && l.press != null )
				l.press();
		}
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
					_onMenuNext(key);
			}
			else if ( key == Keys.keyLeft || key == Keys.keyTop )
			{
				if ( _onMenuPrev != null )
					_onMenuPrev(key);
			}
			else if ( key == Keys.keyB1 || key == Keys.keyStart )
			{
				if ( _onMenuValid != null )
					_onMenuValid(key);
			}
			else if ( key == Keys.keyB2 || key == Keys.keySelect )
			{
				if ( _onMenuCancel != null )
					_onMenuCancel(key);
			}
		}
		
		for ( l in _listener )
		{
			if ( l.key == key && l.release != null )
				l.release();
		}
	}
}