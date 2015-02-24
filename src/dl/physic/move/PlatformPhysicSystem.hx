package dl.physic.move;
import dl.physic.body.Body;
import dl.physic.body.Shape;
import dl.physic.contact.BodyContact;
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
	
	/**
	 * To prevent error collision.
	 * More recursive is better for accuracy but less to memory and performances
	 */
	static inline var MAX_RECURSIVE:Int = 5; 
	
	public var gX:Float = 0.0;
	public var gY:Float = 2.0;
	
	public function new( gravityY = 2.0 ) 
	{
		gY = gravityY;
		all = [];
	}
	
	public function addBody( body:Body ):Void
	{
		if ( all.indexOf( body ) > 0 )
			removeBody( body );
		
		if ( body.physic != null )
			all.push( body );
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
			
			if ( p.flags & BodyPhysicFlags.velocity != 0 )
			{
				b.addPos( p.vX, p.vY );
			}
		}
	}
	
	public function updatePositions( space:ISpace )
	{
		var physDep = all.filter(function(b:Body) { return b.physic.flags & BodyPhysicFlags.dependant != 0; } );
		
		for ( b in physDep )
		{
			b.contacts.fixedLimits = BodyLimitFlags.none;
			b.contacts.classByArea();
			updatePosBody( b, b.contacts.list, space );
		}
		
		for ( b in physDep )
			updatePosBody( b, b.contacts.list, space, true );
	}
	
	inline function filterDrivable( list:Array<Body> )
	{
		return list.filter(function(b:Body) { return b.contacts.flags & BodyContactsFlags.drivable != 0; } );
	}
	
	inline function filterUndrivable( list:Array<Body> )
	{
		return list.filter(function(b:Body) { return b.contacts.flags & BodyContactsFlags.drivable == 0; } );
	}
	
	inline function getPos( a:Body, b:Body ):BodyLimitFlags
	{
		var i = 1;
		var ba0 = (i < a.shape.length) ? a.shape[i] : a.shape[0];
		var bb0 = (i < b.shape.length) ? b.shape[i] : b.shape[0];
		
		var pos:BodyLimitFlags = 0;
		var corner:Int = 0;
		
		// get historic position if the collision is over
		while ( pos == BodyLimitFlags.none && i < Body.SHAPE_PRINT_NUM )
		{
			ba0 = (i < a.shape.length) ? a.shape[i] : a.shape[0];
			bb0 = (i < b.shape.length) ? b.shape[i] : b.shape[0];
			
			pos = 0;
			corner = 0;
			if ( ba0.aabbXMin >= bb0.aabbXMax ) { pos |= BodyLimitFlags.left; corner++; }
			if ( ba0.aabbXMax <= bb0.aabbXMin ) { pos |= BodyLimitFlags.right; corner++; }
			if ( ba0.aabbYMin >= bb0.aabbYMax ) { pos |= BodyLimitFlags.top; corner++; }
			if ( ba0.aabbYMax <= bb0.aabbYMin ) { pos |= BodyLimitFlags.bottom; corner++; }
			
			i++;
		}		
		
		// determine the contact border by the previous position
		if ( corner > 1 )
		{
			var ba1 = a.shape[0];
			var bb1 = b.shape[0];
			
			var Vx = ba1.aabbXMin - ba0.aabbXMin;
			var Vy = ba1.aabbYMin - ba0.aabbYMin;
			
			if ( Vx == 0 && Vy == 0 )
				Vx = Vy = 1;
			
			if ( pos & BodyLimitFlags.bottom != 0 )
			{
				// area height
				var Ah = ba1.aabbYMax - bb1.aabbYMin;
				
				if ( pos & BodyLimitFlags.right != 0 )
				{
					var Aw = ba1.aabbXMax - bb1.aabbXMin;
					
					if ( Vx * Ah > Vy * Aw )
						pos = BodyLimitFlags.right;
					else
						pos = BodyLimitFlags.bottom;
				}
				else if ( pos & BodyLimitFlags.left != 0 )
				{
					var Aw = bb1.aabbXMax - ba1.aabbXMin;
					
					if ( Vx * Ah > Vy * Aw )
						pos = BodyLimitFlags.left;
					else
						pos = BodyLimitFlags.bottom;
				}
			}
			else if ( pos & BodyLimitFlags.top != 0 )
			{
				var Ah = bb1.aabbYMax - ba1.aabbYMin;
				
				if ( pos & BodyLimitFlags.right != 0 )
				{
					var Aw = ba1.aabbXMax - bb1.aabbXMin;
					
					if ( Vx * Ah > Vy * Aw )
						pos = BodyLimitFlags.right;
					else
						pos = BodyLimitFlags.top;
				}
				else if ( pos & BodyLimitFlags.left != 0 )
				{
					var Aw = bb1.aabbXMax - ba1.aabbXMin;
					
					if ( Vx * Ah > Vy * Aw )
						pos = BodyLimitFlags.left;
					else
						pos = BodyLimitFlags.top;
				}
			}
		}
		
		return pos;
	}
	
	function applyVertMobilesReact( top:Body, bottom:Body )
	{
		var m = 0.5;
		var topLimit = top.contacts.fixedLimits & BodyLimitFlags.top != 0;
		var botLimit = bottom.contacts.fixedLimits & BodyLimitFlags.bottom != 0;
		
		top.contacts.fixedLimits |= BodyLimitFlags.bottom;
		bottom.contacts.fixedLimits |= BodyLimitFlags.top;
		
		if ( topLimit && botLimit )
			return false;
		
		if ( topLimit )
			m = 0;
		else if ( botLimit )
			m = 1;
		else if ( top.physic != null && bottom.physic != null )
			m = top.physic.mass / (bottom.physic.mass + top.physic.mass);
		
		var y = (bottom.shape[0].aabbYMin - top.shape[0].aabbYMax) * m + top.shape[0].aabbYMax;
		bottom.setY( y );
		top.setY( y - top.shape[0].getH() );
		
		if ( top.physic.vY > 0 )
			top.physic.vY = 0;
			
		if ( bottom.physic.vY < 0 )
			bottom.physic.vY = 0;
		
		return true;
	}
	
	function applyHorMobilesReact( left:Body, right:Body )
	{
		var m = 0.5;
		var lefLimit = left.contacts.fixedLimits & BodyLimitFlags.left != 0;
		var rigLimit = right.contacts.fixedLimits & BodyLimitFlags.right != 0;
		
		left.contacts.fixedLimits |= BodyLimitFlags.right;
		right.contacts.fixedLimits |= BodyLimitFlags.left;
		
		if ( lefLimit && rigLimit )
			return false;
			
		if ( lefLimit )
			m = 0;
		else if ( rigLimit )
			m = 1;
		else if ( left.physic != null && right.physic != null )
			m = left.physic.mass / (right.physic.mass + left.physic.mass);
		
		var x = (right.shape[0].aabbXMin - left.shape[0].aabbXMax) * m + left.shape[0].aabbXMax;
		right.setX( x );
		left.setX( x - left.shape[0].getW() );
		
		if ( left.physic.vY > 0 )
			left.physic.vX = 0;
			
		if ( right.physic.vY < 0 )
			right.physic.vX = 0;
		
		return true;
	}
	
	function applyReact( a:Body, b:Body, reactBody:Bool ):Bool
	{
		var pos = getPos( a, b );
		
		// update position and velocity
		switch( pos )
		{
			case BodyLimitFlags.top:
				
				if ( (b.contacts.flags & BodyContactsFlags.platformBottom != 0 ||
					b.contacts.flags & BodyContactsFlags.wall != 0) )
				{
					if ( !reactBody )
					{
						a.contacts.fixedLimits |= BodyLimitFlags.top;
						a.setY( b.shape[0].aabbYMax );
						if ( a.physic.vY < 0 )
							a.physic.vY = 0;
						return true;
					}
					else
					{
						return applyVertMobilesReact( b, a );
					}
				}
				
			case BodyLimitFlags.bottom:
				
				if ( (b.contacts.flags & BodyContactsFlags.platformTop != 0 ||
					b.contacts.flags & BodyContactsFlags.wall != 0) )
				{
					if ( !reactBody )
					{
						a.contacts.fixedLimits |= BodyLimitFlags.bottom;
						a.setY( b.shape[0].aabbYMin - a.shape[0].getH() );
						if ( a.physic.vY > 0 )
							a.physic.vY = 0;
						return true;
					}
					else
					{
						return applyVertMobilesReact( a, b );
					}
				}
				
			case BodyLimitFlags.left:
				
				if ( (b.contacts.flags & BodyContactsFlags.platformRight != 0 ||
					b.contacts.flags & BodyContactsFlags.wall != 0) )
				{
					if ( !reactBody )
					{
						a.contacts.fixedLimits |= BodyLimitFlags.left;
						a.setX( b.shape[0].aabbXMax );
						if ( a.physic.vX < 0 )
							a.physic.vX = 0;
						return true;
					}
					else
					{
						return applyHorMobilesReact( b, a );
					}
				}
				
			case BodyLimitFlags.right:
				
				if ( (b.contacts.flags & BodyContactsFlags.platformLeft != 0 ||
					b.contacts.flags & BodyContactsFlags.wall != 0) )
				{
					if ( !reactBody )
					{
						a.contacts.fixedLimits |= BodyLimitFlags.right;
						a.setX( b.shape[0].aabbXMin - a.shape[0].getW() );
						if ( a.physic.vX > 0 )
							a.physic.vX = 0;
						return true;
					}
					else
					{
						return applyHorMobilesReact( a, b );
					}
				}
				
			default:
				
				return false;
				
		}
		return false;
	}
	
	function updatePosBody( a:Body, list:Array<Body>, space:ISpace, complexCol:Bool = false, num:Int = 0 )
	{
		list = (complexCol) ? filterDrivable(list) : filterUndrivable(list);
		
		if ( list.length < 1 || a.shape[0].getHitArea( list[0].shape[0] ) <= 0 || num > MAX_RECURSIVE )
			return;
		
		// calculate last position
		var b = list[0];
		
		if ( applyReact( a, b, complexCol ) )
		{
			list = space.hitTestActive( a );
			BodyContact.classBodiesByContactArea( a.shape[0], list );
			updatePosBody( a, list, space, complexCol, num + 1 );
		}
		else
		{
			list.shift();
			updatePosBody( a, list, space, complexCol, num + 1 );
		}
	}
	
	public inline function removeBody( body:Body ):Void
	{
		all.remove( body );
	}
	
}