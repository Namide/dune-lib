package dl.physic.move;
import dl.physic.body.Body;
import dl.physic.contact.BodyContact.BodyLimitFlags;
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
			trace(b.contacts.length());
			
			if ( b.physic.flags & BodyPhysicFlags.dependant != 0 )
				updatePosBody( b, b.contacts.length() );
			
		}
	}
	
	function updatePosBody( b:Body, rest:Int = 10 ):Void
	{
		if ( b.contacts.length() < 1 || rest < 0 )
			return;
		
		// calculate last position
		var b2 = b.contacts.classByArea()[0];
		var ba0 = ( b.print != null ) ? b.print : b.shape;
		var bb0 = ( b2.print != null ) ? b2.print : b2.shape;
		
		var pos:BodyLimitFlags = 0;
		var corner:Int = 0;
		if ( ba0.aabbXMin >= bb0.aabbXMax ) { pos |= BodyLimitFlags.left; corner++; }
		if ( ba0.aabbXMax <= bb0.aabbXMin ) { pos |= BodyLimitFlags.right; corner++; }
		if ( ba0.aabbYMin >= bb0.aabbYMax ) { pos |= BodyLimitFlags.top; corner++; }
		if ( ba0.aabbYMax <= bb0.aabbYMin ) { pos |= BodyLimitFlags.bottom; corner++; }
		
		if ( corner > 1 )
		{
			if ( pos & BodyLimitFlags.bottom != 0 )
			{
				if ( pos & BodyLimitFlags.right != 0 )
				{
					if ( ba0.aabbYMax - bb0.aabbYMin > ba0.aabbXMax - bb0.aabbXMin )
					{
						pos = BodyLimitFlags.bottom;
					}
					else
					{
						pos = BodyLimitFlags.right;
					}
				}
				else if ( pos & BodyLimitFlags.left != 0 )
				{
					if ( ba0.aabbYMax - bb0.aabbYMin < ba0.aabbXMin - bb0.aabbXMax )
					{
						pos = BodyLimitFlags.bottom;
					}
					else
					{
						pos = BodyLimitFlags.left;
					}
				}
			}
			else if ( pos & BodyLimitFlags.top != 0 )
			{
				if ( pos & BodyLimitFlags.right != 0 )
				{
					if ( ba0.aabbYMin - bb0.aabbYMax < ba0.aabbXMax - bb0.aabbXMin )
					{
						pos = BodyLimitFlags.top;
					}
					else
					{
						pos = BodyLimitFlags.right;
					}
				}
				else if ( pos & BodyLimitFlags.left != 0 )
				{
					if ( ba0.aabbYMin - bb0.aabbYMax < ba0.aabbXMin - bb0.aabbXMax )
					{
						pos = BodyLimitFlags.top;
					}
					else
					{
						pos = BodyLimitFlags.left;
					}
				}
			}
		}
		
		if ( pos & BodyLimitFlags.none != 0 )
			pos = BodyLimitFlags.bottom;
		
		// update position
		switch( pos )
		{
			case BodyLimitFlags.top:
				
				b.setY( b2.shape.aabbYMax );
				
			case BodyLimitFlags.bottom:
				
				b.setY( b2.shape.aabbYMin - b.shape.getH() );
				
			case BodyLimitFlags.left:
				
				b.setX( b2.shape.aabbXMax );
				
			case BodyLimitFlags.right:
				
				b.setX( b2.shape.aabbXMin - b.shape.getW() );
				
			default:
				
				trace("no contact direction?");
		}
		
		updatePosBody( b, rest - 1 );
	}
	
	public function removeBody( body:Body ):Void
	{
		all.remove( body );
	}
	
}