package dl.physic.move;

/**
 * ...
 * @author Namide
 */
class PlatformUtils
{

	inline function new() {
		throw "static class";
	}
	
	public inline static function getVX( pxBySec:Float, frameDelay:Float ):Float {
		return pxBySec * frameDelay;
	}
	
	public inline static function getJumpStartVY( jumpPx:Float, gravity:Float ):Float {
		return Math.sqrt( (gravity + gravity) * jumpPx );
	}
	
	public inline static function getJumpVY( maxPxJump:Float, jumpStartVY:Float, gravity:Float ):Float {
		return - (jumpStartVY * jumpStartVY / (maxPxJump + maxPxJump) - gravity);
	}
	
	public inline static function getJumpVX( maxPxJump:Float, jumpStartVY:Float, jumpVY:Float = 0, gravity:Float ):Float {
		return maxPxJump * (gravity - jumpVY) / (jumpStartVY + jumpStartVY);
	}
	
	public static function maxPxYJump( maxPxXJump:Float, jumpStartVY:Float, jumpVX:Float, jumpVY:Float, gravity:Float ):Float
	{
		var vY:Float = jumpStartVY;
		var vX:Float = jumpVX;
		var h:Float = 0;
		var w:Float = 0;
		
		while ( h >= 0 )
		{
			h += vY;
			w += jumpVX;
			
			if ( w > maxPxXJump )
				return h;
			
			vY += jumpVY - gravity;
		}
		return 0;
	}
	
	public static function maxPxXJump( maxPxYJump:Float, jumpStartVY:Float, jumpVX:Float, jumpVY:Float, gravity:Float ):Float
	{
		var vY:Float = jumpStartVY;
		var vX:Float = jumpVX;
		var h:Float = 0;
		var w:Float = 0;
		
		while ( vY > 0 )
		{
			h += vY;
			w += jumpVX;
			
			if ( h > maxPxYJump )
				return w;
			
			vY += jumpVY - gravity;
		}
		return 0;
	}
	
}