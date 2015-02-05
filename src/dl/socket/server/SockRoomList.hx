package dl.socket.server ;
import haxe.Json;
import dl.socket.SockMsg.Cmd;
import dl.socket.SockMsg.SockMsgGen;
import dl.socket.SockMsg.UserData;

/**
 * ...
 * @author Namide
 */
class SockRoomList
{

	var _list:Array<SockRoom>;
	
	public function new() 
	{
		if ( _list == null )
			_list = [];
	}
	
	public function set( roomName:String, roomPass:String ):SockRoom
	{
		var ri:SockRoom = Lambda.find (_list, function(tmp:SockRoom):Bool { return tmp.name.toLowerCase() == roomName.toLowerCase(); } );
		if ( ri == null )
		{
			ri = new SockRoom( roomName, roomPass );
			_list.push( ri );
		}
		
		return ri;
	}
	
	public function all():Array<SockRoom>
	{
		return _list;
	}
	
	public inline function change( ci:SockServerUser, roomName:String, roomPass:String ):Bool
	{
		return add( ci, roomName, roomPass );
	}
	
	public function add( ci:SockServerUser, roomName:String, roomPass:String ):Bool
	{
		var ri:SockRoom = set( roomName, roomPass );
		if ( ri == null )
			return false;
		
		remove( ci );
		
		ri.clients.push(ci);
		ci.room = ri;
		
		// send to the new user
		var ul:Array<UserData> = [];
		for ( u in ri.clients )
			ul.push( { n:u.name, i:u.id } );
		
		ci.send( SockMsgGen.getReturnRoomData( ri.name, ri.pass, ul ) );
		
		// Send to all users in the room
		var nu:UserData = { i:ci.id, n:ci.name, r:ri.name };
		ci.server.broadcast( new SockMsg( Cmd.setUserData, nu ), ri.clients );
		
		return true;
	}
	
	public function remove( ci:SockServerUser, dispatchMsg:Bool = true )
	{
		var ri:SockRoom = ci.room;
		if ( ri == null )
			return;
		
		ri.clients.remove( ci );
		
		if ( ri.clients.length < 1 )
		{
			_list.remove( ri );
		}
		else if ( dispatchMsg )
		{
			var nu:UserData = { i:ci.id, n:ci.name, r:"?" };
			ci.server.broadcast( new SockMsg( Cmd.setUserData, nu ), ri.clients );
		}
	}
	
}