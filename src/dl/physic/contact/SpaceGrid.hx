package dl.physic.contact ;
import dl.utils.Calcul;
import dl.physic.body.Body;
import dl.physic.body.ShapePoint;
import dl.physic.contact.BodyContact.BodyContactsFlags;
import dl.physic.contact.BodyContact.BodyContactState;
import dl.physic.contact.SpaceGrid.Node;

class Grid
{
	public var minTileX(default, null):Int;
	public var minTileY(default, null):Int;
	public var maxTileX(default, null):Int;
	public var maxTileY(default, null):Int;
	
	var _grid:Array<Array<Array<Node>>>;
	
	public var outdated:Bool;
	
	public function new( minTileX:Int, minTileY:Int, maxTileX:Int, maxTileY:Int )
	{
		outdated = false;
		
		this.minTileX = minTileX;
		this.minTileY = minTileY;
		this.maxTileX = maxTileX;
		this.maxTileY = maxTileY;
		
		_grid = [];
		var x:Int = -1;
		for ( i in minTileX...maxTileX )
		{
			_grid[++x] = [];
			var y:Int = -1;
			for ( j in minTileY...maxTileY )
				_grid[x][++y] = [];
		}
	}
	
	public inline function remove( i:Int, j:Int, node:Node ):Void
	{
		if ( 	i >= minTileX && i < maxTileX &&
				j >= minTileY && j < maxTileY )
		{
			_grid[i-minTileX][j-minTileY].remove( node );
		}
	}
	
	public inline function push( i:Int, j:Int, node:Node ):Void
	{
		if ( 	i >= minTileX && i < maxTileX &&
				j >= minTileY && j < maxTileY )
		{
			_grid[i-minTileX][j-minTileY].push( node );
		}
	}

	public inline function getNodes( i:Int, j:Int ):Array<Node>
	{
		return ( i >= minTileX && i < maxTileX && j >= minTileY && j < maxTileY ) ? _grid[i - minTileX][j - minTileY] : [];
	}
	
	public inline function getContacts( n:Node ):Array<Body>
	{
		var c:Array<Body> = [n.body];
		
		for ( i in n.minTileX...n.maxTileX )
			for ( j in n.minTileY...n.maxTileY )
				for ( n2 in getNodes( i, j ) )
					if ( !Lambda.has( c, n2.body ) && n.body.shape.hitTest( n2.body.shape ) )
						c.push( n2.body );
		
		c.remove( n.body );
		return c;
	}
	
	public inline function dispose():Void
	{
		_grid = null;
	}
	
	#if(debug)
	public function toString()
	{
		var s = "x:" + this.minTileX + " y:" + minTileY + " w:" + (maxTileX - minTileX) + " h:" + (maxTileY - minTileY);
		
		var colLength = _grid.length;
		var linLength = (_grid.length > 0 && _grid[0].length > 0) ? _grid[0].length : 0;
		
		for ( i in 0...linLength )
		{
			s += "\n|";
			for ( j in 0...colLength )
			{
				var le = _grid[j][i].length;
				
				if ( le < 10 )
					s += " " + le + " |";
				else if ( le < 100 )
					s += " " +  le + "|";
				else
					s += "" + le + "|";
			}
		}
		return s;
	}
	#end
}

class Node
{
	public var body(default, null):Body;
	
	public var minTileX(default, default):Int;
	public var minTileY(default, default):Int;
	public var maxTileX(default, default):Int;
	public var maxTileY(default, default):Int;
	
	public var inGrid:Bool;
	
	public function new( body:Body )
	{
		this.body = body;
		inGrid = body.contacts.flags & BodyContactsFlags.passive != 0;
	}
	
	public function init( pitchExpX:Int, pitchExpY:Int, grid:Grid )
	{
		minTileX = -1;
		minTileY = -1;
		maxTileX = -1;
		maxTileY = -1;
		
		refresh( pitchExpX, pitchExpY, grid );
	}
	
