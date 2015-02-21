package dl.utils;

/**
 * ...
 * @author Namide
 */
class Name
{

	public function new() 
	{
		throw "Static class";
	}
	
	public static function getRandName( charMin:Int, charMax:Int ):String
	{
		var v = "aeiouy";
		var c = "bcdfghjklmnpqrstvwxz";
		
		var n = "";
		
		//var s = Math.round( Math.random() * Math.floor((charMax - charMin) / 3) + Math.ceil( (charMin) / 3) );
		var l = Math.round( Math.random() * Math.floor(charMax - charMin) + charMin );
		
		// 2 or 3 by syl
		while ( n.length < l )
		{
			var r = Math.floor(Math.random() * c.length);
			n += c.charAt( r );
			
			if ( n.length < 2 )
				n = n.toUpperCase();
				
			r = Math.floor(Math.random() * v.length);
			n += v.charAt( r );
			if ( Math.random() < 0.3 )
			{
				r = Math.floor(Math.random() * c.length);
				n += c.charAt( r );
			}
		}
		
		if ( n.length > l )
			n = n.substring( 0, l );
		
		return n;
	}
	
}