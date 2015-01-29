package dl.physic.input;

import dl.physic.body.Body;
import dl.physic.contact.BodyContact.BodyLimitFlags;
import dl.physic.move.PlatformPhysicSystem;
import dl.physic.move.PlatformUtils;

/*@:enum
abstract BodyAnimation(Int)
{
	var init = 0;
	var contacts = 1;
	var limits = 2;
	
	inline function new( i:Int ) { this = i; }
	
	@:from
	public static function fromInt(i:Int):BodyContactState {
		return new BodyContactState(i);
	}
	
	@:to
	public function toInt():Int {
		return this;
	}
}*/

/**
 * ...
 * @author Namide
 */
class PlatformPlayerController extends Keyboard
{
	var _fDelay:Float;
	
	var _groundVX:Float; // tiles / sec
	var _jumpStartVY:Float;
	var _jumpVY:Float;
	var _jumpVXMin:Float;
	var _jumpVXMax:Float;
	var _jumpTimeLock:Float;
	var _actionPressed:Bool;
	var _landmark:Float = 0;
	
	//var _t:UInt;
	var _body:Body;
	
	//public var wallBrake:Float = 1;

	public function new( body:Body, platformPhysicSystem:PlatformPhysicSystem, frameDelaySec:Float ) 
	{
		super(0.08);
		
		_body = body;
		_fDelay = frameDelaySec;
		_actionPressed = false;
		
		setRun( 12 * 32, 0.06 );
		setJump( 1.5 * 32, 3 * 32, 3 * 32, 6 * 32, 0.06, 0.3*1000, platformPhysicSystem.gY );
	}
	
	function setRun( vel:Float, accTime:Float ):Void {
		_groundVX = PlatformUtils.getVX( vel, _fDelay );
	}
	
	function setJump( hMin:Float, hMax:Float, lMin:Float, lMax:Float, accTime:Float, timeLock:Float, g:Float ):Void
	{
		_jumpStartVY = PlatformUtils.getJumpStartVY( hMin, g );
		_jumpVY = PlatformUtils.getJumpVY( hMax, _jumpStartVY, g );
		_jumpVXMin = PlatformUtils.getJumpVY( lMin, _jumpStartVY, g );
		_jumpVXMax = PlatformUtils.getJumpVX( lMax, _jumpStartVY, _jumpVY, g );
		_jumpTimeLock = timeLock;
	}
	
