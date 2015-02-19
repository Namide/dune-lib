package dl.socket ;

@:enum
abstract Cmd(Int)
{
	var other = 0;					// send policy
	var transferDatasClient = 1;	// client->server -> calcul
	var transferDatasServer = 2;	// server->client -> calcul
	var send = 3;					// both -> calcul
	
	inline function new( i:Int ){ this = i; }

	@:from
	public static function fromInt(i:Int):Cmd {
	    return new Cmd(i);
	}

	@:from
	public static function fromString(s:String):Cmd {
	    return new Cmd( Std.parseInt(s) );
	}
	
	@:to
	public function toInt():Int {
	    return this;
	}
}

@:enum
abstract SendSubject(Int)
{
	var roomList = 1;
	var errorSystem = 2;
	var messageSystem = 3;
	var connect = 4;
	var chat = 5;
	var register = 6;
	var login = 7;
	var kick = 8;
	var user = 9;
	var room = 10;
	
	inline function new(s: Int){ this = s; }

	@:from
	public static function fromInt(i:Int):SendSubject {
	    return new SendSubject(i);
	}

	@:to
	public function toInt():Int {
	    return this;
	}
}

@:enum
abstract Role(Int)
{
	var basic = 0;
	var roomMaster = 1;
	var admin = 2;
	
	inline function new(s: Int){ this = s; }

	@:from
	public static function fromInt(i:Int):Role {
	    return new Role(i);
	}

	@:to
	public function toInt():Int {
	    return this;
	}
	
	@:op(A > B)
	public function sup(r: Int): Bool
	{
		return this > r;
	}
	
	@:op(A < B)
	public function inf(r: Int): Bool
	{
		return this < r;
	}
}

class SockMsgGen
{
	function new() { throw "static class"; }
	
	/*public static function getUserData( userName:String = null, userId:Int = -1, userRoomName:String = null, userRoomPass:String = null ):SockMsg
	{
		var o:UserData = { };
		if ( userName != null )
			o.n = userName;
		
		if ( userId > -1 )
			o.i = userId;
		
		if ( userRoomName != null )
		{
			o.r = { n:userRoomName, p:"" };
			if ( userRoomPass != null )
				o.r.p = userRoomPass;
		}
		
		return new SockMsg( Cmd.setUserData, o );
	}*/
	
	public static function getSend( subject:SendSubject, ?content:Dynamic = null ):SockMsg
	{
		var o:Send = { s:subject };
		if ( content != null ) o.d = content;
		return new SockMsg( Cmd.send, o );
	}
	
	/*public static function getReturnRoomData( roomName:String, roomPass:String, userList:Array<UserData> = null, userNumber:Int = -1 ):SockMsg
	{		
		var o:RoomData = { n:roomName, p:(roomPass!="")?"1":"" };
		if ( userNumber > -1 ) 	o.l = userNumber;
		if ( userList != null ) o.u = userList;
		return new SockMsg( Cmd.returnRoomData, o );
	}*/
	
	public static function getTransferDatasServer( data:String, userId:Int ):SockMsg
	{		
		var o:TransferDatasServer = { d:data, i:userId };
		return new SockMsg( Cmd.transferDatasServer, o );
	}
	
	public inline static function getTransferDatasClient( data:Dynamic ):SockMsg
	{		
		return new SockMsg( Cmd.transferDatasClient, data );
	}
}

class SockMsg
{
	public var cmd:Cmd;
	public var struct:Dynamic;
	public inline function new( ?cmd:Cmd, ?struct:Dynamic )
	{
		if ( cmd != null ) 		this.cmd = cmd;
		if ( struct != null ) 	this.struct = struct;
	}
	
	public static function fromString( text:String ):SockMsg
	{
		var brut = new SockMsg();
		var cmd:Dynamic = Cmd.fromString( text.charAt(0) );
		
		if ( cmd == null )
			brut.cmd = Cmd.other;
		else
		{
			brut.cmd = cmd;
			text = text.substr(1);
		}
		
		switch( brut.cmd )
		{
			/*case Cmd.setUserData :
				var d:UserData = haxe.Json.parse( text );
				brut.struct = d;*/
			
			case Cmd.send :
				var d:Send = haxe.Json.parse( text );
				brut.struct = d;
			
			/*case Cmd.returnRoomData :
				var d:RoomData = haxe.Json.parse( text );
				brut.struct = d;*/
				
			case Cmd.transferDatasClient :
				//var d:TransferDatas = haxe.Json.parse( text );
				brut.struct = text;// d;
				
			case Cmd.transferDatasServer :
				var d:TransferDatasServer = haxe.Json.parse( text );
				brut.struct = d;
				
			case Cmd.other:
				brut.struct = text;
		}
		
	    return brut;
	}
	
	public function getString():String
	{
		return Std.string(cmd) + haxe.Json.stringify( struct );
	}
}

typedef UserData = {
	@:optional var i: Int;					// user id
	@:optional var n: String;				// user name
	@:optional var r: RoomData;				// room name of user
	@:optional var m: Role;					// moderator, role
	@:optional var d: Dynamic;				// additionnal data
}

typedef UserID = {
	var m: String;							// user email
	var p: String;							// user password
	var n: String;							// user name
}

typedef Send = {
	var s: SendSubject;						// subject
	@:optional var d:Dynamic;				// data
}

typedef Chat = {
	var m: String;							// message
	@:optional var f:Int;					// from user id
	@:optional var t:Int;					// to user id
}

typedef RoomData = {
	var n: String;							// room name
	var p: String; 							// password (only for private room)
	@:optional var u: Array<UserData>;		// list of users in the room
	@:optional var l: Int;					// number of users in the room
	@:optional var d: Dynamic;					// room datas
}

typedef RoomList = {
	var r: Array<RoomData>;					// list of rooms
}

/*typedef TransferDatasClient = {
	var d: String;							// data
}*/

typedef TransferDatasServer = {
	var i: Int;								// user id
	var d: String;							// data
}
