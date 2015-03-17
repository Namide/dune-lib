package dl.physic.move;
import dl.physic.body.Body;

@:enum
abstract BodyPhysicFlags(Int)
{
	/**
	 * Not active physic (like an IA) but an other body can interract with this 
	 */
	var none = 0;
	
	/**
	* Your solid reacts with passives bodies (platform, wall, ladder)
	*/
	var dependant = 1;
	
	/**
	 * Physic engine apply the velocity
	 */
	var velocity = 2;
	
	/**
	 * Physic engine apply the gravity
	 */
	var gravity = 4;
	
	inline function new( i:Int ) { this = i; }
	
	@:from
	public static function fromInt(i:Int):BodyPhysicFlags {
		return new BodyPhysicFlags(i);
	}
	
	@:to
	public function toInt():Int {
		return this;
	}
	
	@:op(A & B)
	public function and(b: BodyPhysicFlags): BodyPhysicFlags
	{
		return new BodyPhysicFlags( this & b.toInt() );
	}
	
	@:op(A | B)
	public function or(b: BodyPhysicFlags): BodyPhysicFlags
	{
		return new BodyPhysicFlags( this | b.toInt() );
	}
}

/**
 * ...
 * @author Namide
 */
class BodyPhysic
{
	var _parent:Body;
	
	public var vX:Float;
	public var vY:Float;
	public var flags:BodyPhysicFlags;
	
	public var mass:Float;
	
	public function new( parent:Body ) 
	{
		_parent = parent;
		vX = 0;
		vY = 0;
		mass = 1;
	}
}