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
	
	public function updatePositions( space:ISpace )
	{
		for ( b in all )
		{
			if ( b.physic.flags & BodyPhysicFlags.dependant != 0 )
				updatePosBody( b, b.contacts.classByArea(), space );
			
		}
	}
	
	function updatePosBody( b:Body, list:Array<Body>, space:ISpace ):Void
	{
		if ( list.length < 1 || b.shape.getHitArea( list[0].shape ) <= 0 )
			return;
		
		// calculate last position
		var b2 = list[0];
		var ba0 = ( b.print != null ) ? b.print : b.shape;
		var bb0 = ( b2.print != null ) ? b2.print : b2.shape;
		
		
		for ( a in b.contacts.classByArea() )
		{
			var w = Math.min( a.shape.aabbXMax, b.shape.aabbXMax ) - Math.max( a.shape.aabbXMin, b.shape.aabbXMin );
			var h = Math.min( a.shape.aabbYMax, b.shape.aabbYMax ) - Math.max( a.shape.aabbYMin, b.shape.aabbYMin );
		}
		
		var pos:BodyLimitFlags = 0;
		var corner:Int = 0;
		if ( ba0.aabbXMin >= bb0.aabbXMax ) { pos |= BodyLimitFlags.left; corner++; }
		if ( ba0.aabbXMax <= bb0.aabbXMin ) { pos |= BodyLimitFlags.right; corner++; }
		if ( ba0.aabbYMin >= bb0.aabbYMax ) { pos |= BodyLimitFlags.top; corner++; }
		if ( ba0.aabbYMax <= bb0.aabbYMin ) { pos |= BodyLimitFlags.bottom; corner++; }
		
		if ( corner > 1 )
		{
			var ba1 = b.shape;
			var bb1 = b2.shape;
			
			var Vx = ba1.aabbXMin - ( ( b.print != null ) ? b.print.aabbXMin : 0 );
			var Vy = ba1.aabbYMin - ( ( b.print != null ) ? b.print.aabbYMin : 0 );
			if ( Vx == 0 && Vy == 0 )
				Vx = Vy = 1;
			
			if ( pos & BodyLimitFlags.bottom != 0 )
			{
				// area height
				var Ah = ba1.aabbYMax - bb1.aabbYMin;
				
				if ( pos & BodyLimitFlags.right != 0 )
				{
					var Aw = ba1.aabbXMax - bb1.aabbXMin;
					if ( Vx * Ah > Vy * Aw ) {
						pos = BodyLimitFlags.right;
					}
					else {
						pos = BodyLimitFlags.bottom;
					}
				}
				else if ( pos & BodyLimitFlags.left != 0 )
				{
					var Aw = bb1.aabbXMax - ba1.aabbXMin;
					if ( Vx * Ah > Vy * Aw ) {
						pos = BodyLimitFlags.left;
					}
					else {
						pos = BodyLimitFlags.bottom;
					}
				}
			}
			else if ( pos & BodyLimitFlags.top != 0 )
			{
				var Ah = bb1.aabbYMax - ba1.aabbYMin;
				
				if ( pos & BodyLimitFlags.right != 0 )
				{
					var Aw = ba1.aabbXMax - bb1.aabbXMin;
					if ( Vx * Ah > Vy * Aw )
					{
						pos = BodyLimitFlags.right;
					}
					else
					{
						pos = BodyLimitFlags.top;
					}
				}
				else if ( pos & BodyLimitFlags.left != 0 )
				{
					var Aw = bb1.aabbXMax - ba1.aabbXMin;
					if ( Vx * Ah > Vy * Aw ) {
						pos = BodyLimitFlags.left;
					}
					else {
						pos = BodyLimitFlags.top;
					}
				}
			}
		}
		
		
		
		if ( pos & BodyLimitFlags.none != 0 )
			pos = BodyLimitFlags.bottom;
		
		// update position and velocity
		switch( pos )
		{
			case BodyLimitFlags.top:
				
				b.setY( b2.shape.aabbYMax );
				if ( b.physic.vY < 0 )
					b.physic.vY = 0;
				
			case BodyLimitFlags.bottom:
				
				b.setY( b2.shape.aabbYMin - b.shape.getH() );
				if ( b.physic.vY > 0 )
					b.physic.vY = 0;
				
			case BodyLimitFlags.left:
				
				b.setX( b2.shape.aabbXMax );
				if ( b.physic.vX < 0 )
					b.physic.vX = 0;
				
			case BodyLimitFlags.right:
				
				b.setX( b2.shape.aabbXMin - b.shape.getW() );
				if ( b.physic.vX > 0 )
					b.physic.vX = 0;
				
			default:
				
				trace("no contact direction?");
		}
		
		list = space.hitTestActive( b );
		updatePosBody( b, list, space );
	}
	
	public function removeBody( body:Body ):Void
	{
		all.remove( body );
	}
	
}