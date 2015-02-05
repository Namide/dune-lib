package dl.socket.client ;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.ui.Keyboard;

/**
 * ...
 * @author Namide
 */
class SockClientUI extends Sprite
{
	public static var MARG_EXT:Int = 32;
	public static var MARG_INT:Int = 16;
	public static var LIST_LARG:Int = 256;
	
	public var sendMsg:String->Void;
	
	var _input:TextField;
	var _output:TextField;
	var _list:TextField;
	
	public function new() 
	{
		super();
		
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
	
	public inline function clear()
	{
		_output.text = '';
		_list.htmlText = "";
	}
	
	public inline function appendText( t:String )
	{
		_output.htmlText += t + "</br>";
		refreshText();
	}
	
	public inline function refreshUsers( t:String )
	{
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