	public function update( t:Float ):Void
	{
		//_t += dt;
		
		var bottomWall:Bool = _body.contacts.fixedLimits & BodyLimitFlags.bottom != 0;
		var leftWall:Bool = _body.contacts.fixedLimits & BodyLimitFlags.left != 0;
		var rightWall:Bool = _body.contacts.fixedLimits & BodyLimitFlags.right != 0;
		var topWall:Bool = _body.contacts.fixedLimits & BodyLimitFlags.top != 0;
		
		var xAxis:Float = this.getAxisX();
		//var g = _sm.settings.gravity;
		
		/*if ( !leftWall && !rightWall || entity.transform.vY < 0 )
		{
			entity.transform.vY += g;
		}
		else
		{
			entity.transform.vY += wallBrake * g;
		}*/
		
		/*if (entity.health != null && entity.health.isHearted())
		{
			if ( BitUtils.has( _display.type, ComponentType.DISPLAY_ANIMATED ) )
			{
				_display.play( "hurt" );
			}
			return;
		}*/
		
		if ( xAxis != 0 )
		{
			if ( xAxis < 0 && !leftWall )
			{
				if ( bottomWall )
				{
					_body.physic.vX = xAxis * _groundVX;
				}
				else if ( _body.physic.vX > -_jumpVXMax && t > _landmark )
				{
					_body.physic.vX = xAxis * _jumpVXMax;
				}
			}
			else
			{
				if ( !rightWall )
				{
					if ( bottomWall )
					{
						_body.physic.vX = xAxis * _groundVX;
					}
					else if ( _body.physic.vX < _jumpVXMax && t > _landmark )
					{
						_body.physic.vX = xAxis * _jumpVXMax;
					}
				}
			}
		}
		else
		{
			if ( bottomWall )
			{
				_body.physic.vX = 0;
			}
			else if ( !topWall && !leftWall && !rightWall )
			{
				if ( _body.physic.vX > _jumpVXMin )
					_body.physic.vX = _jumpVXMin;
				
				if ( _body.physic.vX < -_jumpVXMin )
					_body.physic.vX = -_jumpVXMin;
			}
		}
		
		var b1:Float = this.getB1();
		if ( b1 > 0 )
		{
			if ( bottomWall && !_actionPressed )
			{
				_body.physic.vY = - _jumpStartVY;
				
				if ( xAxis < 0 )
					_body.physic.vX = -_jumpVXMax;
				else if ( xAxis > 0 )
					_body.physic.vX = _jumpVXMax;
			}
			else if ( leftWall && !_actionPressed )
			{
				_body.physic.vY = -_jumpStartVY;
				_body.physic.vX = _jumpVXMax;
				_landmark = t + _jumpTimeLock;
			}
			else if ( rightWall && !_actionPressed )
			{
				_body.physic.vY = -_jumpStartVY;
				_body.physic.vX = -_jumpVXMax;
				_landmark = t + _jumpTimeLock;
			}
			else if ( (!topWall && !bottomWall && !leftWall && !rightWall) )
			{
				_body.physic.vY -= _jumpVY;
			}
			
			if ( !_actionPressed )
			{
				_actionPressed = true;
			}
		}
		else if ( _actionPressed )
		{
			_actionPressed = false;
		}
		
		// DIRECTION
		/*var lastDirX:Int = entity.transform.dirX;
		var lastDirY:Int = entity.transform.dirY;
		entity.transform.dirX = (this.getAxisX() > 0) ? 1 : (this.getAxisX() < 0) ? -1 : 0;
		entity.transform.dirY = (this.getAxisY() > 0) ? 1 : (this.getAxisY() < 0) ? -1 : 0;
		if ( entity.transform.dirX == 0 && entity.transform.dirY == 0 )
		{
			entity.transform.dirX = (_display.isToRight()) ? 1 : -1;
		}
		*/
		
		// ANIMATIONS
		/*if ( entity.transform.vX < platformVX ) _display.setToRight( false );
		else if ( entity.transform.vX > platformVX ) _display.setToRight( true );
		if ( BitUtils.has( _display.type, ComponentType.DISPLAY_ANIMATED ) )
		{
			if ( bottomWall )
			{
				if ( entity.transform.vX == platformVX ) _display.play( "stand" );
				else	_display.play( "run" );
			}
			else if ( leftWall || rightWall )
			{
				_display.play( "wall" );
			}
			else
			{
				_display.play( "jump" );
			}
		}*/
	}
	
	public inline function getMaxPxXJump( maxTilesXJump:Float, gravity:Float ):Float
	{
		return PlatformUtils.maxPxXJump( maxTilesXJump, _jumpStartVY, _jumpVXMax, _jumpVY, gravity );
	}
	
	public inline function getMaxPxYJump( maxTilesYJump:Float, gravity:Float ):Float
	{
		return PlatformUtils.maxPxYJump( maxTilesYJump, _jumpStartVY, _jumpVXMax, _jumpVY, gravity );
	}
	
	// STATICS CALCULATIONS
	public inline static function getVX( pxBySec:Float, frameDelay:Float ):Float
	{
		return pxBySec / frameDelay;
	}
	
	public inline static function getJumpStartVY( jumpPx:Float, gravity:Float ):Float
	{
		return Math.sqrt( 2 * gravity * jumpPx );
	}
	
	public inline static function getJumpVY( maxPxJump:Float, jumpStartVY:Float, gravity:Float ):Float
	{
		return - (jumpStartVY * jumpStartVY / (2 * maxPxJump) - gravity );
	}
	
	public inline static function getJumpVX( maxPxJump:Float, jumpStartVY:Float, jumpVY:Float = 0, gravity:Float ):Float
	{
		return maxPxJump * ( gravity - jumpVY ) / ( 2 * jumpStartVY );
	}
	
	static function maxPxYJump( maxPxXJump:Float, jumpStartVY:Float, jumpVX:Float, jumpVY:Float, gravity:Float ):Float
	{
		var vY:Float = jumpStartVY;
		var vX:Float = jumpVX;
		var h:Float = 0;
		var w:Float = 0;
		
		while ( h >= 0 )
		{
			h += vY;
			w += jumpVX;
			if ( w > maxPxXJump ) return h;
			vY += jumpVY - gravity;
		}
		
		return -1;
	}
	
	static function maxPxXJump( maxPxYJump:Float, jumpStartVY:Float, jumpVX:Float, jumpVY:Float, gravity:Float ):Float
	{
		var vY:Float = jumpStartVY;
		var vX:Float = jumpVX;
		var h:Float = 0;
		var w:Float = 0;
		
		while ( vY > 0 )
		{
			h += vY;
			w += jumpVX;
			if ( h > maxPxYJump ) return w;
			vY += jumpVY - gravity;
		}
		
		return -1;
	}	
	
}