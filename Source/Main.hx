package;


import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.system.Capabilities;
import openfl.Lib;
import openfl.Assets;


class Main extends Sprite {
	
	public function new () {
		
		super ();
		
		var pstate = new Tess.PlayField( this );
	}
	
	
}

