package dl.socket.server.db ;
import sys.db.Connection;
import sys.db.Manager;
import sys.db.Object;
import sys.db.Sqlite;
import sys.db.TableCreate;
import sys.db.Types.SDate;
import sys.db.Types.SInt;
import sys.db.Types.SString;

// http://old.haxe.org/manual/spod
@:table("user")
class User extends sys.db.Object
{
    public var id : SInt;
    public var name : SString<32>;
	public var pass: SString<64>;
	public var mail: SString<64>;
	public var date: SDate;
}

/**
 * ...
 * @author Namide
 */
class SockUserDB
{
	var cnx:Connection;
	var mng:sys.db.Manager<User>;
	
	public function new()
	{
		
	}
	
	public function open()
	{
		cnx = Sqlite.open(SockConfig.SERVER_USERS_FILE);
		
		sys.db.Manager.cnx = cnx;
		if ( !sys.db.TableCreate.exists(User.manager)  )
		{
			sys.db.TableCreate.create(User.manager);
		}
	}
	
	public inline function hasMail( mail:String ):Bool
	{
		return (User.manager.search( { mail:mail } ).length > 0); 
	}
	
	public inline function hasName( name:String ):Bool
	{
		return (User.manager.search( { name:name } ).length > 0);
	}
	
	public function get( mail:String, pass:String ):Null<User>
	{
		var a = User.manager.search( { mail:mail, pass:pass } );
		return (a.isEmpty()) ? null : a.first(); 
	}
	
	public function update( mail:String, pass:String, newName:String )
	{
		var u = get( mail, pass );
		u.name = newName;
		u.update();
	}
	
	public function insert( mail:String, pass:String, name:String )
	{
		var u = new User();
		u.name = name;
		u.date = Date.now();
		u.pass = pass;
		u.mail = mail;
		u.insert();
	}
	
	public function close()
	{
		cnx.close();
	}
	
}