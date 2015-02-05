package dl.socket.server ;

/**
 * ...
 * @author Namide
 */
class SockRoom
{
	public var name:String;
	public var pass:String;
	public var clients:Array<SockServerUser>;
	
	public function new(name:String, pass:String = null)
	{
		this.name = name;
		this.pass = (pass != null) ? pass : "";
		clients = [];
	}
}