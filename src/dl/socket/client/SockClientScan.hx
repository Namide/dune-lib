package dl.socket.client ;
import dl.socket.SockMsg.Chat;
import dl.socket.SockMsg.Cmd;
import dl.socket.SockMsg.Role;
import dl.socket.SockMsg.RoomData;
import dl.socket.SockMsg.Send;
import dl.socket.SockMsg.SendSubject;
import dl.socket.SockMsg.SockMsgGen;
import dl.socket.SockMsg.TransferDatasServer;
import dl.socket.SockMsg.UserData;
import dl.socket.SockMsg.UserID;

@:enum
abstract SystemMsg(Int)
{
	var error = 1;
	var message = 2;
	
	inline function new(s: Int){ this = s; }

	@:from
	public static function fromInt(i:Int):SystemMsg {
	    return new SystemMsg(i);
	}

	@:to
	public function toInt():Int {
	    return this;
	}
}

/**
 * ...
 * @author Namide
 */
class SockClientScan
{
	public var me:SockClientUser;
	public var others:Array<SockClientUser>;
	
	public var onMe:SockClientUser->Void;
	public var onOthers:Array<SockClientUser>->Void;
	public var onConnected:SockClientUser->Void;
	public var onRoom:String->Array<SockClientUser>->Void;
	public var onMsgSystem:String->SystemMsg->Void;
	public var onRoomList:Array<RoomData>->Void;
	
	public var onChat:String->Void;
	public var onGame:TransferDatasServer->Void;
	
	var _room:String;
	var _socket:SockPipe;
	
	var _connected:Bool;
	
	inline function _onMe( u:SockClientUser ) 						{ if ( onMe != null ) onMe( u ); }
	inline function _onOthers( a:Array<SockClientUser> ) 			{ if ( onOthers != null ) onOthers( a ); }
	inline function _onConnected( u:SockClientUser ) 				{ if ( onConnected != null ) onConnected( u ); }
	inline function _onRoom( r:String, a:Array<SockClientUser> ) 	{ if ( onRoom != null ) onRoom( r, a ); }
	inline function _onRoomList( a:Array<RoomData> ) 				{ if ( onRoomList != null ) onRoomList( a ); }
	inline function _onChat( s:String ) 							{ if ( onChat != null ) onChat( s ); }
	inline function _onGame( t:TransferDatasServer ) 				{ if ( onGame != null ) onGame( t ); }
	inline function _onMsgSystem( msg:String, type:SystemMsg ) 		{ if ( onMsgSystem != null ) onMsgSystem( msg, type ); }
	
	public function new( ?me:SockClientUser = null ) 
	{
		_connected = false;
		
		this.me = ( me == null ) ? new SockClientUser() : me;
		others = [];
		
		_room = "";
		_socket = new SockPipe();
		_socket.onConnected = connection;
		_socket.onReceive = appliServer;
	}
	
	function connection( socket:SockPipe )
	{
		var u:UserData = { };
		
		if ( me.datas != null )
			u.d = me.datas;
		
		try
		{
			var so = flash.net.SharedObject.getLocal( "chat" );
			
			if ( so.data.name != null )
				u.n = so.data.name;
			
			if ( SockConfig.ROOM_COOKIE && so.data.room != null )
				u.r = so.data.room;
		}
		catch (e:Dynamic)
		{
			_onMsgSystem( "Load name and room error (" + e + ")", SystemMsg.error );
			//_onChat( "Load name and room error (" + e + ")" );
		}
		
		var msg:SockMsg = SockMsgGen.getSend( SendSubject.connect, u );
		return _socket.send( msg );
	}
	
	public inline function transfertData( text:Dynamic )
	{
		if ( text != null )
			_socket.send( SockMsgGen.getTransferDatasClient( text ) );
	}
	