	public inline function removeFromGrid( grid:Grid )
	{
		if ( inGrid )
			for ( i in minTileX...maxTileX )
				for ( j in minTileY...maxTileY )
					grid.remove( i, j, this );
	}
	
	public function refresh( pitchExpX:Int, pitchExpY:Int, grid:Grid, updatePrint:Bool = true ):Void
	{
		if ( body.contacts.flags & BodyContactsFlags.fix == 0 )
			body.updateAABB(updatePrint);
		
		var nXMin:Int = (Math.floor(body.shape.aabbXMin) >> pitchExpX);
		var nYMin:Int = (Math.floor(body.shape.aabbYMin) >> pitchExpY);
		var nXMax:Int = (Math.ceil(body.shape.aabbXMax) >> pitchExpX) + 1;
		var nYMax:Int = (Math.ceil(body.shape.aabbYMax) >> pitchExpY) + 1;
		
		if ( 	nXMin != minTileX ||
				nYMin != minTileY ||
				nXMax != maxTileX ||
				nYMax != maxTileY )
		{
			
			if ( inGrid )
			{
				for ( i in minTileX...maxTileX )
					for ( j in minTileY...maxTileY )
						grid.remove( i, j, this );
				
				for ( i in nXMin...nXMax )
					for ( j in nYMin...nYMax )
						grid.push( i, j, this );
			}
			
			minTileX = nXMin;
			minTileY = nYMin;
			maxTileX = nXMax;
			maxTileY = nYMax;
		}
	}
	
	#if(debug)
	public function toString()
	{
		return "[Node x:" + minTileX + " y:" + minTileY + " w:" + (maxTileX - minTileX) + " h:" + (maxTileY - minTileY) + " ]";
	}
	#end
}

/**
 * ...
 * @author Namide
 */
class SpaceGrid implements ISpace
{
	public var all(default, null):Array<Body>;
	
	var _active(default, null):Array<Node>;
	var _passive(default, null):Array<Node>;
	var _passiveFixed(default, null):Array<Node>;
	
	var _pitchX:Int;
	var _pitchY:Int;
	var _grid:Grid;
	
	var _pitchXExp:Int;
	var _pitchYExp:Int;
	
	var autoLimits:Bool;
	var xMin:Int;
	var xMax:Int;
	var yMin:Int;
	var yMax:Int;
	
	public function new( tileW:Int = 64, tileH:Int = 64, xMin:Int = null, xMax:Int = null, yMin:Int = null, yMax:Int = null ) 
	{
		autoLimits = ( xMin == null || xMax == null || yMin == null || yMax == null );
		
		_pitchX = Calcul.nextPow( tileW );
		_pitchY = Calcul.nextPow( tileH );
		_pitchXExp = Calcul.exposantInt( _pitchX );
		_pitchYExp = Calcul.exposantInt( _pitchY );
		
		this.xMin = (xMin == null) ? 0 : (Math.floor(xMin / _pitchX) * _pitchX);
		this.xMax = (xMax == null) ? 0 : (Math.ceil(xMax / _pitchX) * _pitchX);
		this.yMin = (yMin == null) ? 0 : (Math.floor(yMin / _pitchY) * _pitchY);
		this.yMax = (yMax == null) ? 0 : (Math.ceil(yMax / _pitchY) * _pitchY);
		
		_active = [];
		_passive = [];
		_passiveFixed = [];
		all = [];
		
		init();
	}
	
	function init()
	{
		if ( _grid != null )
			_grid.dispose();
		
		_grid = new Grid( 	xMin >> _pitchXExp,
							yMin >> _pitchYExp,
							xMax >> _pitchXExp,
							yMax >> _pitchYExp );
		
		for ( node in _passive )
			node.init( _pitchXExp, _pitchYExp, _grid );
			
		for ( node in _passiveFixed )
			node.init( _pitchXExp, _pitchYExp, _grid );
		
		for ( node in _active )
			node.init( _pitchXExp, _pitchYExp, _grid );
	}
	
