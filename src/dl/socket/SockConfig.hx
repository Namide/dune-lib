package dl.socket ;
import dl.utils.Name;

/**
 * ...
 * @author Namide
 */
class SockConfig
{
	public static var IP = '127.0.0.1';// '192.75.16.16';
	public static var PORT:UInt = 8090;
	
	public static var USER_NAME_LENGTH_MIN:UInt = 2;
	public static var USER_NAME_LENGTH_MAX:UInt = 10;
	
	public static var ROOM_NAME_LENGTH_MIN:UInt = 3;
	public static var ROOM_NAME_LENGTH_MAX:UInt = 10;
	
	public static var MSG_LENGTH_MIN:UInt = 1;
	public static var MSG_LENGTH_MAX:UInt = 512;
	
	public static var ROOM_DEFAULT_NAME = "~home";
	public static var ROOM_DEFAULT_IS_LOBBY = false;
	public static var ROOM_LIST_WITH_DATAS = false;
	
	public static var ROOM_COOKIE = true;
	public static dynamic function USER_NAME_GEN( seed:Int ) {
		return Name.getRandName( USER_NAME_LENGTH_MIN, USER_NAME_LENGTH_MAX );// "~Guest" + seed;
	};
	
	
	
	/**
	 * Null to disable user registered
	 */
	public static var SERVER_USERS_FILE:Null<String> = null;//"users.sqlite";
	public static var SERVER_LOGS = false;
	
	/**
	 * Port 843 only for admin.
	 * Required for Flash 10+
	 */
	public static var SEND_POLICY_843 = true;
}