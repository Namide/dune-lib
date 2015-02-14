package dl.utils;

/**
 * ...
 * @author Namide
 */
class Obj
{

	public function new() {
		throw "static class!";
	}
	
	/**
	 * deep copy of anything
	 */
	public static function deepCopy<T>( v:T ):T
	{
		// simple type
		if (!Reflect.isObject(v)) {
			return v;
		}
		// array
		else if( Std.is( v, Array ) ) {
			var r = Type.createInstance(Type.getClass(v), []);
			
			untyped {
				for( ii in 0...v.length )
					r.push(deepCopy(v[ii]));
			}
			
			return r;
		}
		// anonymous object
		else if( Type.getClass(v) == null ) {
			var obj : Dynamic = { };
			
			for( ff in Reflect.fields(v) )
				Reflect.setField(obj, ff, deepCopy(Reflect.field(v, ff)));
			
			return obj;
		}
		// class
		else
		{
			var obj = Type.createEmptyInstance(Type.getClass(v));
			
			for( ff in Reflect.fields(v) )
				Reflect.setField(obj, ff, deepCopy(Reflect.field(v, ff)));
			
			return obj;
		}
		
		return null;
	} 
	
}