package dl.socket.server ;
import dl.socket.SockMsg.Role;
import dl.socket.SockMsg.RoomData;
import dl.socket.SockMsg.SendSubject;
import dl.socket.SockMsg.SockMsgGen;

/**
 * ...
 * @author Namide
 */
class SockRoom
{
	public var name:String;
	public var pass:String;
	public var datas:Dynamic;
	var _clients:Array<SockServerUser>;
	
	public function new(name:String, pass:String = null)
	{
		this.name = name;
		this.pass = (pass != null) ? pass : "";
		_clients = [];
	}
	
	function testCls( cl:SockServerUser )
	{
		if ( cl.room == this )
		{
			if ( clLength() == 1 && cl.role < Role.roomMaster && name != SockConfig.ROOM_DEFAULT )
				cl.role = Role.roomMaster;
		}
		else if ( cl.room == null )
		{
			if ( cl.role == Role.roomMaster )
				cl.role = Role.basic;
		}
	}
	
	public function addCl( cl:SockServerUser )
	{
		_clients.push( cl );
		cl.room = this;
		testCls( cl );
	}
	
	public function rmCl( cl:SockServerUser ):SockServerUser
	{
		var r = cl.room;
		
		_clients.remove( cl );
		cl.room = null;
		testCls( cl );
		
		if ( r != null )
			cl.server.broadcast( SockMsgGen.getSend( SendSubject.user, cl.getUserData( true, false, true, false, false ) ), r.getCls() );
		
		return cl;
	}
	
	public function clLength():UInt
	{
		return _clients.length;
	}
	
	public function getCls():Array<SockServerUser>
	{
		return _clients;
	}
	
	public function getRoomData( userList:Bool = false, userNumber:Bool = true, datas:Bool = false ):RoomData
	{
		var rd:RoomData = { n:name, p:(pass == "") ? "" : "1" };
		
		if ( userNumber )
			rd.l = _clients.length;
		
		if ( userList )
		{
			rd.u = [];
			for ( u in _clients )
				rd.u.push( u.getUserData( true, true, false, true, datas ) );
		}
		
		if ( datas )
			rd.d = this.datas;
		
		return rd;
	}
	
}