	public function appliChat( text:String ):Void
	{
		if ( text.length < 1 )
			return;
		
		if ( text.charAt(0) != "/" )
		{
			var m:Chat = { m:text };
			return _socket.send( SockMsgGen.getSend( SendSubject.chat, m ) );
		}
		else
		{
			var text2 = text.substr(1);
			var rx = ~/^(\w+) *(.*)/g;
			if (!rx.match(text2))
				return _onMsgSystem( '"' + text2 + '" is not a valid command format', SystemMsg.error );
				//return  _onChat( '<i>"' + text2 + '" is not a valid command format</i>' );
			
			switch ( rx.matched(1) )
			{
				case "name":
					
					var ud:UserData = { n:rx.matched(2) };
					return _socket.send( SockMsgGen.getSend( SendSubject.user, ud ));
					
				case "help":
					
					_onChat('<b>____________</b>');
					_onChat("<b>Commands</b>");
					_onChat("<b>¯¯¯¯¯¯¯¯¯¯¯¯</b>");
					_onChat('<i> <b>/help</b> to list the commands...</i>');
					_onChat("<i> <b>/name [newName]</b> to have a new name</i>");
					_onChat("<i> <b>/join [roomName]</b> to join a new room</i>");
					_onChat("<i> <b>/join [roomName] [password]</b> to join a private room</i>");
					_onChat("<br/>");
					_onChat("<i> <b>/users</b> to list all the users in the room</i>");
					_onChat("<i> <b>/rooms</b> to list all the rooms</i>");
					if ( SockConfig.SERVER_USERS_FILE != null )
					{
						_onChat("<br/>");
						_onChat("<i> <b>/register [email] [password] [name]</b> register a new name (1 per email)</i>");
						_onChat("<i> <b>/register [email] [password]</b> register your current name (1 per email)</i>");
						_onChat("<i> <b>/login [email] [password]</b> load your last registered name</i>");
					}
					if ( me.role > Role.basic )
					{
						_onChat("<br/>");
						_onChat("<i> <b>/kick [userName]</b> kick this user</i>");
					}
					_onChat('<b>____________</b>');
					_onChat(" ");
					
					return;
				
				case "users":
					
					_onChat('<b>____________</b>');
					_onChat("<b>" + _room + "</b> <i>(" + (others.length+1) + ")</i>");
					_onChat("<b>¯¯¯¯¯¯¯¯¯¯¯¯</b>");
					_onChat('<i>'+me.fullName()+"</i>");
					for ( u in others )
						_onChat(" <i>"+u.fullName()+"</i>");
					_onChat("");
					_onChat('<b>____________</b>');
					_onChat(" ");
					
					return;
				
				case "register":
					
					var a = rx.matched(2).split(" ");
					if (a.length!=2 && a.length!=3)
						return _onMsgSystem( 'Invalid command format', SystemMsg.error );//_onChat( '<p align="left"><i>Invalid command format</i></p>' );
					
					var ui:UserID = { m:a[0], p:a[1], n:((a.length<3)?me.name:a[2]) };
					return _socket.send( SockMsgGen.getSend( SendSubject.register, ui ) );
					
				case "login":
				
					var a = rx.matched(2).split(" ");
					if (a.length!=2)
						return _onMsgSystem( 'Invalid format', SystemMsg.error );//_onChat( '<p align="left"><i>Invalid format</i></p>' );
					
					var ui:UserID = { m:a[0], p:a[1], n:me.name };
					return _socket.send( SockMsgGen.getSend( SendSubject.login, ui ) );
					
				case "join":
					
					var roomData = rx.matched(2).split(" ");
					var ud:UserData = { r:{ n:roomData[0], p:((roomData.length>1)?roomData[1]:"") } };
					return _socket.send( SockMsgGen.getSend( SendSubject.user, ud ) );
					
				case "kick":
					
					var name = rx.matched(2);
					name = ( name.charAt(0) == "@" ) ? name.substring( 1 ) : name;
					
					var rx2 = ~/^(\w+) *(.+)/;
					if (!rx2.match(name))
						return _onMsgSystem( 'Invalid format', SystemMsg.error );//_onChat( '<p align="left"><i>Invalid format</i></p>' );						
					
					var u = Lambda.find( others, function(c2:SockClientUser) { return c2.name.toLowerCase() == name.toLowerCase(); } );
					if (u == null)
						return _onMsgSystem( name + ' not found', SystemMsg.error );//_onChat( '<p align="left"><i><b>' + name + '</b> not found</i></p>' );
					
					if (u.role.toInt() >= me.role.toInt())
						return _onMsgSystem( 'You can not kick a user with a role superior or equal to you', SystemMsg.error );// _onChat( '<p align="left"><i>You can not kick a user with a role superior or equal to you</p>' );
					
					var ui:UserData = { i:u.id, n:u.name };
					return _socket.send( SockMsgGen.getSend( SendSubject.kick, ui ) );
					
				case "rooms":
					
					return _socket.send( SockMsgGen.getSend( SendSubject.roomList ) );
				
				case "to":
					
					var nameMsg = rx.matched(2);
					nameMsg = ( nameMsg.charAt(0) == "@" ) ? nameMsg.substring( 1 ) : nameMsg;
					
					var rx2 = ~/^(\w+) *(.+)/;
					if (!rx2.match(nameMsg))
						return _onMsgSystem( 'Invalid format', SystemMsg.error );//return _onChat( '<p align="left"><i>Invalid format</i></p>' );
					
					var name2:String = rx2.matched(1);
					var rcs = Lambda.find( others, function(c2:SockClientUser) { return c2.name.toLowerCase() == name2.toLowerCase(); } );//findClientsByName( rx2.matched(1), cl.room.clients );
					if (rcs == null)
						return _onMsgSystem( '"' + name2 + '" not found', SystemMsg.error );//_onChat( '<p align="left"><i><b>' + name2 + '</b> not found</i></p>' );
					
					var msg = rx2.matched(2);
					
					var c:Chat = { m:msg, t:rcs.id };
					return _socket.send( SockMsgGen.getSend( SendSubject.chat, c ) );
				
			}
		}
		
		return _onMsgSystem( '"' + text + '" is not a valid command format', SystemMsg.error );
		//return _onChat( '<p align="left"><i>"' + text + '" is not a valid command format</i></p>' );
	}
	
