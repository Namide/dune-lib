package dl.physic.body ;
import dl.physic.body.Shape.ShapeType;


/**
 * ...
 * @author Namide
 */
class ShapePoint extends Shape
{
	public function new() 
	{
		super();
		type = ShapeType.point;
	}
	
	public override function clone():ShapePoint
	{
		var c = new ShapePoint();
		c.aabbXMin = aabbXMin;
		c.aabbXMax = aabbXMax;
		c.aabbYMin = aabbYMin;
		c.aabbYMax = aabbYMax;
		return c;
	}
	
	override public function updateAABB( x:Float, y:Float )
	{
		aabbXMin =
		aabbXMax = x;
		aabbYMin =
		aabbYMax = y;
	}	
}