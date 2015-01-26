package dl.physic.body ;
import dl.physic.body.Body.BodyColliderFlags;

/**
 * ...
 * @author Namide
 */
class BodyContact
{
	public var parent:Body;
	public var list(default, default):Array<Body>;
	
	public function new( p:Body ) 
	{
		parent = p;
		list = [];
	}
	
	public inline function hasType( type:BodyColliderFlags ):Bool {
		return hasTypeInA( type, list );
	}
	
	public inline function getByType( type:BodyColliderFlags ):Array<Body> {
		return list.filter( function( cb:Body ):Bool { return cb.colliderType & type == type; });
	}
	
	public inline function push( body:Body ):Void { list.push( body ); }
	public inline function length():UInt { return list.length; }
	
	public inline function clear() {
		untyped list.length = 0;
	}

	inline function hasTypeInA( type:BodyColliderFlags, a:Array<Body> ):Bool {
		return Lambda.exists( a, function(cp:Body):Bool { return cp.colliderType & type == type; });
	}
}