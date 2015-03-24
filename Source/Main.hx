package;


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.system.Capabilities;
import flash.Lib;
import openfl.Assets;


class Main extends Sprite {
	
	public function new () {
		
		super ();
		
		var pstate = new Tess.PlayField( this );
	}
	
	
}

