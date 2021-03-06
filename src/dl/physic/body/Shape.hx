package dl.physic.body;
import dl.physic.body.Shape.ShapeType;

@:enum
abstract ShapeType(Int)
{
	var point = 0;
	var rect = 1;
	var circle = 2;
	
	inline function new( i:Int ) { this = i; }
	
	@:from
	public static function fromInt(i:Int):ShapeType {
		return new ShapeType(i);
	}
	
	@:to
	public function toInt():Int {
		return this;
	}
}

/**
 * Form of the body.
 * 
 * @author Namide
 */
class Shape
{
	public var anchorX(default, default):Float;
	public var anchorY(default, default):Float;
	
	public var aabbXMin(default, null):Float;
	public var aabbXMax(default, null):Float;
	public var aabbYMin(default, null):Float;
	public var aabbYMax(default, null):Float;
	
	public var type(default, null):ShapeType;
	
	public function new()
	{
		anchorX = 0;
		anchorY = 0;
	}
	
	public function clone():Shape
	{
		anchorX = 0;
		anchorY = 0;
		
		var c = new Shape();
		c.aabbXMin = aabbXMin;
		c.aabbXMax = aabbXMax;
		c.aabbYMin = aabbYMin;
		c.aabbYMax = aabbYMax;
		
		return c;
	}
	
	public function updateAABB( x:Float, y:Float ) {
		aabbXMin = x + anchorX;
		aabbYMin = y + anchorY;
	}
	
	public inline function getHitArea( s:Shape ):Float {
		return _getHitArea( this, s );
	}
	
	static inline function _getHitArea( a:Shape, b:Shape ):Float
	{
		return (_min( a.aabbXMax, b.aabbXMax ) - _max( a.aabbXMin, b.aabbXMin )) * (_min( a.aabbYMax, b.aabbYMax ) - _max( a.aabbYMin, b.aabbYMin ));
	}
	
	static inline function _max( a : Float, b : Float ) {
		return a < b ? b : a;
	}
	
	static inline function _min( a : Float, b : Float ) {
		return a > b ? b : a;
	}
	
	
	public inline function getH() {
		return Shape._getH( this );
	}
	
	public inline function getW() {
		return Shape._getW( this );
	}
	
	static function _getW( a:Shape ):Float
	{
		if ( a.type == ShapeType.circle )
			return cast( a, ShapeCircle ).r * 2;
		
		else if ( a.type == ShapeType.rect )
			return cast( a, ShapeRect ).w;
		
		return 0;
	}
	
	static function _getH( a:Shape ):Float
	{
		if ( a.type == ShapeType.circle )
			return cast( a, ShapeCircle ).r * 2;
		
		else if ( a.type == ShapeType.rect )
			return cast( a, ShapeRect ).h;
		
		return 0;
	}
	
	public inline function hitTest( b:Shape ):Bool {
		return Shape._hitTest( this, b );
	}
	
	static function _hitTest( a:Shape, b:Shape ):Bool
	{
		if ( !hitTestAABB( a, b ) ) {
			return false;
		}
		else if ( 	a.type == ShapeType.circle &&
					b.type == ShapeType.circle ) {
			return hitTestCircles( cast( a, ShapeCircle ), cast( b, ShapeCircle ) );
		}
		else if ( a.type == ShapeType.circle &&
				  b.type == ShapeType.point ) {
			return hitTestPointCircle( cast( b, ShapePoint ), cast( a, ShapeCircle ) );
		}
		else if ( a.type == ShapeType.point &&
				  b.type == ShapeType.circle ) {
			return hitTestPointCircle( cast( a, ShapePoint ), cast( b, ShapeCircle ) );
		}
		
		return true;
	}
	
	static inline function hitTestAABB( a:Shape, b:Shape ):Bool
	{
		return (	a.aabbXMin <= b.aabbXMax &&
					a.aabbXMax >= b.aabbXMin &&
					a.aabbYMin <= b.aabbYMax &&
					a.aabbYMax >= b.aabbYMin	);
	}
	
	static function hitTestCircles( a:ShapeCircle, b:ShapeCircle ):Bool
	{
		var d1:Float = b.aabbXMin + b.r - (a.aabbXMin + a.r);
		var d2:Float = b.aabbYMin + b.r - (a.aabbYMin + a.r);
		var d3:Float = a.r + b.r;
		
		return ( d1 * d1 - d2 * d2 <= d3 * d3 );
	}
	
	static function hitTestPointCircle( a:ShapePoint, b:ShapeCircle ):Bool
	{
		var d1:Float = b.aabbXMin + b.r - a.aabbXMin;
		var d2:Float = b.aabbYMin + b.r - a.aabbYMin;
		
		return ( d1 * d1 - d2 * d2 <= b.r * b.r );
	}
	
	#if (debug)
		public function toString()
		{
			var t = (type == ShapeType.point)?"point":(type == ShapeType.circle)?"circle":(type == ShapeType.rect)?"rect":"";
			return "[Shape " + t + " w:" + (aabbXMax - aabbXMin) + " h:" + (aabbYMax - aabbYMin) + "]";
		}
	#end
}