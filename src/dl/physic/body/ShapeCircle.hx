package dl.physic.body;
import dl.physic.body.Shape;
import dl.physic.body.Shape.ShapeType;

/**
 * ...
 * @author Namide
 */
class ShapeCircle extends Shape
{
	public var r(default, default):Float;
	
	public function new() 
	{
		super();
		type = ShapeType.circle;
		r = 0.0;
	}
	
	public override function updateAABB( x:Float, y:Float/*, fix:Bool*/ )
	{
		//move( x, y, fix );
		
		var rd = r + r;
		aabbXMin = x;
		aabbXMax = x + rd;
		aabbYMin = x;
		aabbYMax = y + rd;
	}
	
	public override function clone():ShapeCircle 
	{
		var c = new ShapeCircle();
		c.type = type;
		c.aabbXMin = aabbXMin;
		c.aabbXMax = aabbXMax;
		c.aabbYMin = aabbYMin;
		c.aabbYMax = aabbYMax;
		c.r = r;
		return c;
	}
}