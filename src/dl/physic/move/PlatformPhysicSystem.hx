package dl.physic.move;
import dl.physic.body.Body;
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
		
		if ( body.physic != null /*&&
			 ( body.physic.flags & BodyPhysicFlags.dependant != 0 ||
			   body.physic.flags & BodyPhysicFlags.gravity != 0 ||
			   body.physic.flags & BodyPhysicFlags.velocity != 0 )*/ )
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
			updatePosBody( b, /*b.contacts.list*/ b.contacts.list, space );
			//trace( b.contacts.fixedLimits );
		}
		
		for ( b in physDep )
		{
			updatePosBody( b, /*b.contacts.list*/ b.contacts.list, space, true );
		}
	}
	
	inline function filterDrivable( list:Array<Body> )
	{
		return list.filter(function(b:Body) { return b.contacts.flags & BodyContactsFlags.drivable != 0; } );
	}
	
	inline function filterUndrivable( list:Array<Body> )
	{
		return list.filter(function(b:Body) { return b.contacts.flags & BodyContactsFlags.drivable == 0; } );
	}
	
	function getPos( a:Body, b:Body ):BodyLimitFlags
	{
		var ba0 = ( a.print != null ) ? a.print : a.shape;
		var bb0 = ( b.print != null ) ? b.print : b.shape;
		
		var pos:BodyLimitFlags = 0;
		var corner:Int = 0;
		if ( ba0.aabbXMin >= bb0.aabbXMax ) { pos |= BodyLimitFlags.left; corner++; }
		if ( ba0.aabbXMax <= bb0.aabbXMin ) { pos |= BodyLimitFlags.right; corner++; }
		if ( ba0.aabbYMin >= bb0.aabbYMax ) { pos |= BodyLimitFlags.top; corner++; }
		if ( ba0.aabbYMax <= bb0.aabbYMin ) { pos |= BodyLimitFlags.bottom; corner++; }
		
		// determine the contact border by the previous position
		if ( corner > 1 )
		{
			var ba1 = a.shape;
			var bb1 = b.shape;
			
			var Vx = ba1.aabbXMin - ( ( a.print != null ) ? a.print.aabbXMin : 0 );
			var Vy = ba1.aabbYMin - ( ( a.print != null ) ? a.print.aabbYMin : 0 );
			
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
					{
						pos = BodyLimitFlags.right;
					}
					else
					{
						pos = BodyLimitFlags.bottom;
					}
				}
				else if ( pos & BodyLimitFlags.left != 0 )
				{
					var Aw = bb1.aabbXMax - ba1.aabbXMin;
					if ( Vx * Ah > Vy * Aw )
					{
						pos = BodyLimitFlags.left;
					}
					else
					{
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
					if ( Vx * Ah > Vy * Aw )
					{
						pos = BodyLimitFlags.left;
					}
					else
					{
						pos = BodyLimitFlags.top;
					}
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
		
		var y = (bottom.shape.aabbYMin - top.shape.aabbYMax) * m + top.shape.aabbYMax;
		bottom.setY( y );
		top.setY( y - top.shape.getH() );
		
		if ( top.physic.vY > 0 )
			top.physic.vX = 0;
			
		if ( bottom.physic.vY < 0 )
			bottom.physic.vX = 0;
		
		return true;
	}
	
	function applyHorMobilesReact( left:Body, right:Body )
	{
		var m = 0.5;
		var lefLimit = left.contacts.fixedLimits & BodyLimitFlags.left != 0;
		var rigLimit = right.contacts.fixedLimits & BodyLimitFlags.right != 0;
		
		left.contacts.fixedLimits |= BodyLimitFlags.right;
		right.contacts.fixedLimits |= BodyLimitFlags.left;
		
		trace(left, right);
		trace(lefLimit, rigLimit);
		
		if ( lefLimit && rigLimit )
			return false;
			
		if ( lefLimit )
			m = 0;
		else if ( rigLimit )
			m = 1;
		else if ( left.physic != null && right.physic != null )
			m = left.physic.mass / (right.physic.mass + left.physic.mass);
		
		var x = (right.shape.aabbXMin - left.shape.aabbXMax) * m + left.shape.aabbXMax;
		right.setX( x );
		left.setX( x - left.shape.getW() );
		
		if ( left.physic.vY > 0 )
			left.physic.vX = 0;
			
		if ( right.physic.vY < 0 )
			right.physic.vX = 0;
		
		return true;
	}
	
	function applyReact( a:Body, b:Body,/* pos:BodyLimitFlags,*/ reactBody:Bool ):Bool
	{
		//throw "to do (react body)";
		// TODO
		// b.contacts.fixedLimits & BodyLimitFlags.bottom != 0
		
		var pos = getPos( a, b );
		
		//if ( reactBody )
		//	trace( b.contacts.fixedLimits );
		
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
						a.setY( b.shape.aabbYMax );
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
						a.setY( b.shape.aabbYMin - a.shape.getH() );
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
						a.setX( b.shape.aabbXMax );
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
						a.setX( b.shape.aabbXMin - a.shape.getW() );
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
				/*#if debug
					trace("no contact direction?");
				#end*/
		}
		return false;
	}
	
	function updatePosBody( a:Body, list:Array<Body>, space:ISpace, complexCol:Bool = false, num:Int = 0 )
	{
		//trace( num, list.length, a.shape.getHitArea( list[0].shape ) );
		
		/*if ( complexCol )
			trace( list.length );
		*/
			
		list = (complexCol) ? filterDrivable(list) : filterUndrivable(list);
		
		
		if ( list.length < 1 || a.shape.getHitArea( list[0].shape ) <= 0 || num > MAX_RECURSIVE )
			return;
		
		// calculate last position
		var b = list[0];
		
		if ( applyReact( a, b, complexCol ) )
		{
			list = space.hitTestActive( a );
			BodyContact.classBodiesByContactArea( a.shape, list );
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