	public function hitTestActive( b:Body ):Array<Body>
	{
		var n = Lambda.find( _active, function( n:Node ) { return n.body == b; } );
		
		if ( n == null )
			[];
		
		//var c = b.contacts;
		//c.clear();
		n.refresh( _pitchXExp, _pitchYExp, _grid, false );
		//c.change( _grid.getContacts( n ) );
		//c.state = BodyContactState.contacts;
		return _grid.getContacts( n );//b.contacts.list;
	}
	
	public function hitTest():List<Body>
	{
		var affected:List<Body> = new List<Body>();
		
		if ( _grid.outdated )
			init();
		
		for ( node in _passive )
			node.refresh( _pitchXExp, _pitchYExp, _grid );
		
		for ( nodeA in _active )
		{
			var b:Body = nodeA.body;
			var isAffected:Bool = false;
			var c = b.contacts;
			c.clear();
			
			nodeA.refresh( _pitchXExp, _pitchYExp, _grid );
			var contacts:Array<Body> = _grid.getContacts( nodeA );
			
			if ( contacts.length > 0 )
			{
				c.change( contacts );
				affected.push( b );
			}
			
			c.state = BodyContactState.contacts;
		}
		
		return affected;
	}
	
	/**
	 * Add a body in this system
	 * 
	 * @param	body			Body to add in the system
	 */
	public function addBody( body:Body ):Void
	{
		if ( all.indexOf( body ) > 0 )
			removeBody( body );
		
		if ( body.contacts == null )
			body.addBodyContact( 0 );
		
		var node:Node = new Node( body );
		node.init( _pitchXExp, _pitchYExp, _grid );
		
		if ( autoLimits )
		{
			var sh = body.shape;
			if ( sh.aabbXMin < xMin ) {
				xMin = Math.floor(sh.aabbXMin / _pitchX) * _pitchX;
				_grid.outdated = true;
			}
			
			if ( sh.aabbYMin < yMin ) {
				yMin = Math.floor(sh.aabbYMin / _pitchY) * _pitchY;
				_grid.outdated = true;
			}
				
			if ( sh.aabbXMax > xMax ) {
				xMax = Math.ceil(sh.aabbXMax / _pitchX) * _pitchX;
				_grid.outdated = true;
			}
				
			if ( sh.aabbYMax > yMax ) {
				yMax = Math.ceil(sh.aabbYMax / _pitchY) * _pitchY;
				_grid.outdated = true;
			}
		}
		
		if ( body.contacts.flags & BodyContactsFlags.passive != 0 )
		{
			if ( body.contacts.flags & BodyContactsFlags.fix != 0 )
				_passiveFixed.push( node );
			else
				_passive.push( node );
		}
		
		if ( body.contacts.flags & BodyContactsFlags.active != 0 )
			_active.push( node );
		
		all.push( body );
	}
	
	/**
	 * Remove the body of the system
	 * 
	 * @param	body			Body to add
	 * @param	rebuildGrid		Clear the grid and buid it
	 */
	public function removeBody( body:Body ):Void
	{
		if ( body.contacts.flags & BodyContactsFlags.passive != 0 )
		{
			if ( body.contacts.flags & BodyContactsFlags.fix != 0 )
			{
				var node:Node = Lambda.find( _passiveFixed, function( n:Node ):Bool { return n.body == body; } );
				node.removeFromGrid( _grid );
				_passiveFixed.remove( node );
			}
			else
			{
				var node:Node = Lambda.find( _passive, function( n:Node ):Bool { return n.body == body; } );
				node.removeFromGrid( _grid );
				_passive.remove( node );
			}
		}
		else
		{
			var node:Node = Lambda.find( _active, function( n:Node ):Bool { return n.body == body; } );
			node.removeFromGrid( _grid );
			_active.remove( node );
		}
		all.remove( body );
	}
	
	#if(debug)
	public function toString():String
	{
		return "[SpaceGrid x:"+xMin+" y:"+yMin+" w:"+xMax+" h:"+yMax+"]";
	}
	#end
}