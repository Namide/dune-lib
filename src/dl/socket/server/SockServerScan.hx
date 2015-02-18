package dl.socket.server ;
import dl.socket.server.SockServer.SocketServer;
import dl.socket.SockMsg.Role;
import haxe.format.JsonParser;
import haxe.format.JsonPrinter;
import haxe.Json;
import neko.Lib;
import neko.vm.Thread;
import dl.socket.SockMsg.Chat;
import dl.socket.SockMsg.Cmd;
import dl.socket.SockMsg.RoomData;
import dl.socket.SockMsg.Send;
import dl.socket.SockMsg.SendSubject;
import dl.socket.SockMsg.SockMsgGen;
import dl.socket.SockMsg.UserData;
import dl.socket.SockMsg.UserID;
import sys.io.Process;

/**
 * ...
 * @author Namide
 */
class SockServerScan
{
	var sv:SocketServer;
	
	public function new(sv:SocketServer) 
	{
		this.sv = sv;
	}
	
	function findClientsByName( name:String, clients:Array<SockServerUser> ):Array<SockServerUser>
	{
		var r:Array<SockServerUser> = [];
		name = name.toLowerCase();
		for (cl in clients)
		{
			if (cl.name.toLowerCase().indexOf(name) != -1)
				r.push(cl);
		}
		
		return r;
	}
	
	public inline static function getBrutErrorSystem( msg:String = null ):SockMsg
	{
		var send:Send = (msg == null) ? { s:SendSubject.errorSystem } : { s:SendSubject.errorSystem, d:msg };
		return new SockMsg( Cmd.send, send );
	}
	
	/*public inline static function getBrutUserData( user:SockServerUser ):SockMsg
	{
		//var u:UserData = { i:user.id, n:user.name, r:user.room.name };
		//return new SockMsg( Cmd.setUserData, user.getUserData( true, true, true, true, true ) );
	}*/
	
	public inline static function testWord( s:String ):Bool
	{
		// /^([a-zA-Z_-]+)$/i.match(s);
		return ~/^[a-z0-9-]{3,10}$/i.match(s);//new EReg("^(\w)$", "i").match(w);
	}
	
