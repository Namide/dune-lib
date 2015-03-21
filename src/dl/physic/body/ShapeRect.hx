package dl.physic.body ;
import dl.physic.body.Shape.ShapeType;

/**
 * ...
 * @author Namide
 */
class ShapeRect extends Shape
{
	public var w(default, default):Float;
	public var h(default, default):Float;
	
	public function new( w:Float, h:Float ) 
	{
		super();
		type = ShapeType.rect;
		
		this.w = w;
		this.h = h;
	}
	
	public override function clone():ShapeRect
	{
		var c = new ShapeRect( w, h );
		c.aabbXMin = aabbXMin;
		c.aabbXMax = aabbXMax;
		c.aabbYMin = aabbYMin;
		c.aabbYMax = aabbYMax;
		
		c.anchorX = anchorX;
		c.anchorY = anchorY;
		
		return c;
	}
	
	override public function updateAABB( x:Float, y:Float )
	{
		aabbXMin = x + anchorX;
		aabbXMax = x + w + anchorX;
		aabbYMin = y + anchorY;
		aabbYMax = y + h + anchorY;
	}
}