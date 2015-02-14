package dl.utils ;

/**
 * ...
 * @author Namide
 */
class Calcul
{
	inline function new() {
		throw "static class";
	}
	
	public inline static function exposant( n:Float, pow:Float = 2 ):Float {
		return Math.log( n ) / Math.log( pow );
	}
	
	public inline static function exposantInt( n:Float, pow:Float = 2 ):Int {
		return Math.round( Math.log( n ) / Math.log( pow ) );
	}
	
	public inline static function nextPow( n:Float, pow:Float = 2 ):Int {
		return Math.round( Math.pow( pow, Math.ceil( exposant(n, pow) ) ) );
	}
	
}