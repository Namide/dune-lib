package dl.physic.body ;
import dl.physic.body.ShapePoint;
import dl.physic.contact.BodyContact;
import dl.physic.move.BodyPhysic;

/**
 * ...
 * @author Namide
 */
class Body
{
	/**
	 * Historic of positioning (number of memory). Minimal number is 2.
	 * If you add intermediates positionning you must increment SHAPE_PRINT_NUM.
	 * In example for multiplayer manipulation.
	 */
	public static inline var SHAPE_PRINT_NUM:Int = 5;
	
	/**
	 * Optional data
	 */
	public var name:String;
	
	/**
	* Delimit the shape of this body.
	* shape[0] is the current shape.
	* shape[1] is the last shape...
	*/
	public var shape(default, default):Array<Shape>;
	
	/**
	 * Other body in contact with this one
	 */
	public var contacts(default, null):BodyContact;
	
	/**
	 * Physic datas (velocity, mass...).
	 * Usable to calculate physic moves.
	 */
	public var physic(default, null):BodyPhysic;
	
	/**
	 * Position in X-axis in pixel
	 */
	public var x(default, null):Float;
	
	/**
	 * Position in Y-axis in pixel
	 */
	public var y(default, null):Float;
	
	/**
	 * True if the body has moved since the last frame.
	 */
	public var moved(default, null):Bool;
	
	public function new( shape:Shape, x:Float = 0, y:Float = 0 ) 
	{
		this.shape = [shape];
		this.contacts = new BodyContact( this );
		
		this.x = x;
		this.y = y;
		shape.updateAABB( x, y );
		
		for ( i in 0...(SHAPE_PRINT_NUM-1) )
			this.shape.push( shape.clone() );
		
		moved = true;
	}
	
	/**
	 * Edits the position in pixel
	 * 
	 * @param	x		New X-axis position in pixel
	 * @param	y		New Y-axis position in pixel
	 */
	public function setPos( x:Float, y:Float )
	{
		#if (debug)
			
			if ( contacts != null &&
				 contacts.flags & BodyContactsFlags.fix != 0 )
				throw "Can't move a fix body!";
			
		#end
		
		if (x != this.x || y != this.y)
		{
			this.x = x;
			this.y = y;
			moved = true;
		}
	}
	
	/**
	 * Edits the X-axis in pixel
	 * 
	 * @param	x	New X-axis position in pixel
	 */
	public function setX( x:Float )
	{
		#if (debug)
			
			if ( contacts != null &&
				 contacts.flags & BodyContactsFlags.fix != 0 )
				throw "Can't move a fix body!";
			
		#end
		
		var m = x != this.x;
		if ( m )
		{
			this.x = x;
			moved = true;
		}
	}
	
	/**
	 * Edits the Y-axis in pixel
	 * 
	 * @param	y	New Y-axis position in pixel
	 */
	public function setY( y:Float )
	{
		#if (debug)
			
			if ( contacts != null &&
				 contacts.flags & BodyContactsFlags.fix != 0 )
				throw "Can't move a fix body!";
			
		#end
		
		var m = y != this.y;
		if ( m )
		{
			this.y = y;
			moved = true;
		}
	}
	
	/**
	 * Add numbers to actual position.
	 * 
	 * @param	x		Number to add to the X-axis position in pixel
	 * @param	y		Number to add to the Y-axis position in pixel
	 */
	public function addPos( x:Float, y:Float )
	{
		#if (debug)
			
			if ( contacts != null &&
				 contacts.flags & BodyContactsFlags.fix != 0 )
				throw "Can't move a fix body!";
			
		#end
		
		if ( x != 0 || y != 0 )
		{
			this.x += x;
			this.y += y;
			moved = true;
		}
	}
	
	/**
	 * Update the bounding box of this body.
	 * 
	 * @param	updatePrint		Force the saves of the datas
	 */
	public function updateAABB( updatePrint:Bool = true )
	{
		#if (debug)
		
			if ( contacts != null &&
				 contacts.flags & BodyContactsFlags.fix != 0 )
				throw "Can't updateAABB() a fix body!";
			
		#end
		
		if ( updatePrint )
		{
			var t = shape.pop();
			shape.unshift( t );
			moved = false;
		}
		
		shape[0].updateAABB( x, y );
	}
	
	/**
	 * Initialize the BodyContacts property.
	 * 
	 * @param	flags		List of flags of the BodyContacts
	 */
	public inline function addBodyContact( flags:BodyContactsFlags = 0 ):Void
	{
		if ( contacts == null )
			contacts = new BodyContact(this);
		
		contacts.flags = flags;
	}
	
	/**
	 * Initialize the BodyPhysic property.
	 * 
	 * @param	flags		List of flags of the BodyPhysic
	 */
	public inline function addBodyPhysic( flags:BodyPhysicFlags = BodyPhysicFlags.none ):Void
	{
		if ( physic == null )
			physic = new BodyPhysic(this);
		
		physic.flags = flags;
	}
	
	#if (debug)
		public function toString() {
			if ( name != null )
				return "[Body "+name+" x:" + x + " y:" + y + " ]";
			return "[Body x:" + x + " y:" + y + " " + shape +"]";
		}
	#end
}