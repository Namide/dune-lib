package dl.physic.contact ;
import dl.physic.body.Body;
import dl.physic.contact.BodyContact.BodyContactsFlags;
import dl.physic.contact.BodyContact.BodyContactState;

/**
 * ...
 * @author Namide
 */
class SpaceSimple implements ISpace
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
	
	public function hitTestActive( b:Body ):Array<Body>
	{
		var c = b.contacts;
		c.clear();
		
		if ( b.contacts.flags & BodyContactsFlags.fix == 0 )
			b.updateAABB(false);
		
		for ( b2 in _passive )
			if ( b.shape.hitTest( b2.shape ) )
				c.push( b2 );

		c.state = BodyContactState.contacts;
		return b.contacts.list;
	}
	
	public function hitTest():List<Body>
	{
		
		var affected:List<Body> = new List<Body>();
		
		for ( b in _active )
		{
			var af:Bool = false;
			var c = b.contacts;
			c.clear();
			b.updateAABB();
			
			for ( b2 in _passive )
			{
				if ( b2.contacts.flags & BodyContactsFlags.fix == 0 )
					b2.updateAABB();
				
				if ( 	b.shape.hitTest( b2.shape ) /*&&
						b.contacts.list.indexOf( b2 ) < 0*/ )
				{
					c.push( b2 );
					if ( !af )
					{
						affected.push( b );
						af = true;
					}
				}
			}
			
			c.state = BodyContactState.contacts;
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
		if ( body.contacts == null )
			body.addBodyContact( 0 );
		
		if ( body.contacts.flags & BodyContactsFlags.passive != 0 )
		{
			if ( body.contacts.flags & BodyContactsFlags.fix == 0 )
				body.updateAABB();
			
			_passive.push( body );
		}
		
		if ( body.contacts.flags & BodyContactsFlags.active != 0 )
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
		if ( body.contacts.flags & BodyContactsFlags.passive != 0 )
			_passive.remove( body );
		
		if ( body.contacts.flags & BodyContactsFlags.active != 0 )
			_active.remove( body );
		
		all.remove( body );
	}
	
}