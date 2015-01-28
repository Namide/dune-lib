package dl.physic.move;
import dl.physic.body.Body;
import dl.physic.contact.ISpace;
import dl.physic.move.BodyPhysic.BodyPhysicFlags;

/**
 * ...
 * @author Namide
 */
class PlatformPhysicSystem
{
	var all:Array<Body>;
	
	public var gX:Float = 0;
	public var gY:Float = 30;
	
	public function new( gravityY = 2.0 ) 
	{
		gY = gravityY;
		all = [];
	}
	
	public function addBody( body:Body ):Void
	{
		if ( all.indexOf( body ) > 0 )
			removeBody( body );
		
		if ( body.physic != null &&
			 ( body.physic.flags & BodyPhysicFlags.dependant != 0 ||
			   body.physic.flags & BodyPhysicFlags.gravity != 0 ||
			   body.physic.flags & BodyPhysicFlags.velocity != 0 ) )
		{
			all.push( body );
		}
	}
	
	public function updateMoves()
	{
		for ( b in all )
		{
			var p = b.physic;
			
			if ( p.flags & BodyPhysicFlags.gravity != 0 )
			{
				p.vX += gX;
				p.vY += gY;
			}
			
			if ( p.flags & BodyPhysicFlags.dependant != 0 )
			{
				b.addPos( p.vX, p.vY );
			}
		}
	}
	
	public function updatePositions()
	{
		for ( b in all )
		{
			var p = b.physic;
			
			
		}
	}
	
	public function removeBody( body:Body ):Void
	{
		all.remove( body );
	}
	
}