	public inline function getUserById(id:Int):Null<SockClientUser>
	{
		return Lambda.find( others, function(u) { return u.id == id; } );
	}
	
	function setRoom( o:RoomData )
	{
		var lastName = _room;
		
		others = [];
		_room = o.n;
		
		if( o.u != null )
			for ( u in o.u )
				setUser( u, true );
		
		if ( lastName != _room )
			_onRoom( _room, others );
		else
			_onOthers( others );
		
	}
	
	function initMe( o:UserData )
	{
		if ( o.i != null )
		{
			// to avoid error (others already initialized)
			var u = getUserById( o.i );
			if ( u != null )
				others.remove( u );
			
			me.id = o.i;
		}
		
		if ( o.n != null )
			me.name = o.n;
		
		_connected = true;
		_onConnected( me );
		
		if ( o.r != null )
			setRoom( o.r );
	}
	
	function setUser( o:UserData, avoidMsg:Bool = false )
	{
		var user = getUserById( o.i );
		if ( user == null && me.id == o.i )
			user = me;
		
		if ( user != null )
		{
			var lastName:String = user.name;
			var lastRoom:String = _room;
			var lastRole:Role = user.role;
			user.name = (o.n != null) ? o.n : user.name;
			user.role = (o.m != null) ? o.m : user.role;
			var newRoom = (o.r != null) ? o.r.n : _room;
			
			if ( me == user )
			{
				if ( newRoom != lastRoom )
					setRoom( o.r );
					
				if ( user.name != lastName || user.role != lastRole )
					_onMe( user );
				
			}
			else
			{
				if ( newRoom != lastRoom  )
				{
					others.remove( user );
					
					if ( !avoidMsg )
						_onOthers( others );
				}
				else if ( user.name != lastName || user.role != lastRole )
				{
					if ( !avoidMsg )
						_onOthers( others );
				}
			}
		}
		else if ( o.r == null || o.r.n == _room )
		{
			user = new SockClientUser();
			user.id = o.i;
			user.name = o.n;
			user.role = o.m;
			user.datas = o.d;
			
			others.push( user );
			
			if ( !avoidMsg )
				_onOthers( others );
		}
		
		// Save the datas in cookie file
		if ( user == me )
		{
			try
			{
				var so = flash.net.SharedObject.getLocal( "chat" );
				
				if ( user.name != null )
					so.data.name = user.name;
				
				if ( SockConfig.ROOM_COOKIE && _room != null )
					so.data.room = _room;
				
				so.flush();
			}
			catch (e:Dynamic)
			{
				return _onMsgSystem( "Load name and room error (" + e + ")", SystemMsg.error );
				//_onChat( "Load name and room error (" + e + ")" );
			}
		}
	}
	
