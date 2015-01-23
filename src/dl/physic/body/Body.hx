package dl.physic.body ;
import dl.physic.body.ShapePoint;

@:enum
abstract BodyType(Int)
{
	/**
	* This body don't test the collision but the actives bodies tests the collision with this one
	*/
	var passive = 1;
	
	/**
	* This body test the collision with the passives bodies
	*/
	var active = 2;
	
	/**
	* You can jump from bottom over a platform
	*/
	var platform = 4;
	
	/**
	* You can't cross it
	*/
	var wall = 8;
	
	/**
	* You can climb it
	*/
	//var lader = 4;
	
	/**
	* Collision is activated, but not physic.
	* It's usable for life, ennemy, ammo...
	*/
	var item = 16;
	
	/**
	* Your solid reacts with passives bodies (platform, wall, ladder)
	*/
	var mover = 32;
	
	//public inline static var SOLID_TYPE_EATER:UInt = 32;
	
	inline function new( i:Int ) { this = i; }
	
	@:from
	public static function fromInt(i:Int):BodyType {
		return new BodyType(i);
	}
	
	@:to
	public function toUInt():Int {
		return this;
	}
}


/**
 * ...
 * @author Namide
 */
class Body
{
	/**
	* Delimit the shape of this body
	*/
	public var shape(default, default):Shape;
	
	/**
	* Other body in contact with this one
	*/
	public var contacts(default, null):BodyContact;

	public var type:BodyType;
	
	/*public var x(default, null):Float;
	public var y(default, null):Float;
	
	public var lx(default, null):Float;
	public var ly(default, null):Float;
	
	public var moved:Bool;*/
	//var _lastPosX:Float;
	//var _lastPosY:Float;
	
	//public var insomniac(default, default):Bool = false;
	
	public function new( shape:Shape ) 
	{
		type = 0 | BodyType.passive;
		//moved = false;
		this.shape = shape;
		this.contacts = new BodyContact( this );
	}
	
	public inline function updatePos( x:Float, y:Float, fix:Bool = true ) {
		shape.updateAABB(x, y, fix);
	}
	
	public inline function moved():Bool {
		return shape.moved;
	}
	
	public function toString() {
		return "[Body" + shape +"]";
	}
	
	
	
	
}