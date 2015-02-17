package dl.socket.client ;

import dl.socket.SockMsg.UserData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.ui.Keyboard;

/**
 * ...
 * @author Namide
 */
class SockClientTchatUI extends Sprite
{
	public static var MARG_EXT:Int = 32;
	public static var MARG_INT:Int = 16;
	public static var LIST_LARG:Int = 256;
	
	public var sendMsg:String->Void;
	
	var _me:SockClientUser;
	var _others:Array<SockClientUser>;
	var _room:String;
	
	var _input:TextField;
	var _output:TextField;
	var _list:TextField;
	
	public function new() 
	{
		super();
		
		_others = [];
		_room = "";
		
		var s:Stage = flash.Lib.current.stage;
		s.addEventListener( Event.RESIZE, resize );
		
		var ft:TextFormat = new TextFormat();
		ft.font = "Verdana";
		ft.size = 15;
		
		_input = new TextField();
		_input.type = TextFieldType.INPUT;
		_input.maxChars = SockConfig.MSG_LENGTH_MAX;
		_input.defaultTextFormat = ft;
		_input.autoSize = TextFieldAutoSize.LEFT;
		var h = _input.height;
		_input.autoSize = TextFieldAutoSize.NONE;
		_input.height = h;
		_input.textColor = 0xFFFFFF;
		addChild( _input );
		
		_output = new TextField();
		_output.defaultTextFormat = ft;
		_output.wordWrap = true;
		_output.multiline = true;
		_output.textColor = 0xFFFFFF;
		addChild( _output );
		
		_list = new TextField();
		_list.defaultTextFormat = ft;
		_list.wordWrap = true;
		_list.multiline = true;
		_list.textColor = 0xCCCCCC;
		addChild( _list );
		
		resize();
		addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
	}
	
	function onKeyUp(e:KeyboardEvent):Void 
	{
		if ( e.charCode == Keyboard.ENTER )
		{
			sendMsg( _input.text );
			_input.text = "";
		}
	}
	
	public function connect( me:SockClientUser )
	{
		_me = me.clone();
		
		appendText( '<p align="left"><i>Welcome on this Tchat!</i></p>' );
		appendText( '<p align="left"><i>Your name is <b>' + _me.fullName() + '</b></i></p>' );
		//appendText( '<p align="left"><i>You joined the room <b>' + _room + '</b></i></p>' );
		
	}
	
	public function refreshMe( me:SockClientUser )
	{
		//if ( me.name != _me.name )
		//	appendText( '<p align="left"><i>Your name is now <b>' + me.fullName() + '</b></i></p>' );
		
		_me = me.clone();
		refreshRight();
		
		//appendText( '<p align="left"><i>Welcome on this Tchat!</i></p>' );
		//appendText( '<p align="left"><i>You joined the room <b>' + _room + '</b></i></p>' );
	}
	
	public inline function changeRoom( room:String, userList:Array<SockClientUser> )
	{
		if ( room == _room )
			return;
		
		if ( _room != "" )
			clear();
		
		_room = room;
		appendText( '<p align="left"><i>You joined <b>' + _room + '</b> (' + (userList.length+1) + ")</i></p>" );
		
		_others = cloneList(userList);
		refreshRight();
	}
	
	inline function cloneList( list:Array<SockClientUser> ):Array<SockClientUser>
	{
		var c:Array<SockClientUser> = [];
		for ( u in list )
			c.push( u.clone() );
		return c;
	}
	
	inline function clear()
	{
		_output.text = '';
		_list.htmlText = "";
	}
	
	public inline function appendText( t:String )
	{
		_output.htmlText += t + "</br>";
		refreshText();
	}
	
	public inline function refreshOthers( list:Array<SockClientUser> )
	{
		//trace( list.length, _room );
		if ( _room != "" )
		{
			for ( newUser in list )
			{
				var oldUser = Lambda.find( _others, function(user:SockClientUser) {
					return user.id == newUser.id;
				} );
				
				/*if ( oldUser == null )
				{
					//appendText( '<p align="left"><i>' + newUser.fullName() + ' join the room ' + _room + ' ('+(list.length+1)+')</i></p>' );
				}
				else
				{
					//if ( newUser.name != oldUser.name )
					//	appendText( '<p align="left"><i>' + oldUser.fullName() + ' is now known as <b>' + newUser.fullName() + '</b></i></p>' );
				}*/
			}
			
			for ( oldUser in _others )
			{
				var newUser = Lambda.find( list, function(user:SockClientUser) {
					return user.id == oldUser.id;
				} );
				
				/*if ( newUser == null )
				{
					//appendText( '<p align="left"><i>' + oldUser.fullName() + " leaves the room " + _room + "</i></p>" );
				}*/
			}
		}
		
		
		_others = cloneList( list );
		refreshRight();
	}
	
	function refreshRight()
	{
		var list = _others.concat([_me]);
		list.sort( function(a:SockClientUser, b:SockClientUser) { return (a.fullName() > b.fullName())?1: -1; } );
		
		var t = '<p align="center"><b>' + _room + "</b> (" + list.length + ")</p><br/>";
		for ( u in list )
		{
			if ( u.name != null )
				t += " <i>"+u.fullName()+"</i><br/>";
		}
		t += "<br/><br/><i>List of commands:<br/>/help</i>";
		
		_list.htmlText = t;
	}
	
	inline inline function refreshText()
	{
		_output.scrollV = _output.maxScrollV;
	}
	
	public function resize( ?e:Dynamic )
	{
		var s:Stage = flash.Lib.current.stage;
		var w = s.stageWidth;
		var h = s.stageHeight;
		
		graphics.clear();
		
		_input.width =
		_output.width = w - (2*MARG_EXT+3*MARG_INT+LIST_LARG);
		
		_input.x =
		_output.x = MARG_EXT + MARG_INT;
		
		_output.y = MARG_EXT + MARG_INT;
		_input.y = h - (_input.height+MARG_EXT+MARG_INT);
		_output.height = _input.y - (MARG_EXT+4*MARG_INT);
		
		_list.x = w + MARG_INT - (LIST_LARG + MARG_EXT);
		_list.y = MARG_INT + MARG_EXT;
		_list.width = LIST_LARG - 2 * MARG_INT;
		_list.height = h - (2*MARG_INT + 2*MARG_EXT);
		
		graphics.beginFill( 0x314346 );
		graphics.drawRect( 	0, 0, w, h );
		
		graphics.beginFill( 0x536467 );
		graphics.drawRect( 	_output.x - MARG_INT,
							_output.y - MARG_INT,
							_output.width + 2 * MARG_INT,
							_output.height + 2 * MARG_INT );
		
		graphics.drawRect( 	_input.x - MARG_INT,
							_input.y - MARG_INT,
							_input.width + 2 * MARG_INT,
							_input.height + 2 * MARG_INT );
		
		graphics.drawRect( 	_list.x - MARG_INT,
							_list.y - MARG_INT,
							_list.width + 2 * MARG_INT,
							_list.height + 2 * MARG_INT );
		graphics.endFill();
		
		flash.Lib.current.stage.focus = _input;
		refreshText();
	}
	
}