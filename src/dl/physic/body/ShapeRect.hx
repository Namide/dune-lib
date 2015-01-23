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
	
	override public function updateAABB( x:Float, y:Float, fix:Bool )
	{
		move( x, y, fix );
		
		aabbXMin = x;
		aabbXMax = x + w;
		aabbYMin = y;
		aabbYMax = y + h;
	}
}