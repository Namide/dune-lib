package dl.physic.space;
import dl.physic.body.Body;

/**
 * ...
 * @author Namide
 */
class SpaceSimple
{
	public var all(default, null):List<Body>;
	
	var _active(default, null):List<Body>;
	var _passive(default, null):List<Body>;
	
	public function new() 
	{
		_active = new List<Body>();
		_passive = new List<Body>();
		all = new List<Body>();
	}
	
	public function hitTest():List<Body>
	{
		
		var affected:List<Body> = new List<Body>();
			
		for ( b in _active )
		{
			var af:Bool = false;
			b.contacts.clear();
			b.updateAABB();
			//b.shape.updateAABB( b.entity.transform );
			
			for ( b2 in _passive )
			{
				//trace( b, b2 );
				
				if ( b2.physicType & BodyPhysicFlags.fix == 0 )
					b2.updateAABB();
				
				if ( 	b.shape.hitTest( b2.shape ) /*&&
						b.contacts.list.indexOf( b2 ) < 0*/ )
				{
					b.contacts.push( b2 );
					if ( !af )
					{
						affected.push( b );
						af = true;
					}
				}
			}
		}
		
		return affected;
	}
	
	/**
	 * Add a body in this system
	 * 
	 * @param	body			Body to add in the system
	 */
	public function addBody( body:Body ):Void
	{
		if ( body.colliderType & BodyColliderFlags.passive == BodyColliderFlags.passive )
		{
			if ( body.colliderType & BodyPhysicFlags.fix == 0 )
				body.updateAABB();
			
			_passive.push( body );
		}
		
		if ( body.colliderType & BodyColliderFlags.active == BodyColliderFlags.active )
			_active.push( body );
		
		all.push( body );
	}
	
	/**
	 * Remove the body of the system
	 * 
	 * @param	body			Body to add
	 */
	public function removeBody( body:Body ):Void
	{
		if ( body.colliderType & BodyColliderFlags.passive == BodyColliderFlags.passive )
			_passive.remove( body );
		
		if ( body.colliderType & BodyColliderFlags.active == BodyColliderFlags.active )
			_active.remove( body );
		
		all.remove( body );
	}
	
}