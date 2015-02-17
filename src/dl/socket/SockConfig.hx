package dl.socket ;

/**
 * ...
 * @author Namide
 */
class SockConfig
{
	public static inline var IP = '127.0.0.1';// '192.75.16.16';
	public static inline var PORT:UInt = 8090;
	
	public static inline var USER_NAME_LENGTH_MIN:UInt = 2;
	public static inline var USER_NAME_LENGTH_MAX:UInt = 10;
	
	public static inline var MSG_LENGTH_MIN:UInt = 1;
	public static inline var MSG_LENGTH_MAX:UInt = 512;
	
	public static inline var ROOM_DEFAULT = "~home";
	public static inline var ROOM_COOKIE = false;
	public static inline var USER_NAME = "~Guest";
	
	/**
	 * Null to disable user registered
	 */
	public static inline var SERVER_USERS_FILE:Null<String> = null;//"users.sqlite";
	public static inline var SERVER_LOGS = false;
	
		
	/**
	 * Port 843 only for admin.
	 * Required for Flash 10+
	 */
	public static inline var SEND_POLICY_843 = true;
}