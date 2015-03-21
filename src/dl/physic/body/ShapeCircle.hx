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
	
	public override function updateAABB( x:Float, y:Float )
	{
		var rd = r + r;
		aabbXMin = x + anchorX;
		aabbXMax = x + rd + anchorX;
		aabbYMin = y + anchorY;
		aabbYMax = y + rd + anchorY;
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
		
		c.anchorX = anchorX;
		c.anchorY = anchorY;
		
		return c;
	}
}