	function updateUserName( cl:SockServerUser, newUser:UserData )
	{
		var newName = newUser.n;
		
		if (  	newName.length < SockConfig.USER_NAME_LENGTH_MIN ||	newName.length > SockConfig.USER_NAME_LENGTH_MAX )
		{
			return cl.send( SockMsgGen.getSend( SendSubject.errorSystem,
												'your name must have min:' +
												SockConfig.USER_NAME_LENGTH_MIN +
												' , max:' +
												SockConfig.USER_NAME_LENGTH_MAX +
												' character' ) );
			
		}
		
		if ( !testWord(newName) )
			return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, newName + ' is not a valid name' ) );
		
		var name = newName;
		if ( userExist( name ) )
			return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, newName + ' such name already exists' ) );
		
		appliUserName( cl, name );
	}
	
	function appliUserName( cl:SockServerUser, name:String )
	{
		sv.console.write( Std.string(cl) + ' rename > ' + name );
		
		var oldName = cl.name;
		cl.name = name;
		
		/*var u:UserData = { };
		u.n = name;
		u.i = cl.id;*/
		
		if ( cl.room != null )
		{
			sv.broadcast( SockMsgGen.getSend( SendSubject.user, cl.getUserData( true, true, false, false, false ) ), cl.room.getCls() );
			sv.broadcast( SockMsgGen.getSend( SendSubject.messageSystem, oldName + " is now known as " + name ), cl.room.getCls() );
			//sv.broadcast( new SockMsg( Cmd.setUserData, cl.getUserData(true, true, false, false, false) ), cl.room.getCls()/*.clients*/ );
		}
	}
	
	inline function userExist( name:String ):Bool
	{
		return 	Lambda.exists( sv.clients, function( c:SockServerUser ):Bool { return c.name.toLowerCase() == name.toLowerCase(); } ) || 
				(sv.users != null && sv.users.hasName( name ) );
	}
	
	function updateUserRoom( cl:SockServerUser, rd:RoomData )
	{
		var newRoomName = rd.n;
		
		if ( newRoomName == null )
		{
			newRoomName = rd.n = SockConfig.ROOM_DEFAULT_NAME;
			rd.p = "";
		}
		
		if ( newRoomName.toLowerCase() == SockConfig.ROOM_DEFAULT_NAME.toLowerCase() )
		{
			newRoomName = SockConfig.ROOM_DEFAULT_NAME;
		}
		else if (  	newRoomName.length < SockConfig.ROOM_NAME_LENGTH_MIN ||
					newRoomName.length > SockConfig.ROOM_NAME_LENGTH_MAX )
		{
			return cl.send( SockMsgGen.getSend( SendSubject.errorSystem,
											newRoomName +
											' room name must have min:' +
											SockConfig.ROOM_NAME_LENGTH_MIN +
											' , max:' +
											SockConfig.ROOM_NAME_LENGTH_MAX +
											' character' ) );
		}
		else if ( !testWord(newRoomName) )
		{
			return cl.send( SockMsgGen.getSend( SendSubject.errorSystem,
												newRoomName + ' is not a valid room name' ) );
		}
		
		var name = newRoomName;
		var pass = (rd.p == null) ? "" : rd.p;
		
		if ( name == SockConfig.ROOM_DEFAULT_NAME && pass != "" )
			cl.send( SockMsgGen.getSend( SendSubject.errorSystem, name + ' can\'t be private' ) );
		
		var oldRoom = cl.room;
		if ( sv.rooms.change( cl, name, pass ) )
		{
			sv.console.write( Std.string(cl) + ' change room > ' + name );
			
			if ( oldRoom != null && oldRoom.clLength() > 0 )
				sv.broadcast( SockMsgGen.getSend( SendSubject.messageSystem, cl.name + " leaves the room " ), oldRoom.getCls() );
			
			sv.broadcast( SockMsgGen.getSend( SendSubject.messageSystem, cl.name + " join the room" ), cl.room.getCls() );
		}
		else
		{
			cl.send( SockMsgGen.getSend( SendSubject.errorSystem, name + ' is private, you must have a password' ) );
		}
	}
	
	inline function updateRoom(  cl:SockServerUser, newRoom:RoomData )
	{
		if ( cl.role > Role.basic && newRoom.d != null )
		{
			cl.room.datas = newRoom.d;
			sv.broadcast( SockMsgGen.getSend( SendSubject.room, cl.room.getRoomData( false, false, true ) ), cl.room.getCls() );
		}
	}
	
	inline function updateUser( cl:SockServerUser, newUser:UserData )
	{
		// CHANGE THE NAME
		if ( newUser.n != null )
		{
			updateUserName( cl, newUser );
			// check the name to avoid errors
			newUser.n = cl.name;
		}
		
		// CHANGE THE ROOM
		if ( newUser.r != null )
		{
			updateUserRoom( cl, newUser.r );
			// check the room name to avoid errors
			newUser.r.n = ( cl.room != null ) ? cl.room.name : SockConfig.ROOM_DEFAULT_NAME;
			newUser.r.p = ( cl.room != null ) ? cl.room.pass : "";
			
			//newUser.r = ( cl.room != null ) ? cl.room.name : SockConfig.ROOM_DEFAULT;
			//newUser.rp = ( cl.room != null ) ? cl.room.pass : "";
		}
		
		if ( newUser.d != null )
			cl.datas = newUser.d;
		
		return newUser;
	}
	
	function kickUser( cl:SockServerUser, UserKikedId:Int )
	{
		if ( cl.room == null && cl.role < Role.admin )
		{
			cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'User not found' ) );
			return false;
		}
		
		// GET USER KICKED
		var kd:SockServerUser = Lambda.find( cl.room.getCls(), function( k:SockServerUser ) { return k.id == UserKikedId; } );
		
		//NOT FOUND
		if ( kd == null )
		{
			cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'User not found' ) );
			return false;
		}
		
		appliKick( kd, cl );
		
		return true;
	}
	
	function appliKick( kicked:SockServerUser, kicker:SockServerUser )
	{
		var oldRoom = kicked.room;
		sv.rooms.change( kicked, SockConfig.ROOM_DEFAULT_NAME, "" );
		kicked.send( SockMsgGen.getSend( SendSubject.messageSystem, 'You have been kicked by ' + kicker.fullName() + Std.string((oldRoom!=null)?(" from " + oldRoom.name):"" )) );
		
		if ( oldRoom != null )
			sv.broadcast( SockMsgGen.getSend( SendSubject.messageSystem, kicked.fullName() + ' has been kicked by ' + kicker.fullName() ), oldRoom.getCls() );
	}
	
	function appliBann( cl:SockServerUser, kiker:SockServerUser )
	{
		cl.send( SockMsgGen.getSend( SendSubject.messageSystem, 'You have been banned by ' + kiker.fullName() ) );
		sv.rooms.rm( cl );
		sv.clients.remove( cl );
		cl.active = false;
	}
	
	function serverCommands( chars:String, cl:SockServerUser )
	{
		var a = chars.split(" ");
		switch( a[0] )
		{
			case "/help" :
				
				sv.console.write( "\nCOMMANDS\n" );
				sv.console.write( "  /clients     print all clients" );
				sv.console.write( "  /rooms       print all rooms" );
				sv.console.write( "  /bannAll     bann all clients" );
				sv.console.write( "  /kick [id]   kick a client from a room" );
				sv.console.write( "  /close       quit app\n" );
				
			case "/exit" | "/close":
				
				for ( c in sv.clients )
					c.active = false;
				sv.console.write( "\n!server closed\n" );
				
				sv.close();
				
			case "/bannAll" :
				
				var i = sv.clients.length;
				while ( --i > -1 )
				{
					var c = sv.clients[i];
					appliBann( c, sv.admin );
					//c.send( SockMsgGen.getSend( SendSubject.messageSystem, c.fullName() + ' has been kicked by ' + cl.fullName() ) );
				}
				sv.console.write( "\n  all clients kicked!\n" );
				
			case "/clients" :
				
				sv.console.write( "\nCLIENT LIST\n" );
				for ( c in sv.clients )
					sv.console.write( "  " + c.id + " " + c.name + " (" + c.socket.peer().host + ":" + c.socket.peer().port + ")     " + c.room.name );
				
				if ( sv.clients.length < 1 )
					sv.console.write( "  ---\n" );
				else
					sv.console.write( " " );
				
			case "/rooms" :
				
				sv.console.write( "\nROOM LIST\n" );
				for ( r in sv.rooms.all() )
					sv.console.write( "  " + r.name + " (" + r.clLength()/*.clients.length*/ + ")" );
				
				if ( sv.rooms.all().length < 1 )
					sv.console.write( "  ---\n" );
				else
					sv.console.write( " " );
			
			case "/room" :
				
				if ( a.length > 1 )
				{
					var r = Lambda.find( sv.rooms.all(), function(r0:SockRoom) { return (r0.name.toLowerCase() == a[1].toLowerCase() ); } );
					if ( r != null )
					{
						sv.console.write( "\n ROOM: " + r.name + "\n" );
						
						for ( c in r.getCls()/*.clients*/ )
							sv.console.write( "  " + c.id + " " + c.name + " (" + c.socket.peer().host + ":" + c.socket.peer().port + ")     " + c.room.name );
						
						if ( r.clLength()/*.clients.length*/ < 1 )
							sv.console.write( "  ---\n" );
						else
							sv.console.write( " " );
						
					}
					else
					{
						sv.console.write( "\n  room: " + a[1] + " not found\n" );
					}
				}
				
			case "/kick" :
				
				if ( a.length > 1 )
				{
					if ( kickUser( sv.admin, Std.parseInt( a[1] ) ) )
					{
						sv.console.write( "\n  " + Std.parseInt( a[1] ) + " kicked!\n" );
					}
					else
					{
						sv.console.write( "\n  client: " + a[1] + " not found (must be an ID)\n" );
					}
					
					/*var c = Lambda.find( sv.clients, function(c0:SockServerUser) { return (c0.id == Std.parseInt( a[1] ) ); } );
					if ( c != null )
					{
						for ( c2 in c.room.getCls() )
							c2.send( SockMsgGen.getSend( SendSubject.messageSystem, c.fullName() + ' has been kicked by ' + sv.admin.fullName() ) );
						
						sv.rooms.rm( c );
						sv.clients.remove( c );
						c.active = false;
						
						sv.console.write( "\n  " + c.id + " " + c.name + " (" + c.socket.peer().host + ":" + c.socket.peer().port + ")     kicked!\n" );
					}
					else
					{
						sv.console.write( "\n  client: " + a[1] + " not found (must be an ID)\n" );
					}*/
				}
				
				
		}
	}
	
	public function appli( chars:String, cl:SockServerUser )
	{
		// SERVER COMMANDS
		if ( cl == sv.admin )
		{
			serverCommands( chars, cl );
			return;
		}
		
		
		// CLIENTS COMMANDS
		var brut = SockMsg.fromString( chars );
		switch ( brut.cmd )
		{
			case Cmd.send:
				
				var o:Send = brut.struct;
				switch( o.s )
				{
					case SendSubject.connect:
						
						cl.dispatch = false;
						sv.clients.push(cl);
						
						var u:UserData = o.d;
						if ( u.n != null || u.r != null )
							u = updateUser( cl, u );
						
						if ( cl.room == null )
							sv.rooms.add( cl, SockConfig.ROOM_DEFAULT_NAME, "" );
						
						u = cl.getUserData( true, true, false, true, false );
						u.r = cl.room.getRoomData( true, false, true );
						
						cl.dispatch = true;
						cl.send( SockMsgGen.getSend( SendSubject.connect, u ) );
						
						if ( 	!SockConfig.ROOM_DEFAULT_IS_ROOM &&
								cl.room != null &&
								cl.room.name.toLowerCase() == SockConfig.ROOM_DEFAULT_NAME )
							cl.send( SockMsgGen.getSend( SendSubject.roomList, sv.rooms.getRoomListData(sv) ) );
						
						return;
						
					case SendSubject.user :
				
						var newUser:UserData = o.d;
						updateUser( cl, newUser );
						return;
						
					case SendSubject.room :
				
						var newRoom:RoomData = o.d;
						updateRoom( cl, newRoom );
						return;
						
					case SendSubject.kick:
						
						var newUser:UserData = o.d;
						kickUser( cl, newUser.i );
						return;
						
					case SendSubject.errorSystem:
						
						// Not implemented for server
						return;
						
					case SendSubject.chat:
						
						var o2:Chat = o.d;
						if ( o2.m.length < 1 )
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'Empty messages not allowed' ) );
						
						o2.f = cl.id;
						
						sv.console.write( cl.id + "_(" + cl.name + ")" + ( (o2.t!=null)?(">"+o2.t):"" ) + ": " + o2.m );
						
						// SEND A MESSAGE TO
						if ( o2.t != null )
						{
							var rc:SockServerUser = (cl.room != null) ? Lambda.find( cl.room.getCls()/*.clients*/, function(u:SockServerUser) { return u.id == o2.t; } ) : null;
							
							if ( rc == null )
								return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'User not found' ) );
							
							cl.send( SockMsgGen.getSend( SendSubject.chat, o2 ) );
							rc.send( SockMsgGen.getSend( SendSubject.chat, o2 ) );
							return;
						}
						
						return sv.broadcast( SockMsgGen.getSend( SendSubject.chat, o2 ), cl.room.getCls()/*.clients*/ );
						
					case SendSubject.messageSystem:
						
						// Not implemented for server
						return;
						
					case SendSubject.roomList:
						
						/*var rl:Array<RoomData> = [];
						for ( r in sv.rooms.all() )
							rl.push( r.getRoomData( false, true ) );*/
						
						cl.send( SockMsgGen.getSend( SendSubject.roomList, sv.rooms.getRoomListData( sv ) ) );
						return;
					
					case SendSubject.register:
						
						if ( sv.users == null )
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'Register mode disable' ) );
						
						var ui:UserID = o.d;
						var ereg = ~/\w+@[a-z_\.-]+?\.[a-z]{2,6}/i;
						if ( !ereg.match( ui.m ) )
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, ui.m + ' invalid e-mail format' ) );
						
						if ( !testWord(ui.n) )
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, ui.n + ' is not a valid name' ) );
						
						if ( userExist(ui.n) && ui.n.toLowerCase() != cl.name.toLowerCase() )
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, ui.n + ' such name already exists' ) );
						
						if ( sv.users.hasMail(ui.m) )
						{
							if ( sv.users.get( ui.m, ui.p ) == null )
								return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'bad password' ) );
							
							sv.users.update( ui.m, ui.p, ui.n );
						}
						else
						{
							sv.users.insert( ui.m, ui.p, ui.n );
						}
						
						appliUserName( cl, ui.n );
						
						return cl.send( SockMsgGen.getSend( SendSubject.messageSystem, 'You have been registered' ) );
						
					case SendSubject.login:
						
						if ( sv.users == null )
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'Login mode disable' ) );
						
						var ui:UserID = o.d;
						
						if ( sv.users.hasMail(ui.m) )
						{
							var udb = sv.users.get( ui.m, ui.p );
							if ( udb == null )
								return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'bad password' ) );
							
							appliUserName( cl, udb.name );
						}
						else
						{
							return cl.send( SockMsgGen.getSend( SendSubject.errorSystem, 'Entry not found' ) );
						}
					
				}
				
			case Cmd.transferDatasClient :
			
				var msg = SockMsgGen.getTransferDatasServer( brut.struct, cl.id );
				for ( c in cl.room.getCls() )
					c.send( msg );
				return;
			
			case Cmd.transferDatasServer :
				
				// Not implemented for server
				return;
				
			/*case Cmd.returnRoomData :
				
				// Not implemented for server
				return;*/
				
			/*case Cmd.setUserData :
				
				var newUser:UserData = brut.struct;
				updateUser( cl, newUser );
				return;*/
				
			case Cmd.other :
				
				// not working
				if ( brut.struct == "<policy-file-request/>\x00" )
				{
					sv.console.write( "MS: Sending policies to:" + sv.socket.peer().host );
					cl.sendPolicy();
				}
				
				cl.active = false;
				//cl.socket.close();
				
		}		
	}
}