	function printChatMsg( o:Chat )
	{
		var user = (o.f == me.id) ? me : getUserById( o.f );
		
		if ( user == null )
			return;
		
		if ( user == me )
		{
			if ( o.t != null )
			{
				var u:SockClientUser = Lambda.find( others, function(u:SockClientUser) { return u.id == o.t; } );
				return _onChat( '<b>' + me.fullName() + ">" + u.fullName() + "</b>: " + o.m );
			}
			return _onChat( '<b>' + me.fullName() + "</b>: " + o.m );
		}
		
		if ( o.t == me.id )
			return _onChat( '<b>' + user.fullName() + ">" + me.fullName() + "</b>: " + o.m );
		
		return _onChat( '<b>' + user.fullName() + "</b>: " + o.m );
	}
	
	function printRoomList( rl:Array<RoomData> )
	{
		_onChat('____________');
		_onChat("<b>Room list</b><br><i>(number of users)</i>");
		_onChat("¯¯¯¯¯¯¯¯¯¯¯¯");
		for ( r in rl )
		{
			if ( r.l != null )
				_onChat(" <i>" + r.n + " (" + r.l + ") " + ((r.p == "")?"":"(private)") + "</i>");
			else if ( r.u != null )
				_onChat(" <i>" + r.n + " (" + r.u.length + ") " + ((r.p == "")?"":"(private)") + "</i>");
		}
		_onChat('____________');
		_onChat(' ');
	}
	
	public function appliServer( brut:SockMsg ):Void
	{
		
		switch ( brut.cmd )
		{
			case Cmd.transferDatasServer:
				
				var o:TransferDatasServer = brut.struct;
				onGame( o );
				
			case Cmd.send:
				
				var o:Send = brut.struct;
				switch ( o.s )
				{
					case SendSubject.room:
						
						var room:RoomData = o.d;
						setRoom( room );
					
					case SendSubject.user:
						
						var user:UserData = o.d;
						return setUser( user );
					
					case SendSubject.chat:
						
						var o2:Chat = o.d;
						return printChatMsg( o2 );
						
					case SendSubject.connect:
						
						var o2:UserData = o.d;
						return initMe( o2 );
						
					case SendSubject.errorSystem:
						
						return _onMsgSystem( o.d, SystemMsg.error );
						//return _onChat( '<p align="left"><i>' + o.d + "</i></p>" );
						
					case SendSubject.messageSystem:
						
						return _onMsgSystem( o.d, SystemMsg.message );
						//return _onChat( '<p align="left"><i>' + o.d + "</i></p>" );
						
					case SendSubject.roomList:
						
						var o2:Array<RoomData> = o.d;
						_onRoomList( o2 );
						return printRoomList( o2 );
						
					case SendSubject.login | SendSubject.register | SendSubject.kick:
						
						// for server
						
				}
				
			case Cmd.other | Cmd.transferDatasClient:
				
				// for server
				
		}
	}
}