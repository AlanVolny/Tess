package;


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.Lib;
import openfl.Assets;
import openfl.geom.Rectangle;


typedef Pos  = {x:Int, y:Int, t:Int};

//path types: move, death
typedef Path = {type:String, future:TPiece};



//everything currently in play
class PlayField {

	public var play_boards:Array<Tboard>;
	public var w:Int;
	public var h:Int;
	public var gamedat : GameMetaData;
	public var indics : Array<Indicator>;
	public var selected_piece: TPiece;
	public var multiple_futures: Bool;

	public var display_graphics: Bool;
	public var canvas_sprite: Main;
	public var boardfield_sprite: Sprite;
	public var boards_canvas: Sprite;
	public var boardw: Int;
	public var boardh: Int;
	public var tilesize: Int;
	public static var mf; //main field

	private var board_bmp: BitmapData;
	private var background: BitmapData;
	private var backbutton: Sprite;
	private var forwardbutton: Sprite;
	private var boardfont: TextFormat;
	private var downx_mask: Float;
	private var downx_click: Float;
	public var disp_board_ind: Int;
	public var hasmoved: Bool;
	public var hasmoved_allowance: Float;
	public var piececlicked: Bool;

	public static var debug: Bool;
	public static var recording_moves: Bool;


	public var turn_num: Int;

	public function new(main_sprite:Main) {
		//function parameters: gamefile, boardfile
		debug = false;
		// debug = true;

		//initialization
		mf = this;
		canvas_sprite = main_sprite;
		display_graphics = true;

		tilesize = 32;
		w = 4; h = 5;
		boardw = tilesize*w;
		boardh = tilesize*h;
		multiple_futures = false;
		hasmoved_allowance = 16;
		turn_num = 0;

		//load assets
			//load pieces
		gamedat = new GameMetaData();
			//load board image
		// board_bmp = Assets.getBitmapData( "assets/images/Chessboard4x6.png" );
		board_bmp = Assets.getBitmapData( "assets/images/Chessboard4x5.png" );
			//load background
		background = Assets.getBitmapData( "assets/images/bg.png" );
			//load font
		boardfont = new TextFormat( "assets/mplus-1p-black.ttf", 16, 0xFFFFFF );

			//the chess boards
		boardfield_sprite = new Sprite();
		boardfield_sprite.x = 16; boardfield_sprite.y=16;
		boardfield_sprite.scrollRect = new Rectangle( 0, 0, 1920, 600 );

		boards_canvas = new Sprite();

		boardfield_sprite.addChild( boards_canvas );
		canvas_sprite.addChild( boardfield_sprite );


		// backbutton    = new Sprite(); 
		// forwardbutton = new Sprite(); 
		// backbutton.addChild( new Bitmap(Assets.getBitmapData("assets/images/ArrowLeft.png")) );
		// forwardbutton.addChild(new Bitmap(Assets.getBitmapData("assets/images/ArrowRight.png")));
		// backbutton.x = 16; backbutton.y = tilesize*(h+1);
		// forwardbutton.x = 16+64+16; forwardbutton.y = tilesize*(h+1);
		// boardfield_sprite.addChild(backbutton);
		// boardfield_sprite.addChild(forwardbutton);

		// backbutton.addEventListener(MouseEvent.MOUSE_UP, undo_turn);


		//setup the starting play state

			//setup boards
		var startboard = new Tboard([]);
		play_boards = [ startboard ];
		propogate_board(5);
		selected_piece = null;
		hasmoved = false;
		piececlicked = false;
		indics = [];

			//setup default pieces
		new TPiece( gamedat.pieces[0], 0, {x:0,y:0,t:0}); new TPiece( gamedat.pieces[0], 1, {x:1,y:0,t:0});
		new TPiece( gamedat.pieces[0], 2, {x:2,y:0,t:0}); new TPiece( gamedat.pieces[0], 3, {x:3,y:0,t:0}); 
		new TPiece( gamedat.pieces[1], 0, {x:0,y:4,t:0}); new TPiece( gamedat.pieces[1], 1, {x:1,y:4,t:0}); 
		new TPiece( gamedat.pieces[1], 2, {x:2,y:4,t:0}); new TPiece( gamedat.pieces[1], 3, {x:3,y:4,t:0});

		//display stuff
			//background
		var default_background = new Sprite();
		default_background.graphics.beginBitmapFill(background, null, true, false);
		default_background.graphics.drawRect(0,0,1920,1080);
		canvas_sprite.addChildAt(default_background, 0);
		// default_background.addEventListener(MouseEvent.MOUSE_DOWN, respond);
			//board field
			//show chessboards
		for (bnum in 0...play_boards.length){
			var disp_pos = display_pos({x:0,y:0,t:bnum});
			display_board(disp_pos.x, disp_pos.y, Std.string(bnum));
		}
			//show, propogate pieces
		for (p in startboard.pieces){
			p.propogate(this);
		}
		disp_board_ind = play_boards.length;

		trace("Done generating default board");
		if (PlayField.debug) S.print('Debug messages enabled\n');
		
		recording_moves = true;

		term_display();

		return;
	}


	//propogate last board till we have bnum boards
	public function propogate_board(bnum){
		var pieces_board = play_boards[ play_boards.length - 1 ];

		//create the new boards
		while (play_boards.length < bnum){
			play_boards.push(new Tboard([]));
		}

		//propogate the pieces forward
		for (piece in pieces_board.pieces) {
			piece.propogate(this);
		}
	}

	//print current state to terminal.
	public function term_display() {

		S.print(' --- Tess v0.1 --- \n');

		//print board numbers
		for (bnum in (0...play_boards.length)) {
			S.print(bnum+' ');
			for (p in (0...(w))) S.print('  ');
		}
		S.print('\n');

		//print the boards
		for (row in (0...h)) { 
			for (bnum in (0...play_boards.length)) {


				var board = play_boards[bnum];

				for (column in (0...w) ) {
					var print_piece = null;
					for (p in board.pieces){
						if (p.x==column && p.y==row){
							print_piece = p;
							break;
						}
					}
					if (print_piece!=null){
						S.print( print_piece.dat.display + ' ' );
					}
					else S.print('_ ');

				}
				S.print('  ');
			}
			S.print('\n');
		}
	}


	public function display_board(dispx:Int, dispy:Int, textstring:String){
		
		//image
		var chessb = new Sprite();
		chessb.addChild(new Bitmap( board_bmp ));
		chessb.x = dispx; chessb.y = dispy;
		gamedat.board_bmps.push(chessb);
		//board ind
		var text = new TextField();
		text.defaultTextFormat = boardfont;
		text.selectable = false;
		text.y=-16;

		text.x = boardw/2 - tilesize/2 + 8;
		text.text = textstring;
		chessb.addChild(text);

		boards_canvas.addChildAt( chessb, 0 );


		//mouse events
		chessb.addEventListener(MouseEvent.MOUSE_DOWN, board_onclick);

	}

	public function board_onclick(event:MouseEvent){
		downx_mask = boards_canvas.x - event.stageX;
		downx_click= event.stageX;
		canvas_sprite.addEventListener(MouseEvent.MOUSE_MOVE, board_move);
		canvas_sprite.addEventListener(MouseEvent.MOUSE_UP, board_unclick);
		hasmoved = false;
	}

	public function board_move(event:MouseEvent){
		boards_canvas.x = event.stageX + downx_mask;
		if (boards_canvas.x>0) boards_canvas.x = 0;

		if (Math.abs(downx_click-event.stageX) > hasmoved_allowance)
			hasmoved = true;
	}

	public function board_unclick(event:MouseEvent){
		canvas_sprite.removeEventListener(MouseEvent.MOUSE_MOVE, board_move);
		canvas_sprite.removeEventListener(MouseEvent.MOUSE_UP,   board_unclick);
		if (!hasmoved && !piececlicked){
			remove_indics();
			selected_piece = null;
		}
		piececlicked = hasmoved = false;
	}

	public function in_bounds(px, py, pt) {
		if (pt<0 || pt>=play_boards.length ||
			px<0 || px>=PlayField.mf.w || py<0 || py>=PlayField.mf.h) return false;
		return true;
	}

	//get the piece, if any, at given pos
	public function get_piece(px, py, pt) {
		if (!in_bounds(px,py,pt)) return null;
		var board = play_boards[pt];
		for (p in board.pieces){
			if (p.x==px && p.y==py)
				return p;
		}
		return null;
	}

	public function display_pos(pos:Pos){
		var outpos = {x:0, y:0};
		var gap=16;
		outpos.x = pos.t*(boardw+gap) + pos.x*tilesize;
		outpos.y = pos.y*tilesize + 16;
		return outpos;
	}

	public function remove_indics(){
		for (i in indics){
			boards_canvas.removeChild(i.img);
		}
		indics = [];
	}

	public function undo_turn(event:MouseEvent){
		if (debug) trace('undoing turn');
		if (turn_num==0) return;
		var cur_turn = gamedat.turns[turn_num-1];
		for (change in cur_turn.actions){
			trace('going through turn, changing from', change.new_path.future.pos(), 'to', change.old_path.future.pos());
			var piece = change.base_piece;
			var pathpos = piece.paths.indexOf(change.new_path);
			if (pathpos==-1){
				trace('undoing failed; could not find old path');
				return;
			}
			
			piece.paths[pathpos] = change.old_path;

			change.new_path.future.remove_from_board();
			piece.reinstate();
			piece.propogate(PlayField.mf);

			trace('finished undoing');
		}
		turn_num -= 1;
	}

	public function redo_turn(){

	}

}


//a specifc time slice/frame of the playing board 
class Tboard {

	public var pieces:Array<TPiece>;
	public var imgdat:Bitmap;

	public function new( pieceslist:Array<TPiece> ) {
		if (pieceslist==null) pieceslist = [];

		pieces = [];
	}


	public function print_pieces(){
		for (p in pieces){
			Sys.print(p.dat.name + Std.string(p.pnum) + Std.string([p.x,p.y,p.t]));
			for (path in p.paths)
				Sys.print(' ' + path.type);
			Sys.print(' ; ');
		}
		Sys.println('\n');
	}
}


class TPiece {

	public var x:Int; public var y:Int; public var t:Int;
	var prev:  TPiece;
	public var paths: Array<Path>;
	var in_play: Bool;
	var displayed: Bool;
	public var is_removed: Bool;
	public var dat: PieceDat;
	public var img: Sprite;
	public var pnum:Int;
	public var victim: TPiece;


	public function new(pdat, piecenum, ?ppos=null) {
		dat = pdat;
		pnum = piecenum;
		prev = null;
		paths = [];
		img = null;
		is_removed = false;
		in_play = true;
		displayed = false;
		victim = null;

		if (ppos!=null){
			x=ppos.x; y=ppos.y; t=ppos.t;
			place(ppos);
		}
		else {
			x=-1; y=-1; t=-1;
		}

	}

	public function propogate(pfield:PlayField){

		if (!in_play) return;

		if (PlayField.debug==true)trace('propogate', dat.color, pnum ,' at',x,y,t);

		if (PlayField.mf.display_graphics)
			display();

		//if no future, make new future
		if (paths.length==0){
			if (PlayField.debug==true) S.print('\tgiving a future\n');

			var fpos = {x:x,y:y,t:t+1};
			if (!PlayField.mf.in_bounds(fpos.x, fpos.y, fpos.t))
				return;
			move_to(fpos);
			return;
		}

		var future = paths[ paths.length-1 ].future;

		if (PlayField.debug==true) 
			if (future==null) trace('propogating a null, futurepath type is', paths[ paths.length-1 ].type, 'at',x,y,t);
		if (future==null) return;


		//reinstate future
		var deadfuture = should_be_dead();
		if (!deadfuture && future.in_play==false){
			future.in_play = true;
			future.place( future.pos() );
		}

		future.propogate(pfield);
	}

	public function reinstate(){
		in_play = true;
		is_removed = false;

		if (paths.length==0) return;
		var path = paths[paths.length-1];
		if (path.type=='death')
			path.future.in_play = true;
		if (path.type=='death' || path.future==null)
			return;
		path.future.reinstate();
	}

	public function move_to(pos){
		var pfield = PlayField.mf;

		//erase any existing future
		var prev_path;
		if (paths.length>0){
			prev_path = paths[paths.length-1];
			prev_path.future.remove_from_board();
		}
		else prev_path = null;

		//make new piece
		var newpiece = new TPiece(dat, pnum);
		var newpath = newpiece.place(pos);
		paths.push( newpath );

		if (prev_path!=null){
			var pd = new PathDelta(this, prev_path, newpath);
			pd.add_to_turn();
		}

		newpiece.propogate(PlayField.mf);
	}

	//places piece onto board, killing any currently on that spot. Returns path to get to this piece
	public function place(pos:Pos):Path{
		if (!PlayField.mf.in_bounds(pos.x,pos.y,pos.t)){ trace("IMPOSSIBLE"); return null; }

		x=pos.x; y=pos.y; t=pos.t;
		
		//kill any existing unit.
		victim = PlayField.mf.get_piece(pos.x,pos.y,pos.t);
		if (victim!=null){
			if (PlayField.debug==true){trace("killing unit", victim.dat.color, victim.pnum, ' at ',pos.x,pos.y,pos.t,
				' from ',dat.color, pnum, x,y,t);}
			kill_piece( victim );
		}

		//place piece on board
		PlayField.mf.play_boards[t].pieces.push(this);

		//get path to this piece
		var path = {type:"move", future:this};

		return path;
	}


	//remove from board. Can come back if asked
	public function remove_from_board() {
		in_play = false;
		displayed = false;
		if (PlayField.debug==true)trace('removing from board at ', x, y, t);
		if (PlayField.mf.multiple_futures==false){
			PlayField.mf.play_boards[t].pieces.remove(this);
			PlayField.mf.boards_canvas.removeChild(img);
			img = null;
			displayed = false;
			for (p in paths){
				destroy_path(p);
			}
			if (victim!=null)
				victim.unkill();
			// paths = [];
			return;
		}

		if (PlayField.debug==true)trace('rm: MF not yet implemented');
	}

	public function kill_piece(victim:TPiece) {
		if (PlayField.debug==true)trace('killing unit at ', x,y,t);
		var deathpath = {type:'death', future:this};

		var past = victim.get_past();
		var curpath = past.paths[past.paths.length-1];
		// curpath.future.remove_from_board();
		var PD = new PathDelta(past, curpath, deathpath);
		PD.add_to_turn();

		victim.remove_from_board();
		past.paths.push( deathpath );
	}

	public function unkill(){
		if (is_removed) return;
		if (PlayField.debug==true) trace('unkilling piece at ', x, y, t);
		in_play = true;
		var past = get_past();
		if (past.paths[ past.paths.length-1 ].type=='death' ){
			past.paths.pop();
		}
		else if (PlayField.debug){
			trace("that's weird"); 
			return; 
		}
		place( pos() );
		propogate(PlayField.mf);
	}

	//recursively free/destroy this piece. This piece ain't comin back
	public static function destroy_path(path:Path) {
		var pfield = PlayField.mf;

		if (path==null) return;

		var future = path.future;
		if (future!=null) {

			//remove from play
			future.remove_from_board();

			//clean up
			pfield.boards_canvas.removeChild(future.img);
			future.is_removed = true;
			future.img=null;

			for (subpath in future.paths){
				destroy_path(subpath);
			}
			future.paths=[];
		}
	}

	public function should_be_dead() {
		var past = get_past();
		if (past==null) return false; //assumes is progenitor piece. stopgap
		return (past.paths[past.paths.length-1].type=='death');
	}

	public function on_unclick(event:Event){
		if (PlayField.mf.hasmoved)
			return;

		if (this==PlayField.mf.selected_piece){
			PlayField.mf.selected_piece = null;
			PlayField.mf.remove_indics();
			return;
		}

		if (PlayField.mf.selected_piece!=null){
			PlayField.mf.selected_piece = null;
			PlayField.mf.remove_indics();
		}

		PlayField.mf.piececlicked = true;

		PlayField.mf.selected_piece = this;

		PlayField.mf.indics.push(new Indicator('selected',x,y,t));
		mark_selected(PlayField.mf);
	}


		//mark available moves
	public function mark_selected(pfield:PlayField) {

		for (m in dat.moves) {
			var mx = x; var my = y; var mt = t;
			mt += m[4];
			var occupying=null;
			do {
				mx += m[0]; my += m[1]; mt += m[2];
				if (!pfield.in_bounds(mx,my,mt)) break;
				var occupying = pfield.get_piece(mx, my, mt);

				if (occupying!=null){
					if (PlayField.debug==true || ( //))
						 occupying.dat.color != this.dat.color ) )
						pfield.indics.push( new Indicator('killmove', mx, my, mt) );
				}
				else {
					pfield.indics.push( new Indicator('canmove', mx, my, mt) );
				}

			} while (m[3]==1 && occupying==null);
		}

		mark_future();
	}

	public function mark_future(){
		var curnum = 1;
		var curpiece = get_future();
		while (curpiece!=null && curpiece.is_removed==false){
			PlayField.mf.indics.push( new Indicator('futureshow', curpiece.x,curpiece.y,curpiece.t, Std.string(curnum)) );
			curpiece = curpiece.get_future();
			if (curpiece==this){ if (PlayField.debug==true)trace('hum'); break; }
		}
	}

	public function get_past(): TPiece {

		if (t==0) return null;
		for (p in PlayField.mf.play_boards[t-1].pieces){
			if (p.dat==dat && p.pnum==pnum){
				return p;
			}
		}
		trace('get_past returning null! at',x,y,t);
		return null;
	}

	public function pos():Pos {
		return {x:x,y:y,t:t};
	}

	public function path_to(): Path {
		var past = get_past();
		return past.paths[past.paths.length-1];
	}

	public function get_future(): TPiece {
		if (paths.length==0) return null;
		return paths[paths.length-1].future;
	}


	public function display() {
		if (img!=null && displayed==false){
			PlayField.mf.boards_canvas.addChild(img);
			displayed = true;
			return;
		}
		img = new Sprite();

		img.addChild(new Bitmap(dat.bmp));

		var bgtxt = new TextField();
		bgtxt.defaultTextFormat = dat.bgfont;
		bgtxt.selectable = false;
		bgtxt.x = 16; bgtxt.y = 16; bgtxt.width=16; bgtxt.height=18;
		bgtxt.text = Std.string(pnum);
		img.addChild(bgtxt);


		var txt = new TextField();
		txt.defaultTextFormat = dat.font;
		txt.selectable = false;
		txt.x = 17; txt.y = 17; txt.width=12; txt.height=18;
		txt.text = Std.string(pnum);
		img.addChild(txt);

		var disp_pos = PlayField.mf.display_pos( {x:x,y:y,t:t} );
		img.x = disp_pos.x; img.y = disp_pos.y;
		PlayField.mf.boards_canvas.addChild(img);
		img.addEventListener (MouseEvent.MOUSE_UP,   on_unclick);
		img.addEventListener (MouseEvent.MOUSE_DOWN, PlayField.mf.board_onclick);
		displayed = true;

	}
}


//general data about a piece
class PieceDat {

	public var color : String; 
	public var name  : String;
	public var display:String;
	public var moves : Array<Array<Int>>;
	public var font  : TextFormat;
	public var bgfont: TextFormat;

	public var bmp   :BitmapData;


	//color, name, moves: moves is a list of [+x, +y, +z, repeating]
	public function new( pcolor:String, pname:String, pdisplay, pmoves, imgfile, fontfile, bgfontfile) {
		color   = pcolor;
		name    = pname;
		display = pdisplay;
		moves   = pmoves;
		bmp     = Assets.getBitmapData(imgfile);
		font    = new flash.text.TextFormat(   fontfile, 12, 0xFFFFFF );
		font.leading = 0;
		bgfont  = new flash.text.TextFormat( bgfontfile, 16, 0x000000 );
	}
}


class Indicator {
	public var pos:Pos;
	public var name:String;
	public var img:Sprite;

	public function new(iname, px, py, pt, ?txt=null){
		if (!PlayField.mf.in_bounds(px,py,pt)) return;
		var name = iname;
		pos = {x:px,y:py,t:pt};


		img = new Sprite();
		if (name=='selected'){
			img.graphics.beginFill(0x00FF00, 0.5);
		}
		else if (name=='canmove'){
			img.graphics.beginFill(0x08FF08, 0.3);
			img.addEventListener( MouseEvent.MOUSE_UP, move_to_indic );
		}
		else if (name=='killmove'){
			img.graphics.beginFill(0xFF0000, 0.5);
			img.addEventListener( MouseEvent.MOUSE_UP, move_to_indic );
		}
		else if (name=='futureshow'){
			img.graphics.lineStyle(3, 0x000000, 0.3, true);
			img.graphics.drawRoundRect(0, 0, 32, 32, 12, 12);
			img.mouseEnabled = false;
		}
		img.graphics.drawRect(0,0,32,32);
		var disp_pos = PlayField.mf.display_pos(pos);
		img.x = disp_pos.x; img.y = disp_pos.y;
		if (name=='futureshow')
			PlayField.mf.boards_canvas.addChildAt( img, PlayField.mf.disp_board_ind );
		else
			PlayField.mf.boards_canvas.addChild( img );

		img.addEventListener( MouseEvent.MOUSE_DOWN, PlayField.mf.board_onclick );
	}

	public function move_to_indic(event:Event){
		if (PlayField.mf.hasmoved) return;
		if (PlayField.debug) S.print('\n');

		PlayField.mf.selected_piece.move_to( pos );
		PlayField.mf.selected_piece = null;
		PlayField.mf.remove_indics();

		if (PlayField.debug){
			PlayField.mf.term_display();
			PlayField.mf.gamedat.print_actions();
		}

		//start new turn
		var turns = PlayField.mf.gamedat.turns;
		while ( PlayField.mf.gamedat.turns.length-1 > PlayField.mf.turn_num)
			PlayField.mf.gamedat.turns.pop();
		var newturn_num = turns[ turns.length-1 ].num+1;
		PlayField.mf.turn_num += 1;
		turns.push( new TurnData( newturn_num ) );
		trace(' --- turn ' + PlayField.mf.turn_num + ' --- ');
	}

}

class PathDelta {
	public var base_piece:TPiece;
	public var old_path:Path;
	public var new_path:Path;

	public function new(piece, oldp, newp){
		base_piece = piece;
		old_path = oldp;
		new_path = newp;
	}

	public function add_to_turn(){
		var turns = PlayField.mf.gamedat.turns;
		var turn_num = turns[turns.length-1];
		turn_num.actions.push(this);
	}
}


//all the actions that happened during a turn
class TurnData {
	public var num: Int;
	public var actions:Array<PathDelta>;

	public function new(turn_num:Int){
		num = turn_num;
		actions = [];
	}
}


//general data: past moves, data of all playable pieces, etc.
class GameMetaData {

	public var board_bmps:Array<Sprite>;
	public var pieces:Array<Dynamic>;

	public var turns:Array<TurnData>;

	public function new() {
		load_default_pieces();
		board_bmps = [];
	}

	public function load_default_pieces() {

		pieces = [];
		turns  = [new TurnData(0)];

		//Piece move:
		// [xmove, ymove, tmove, whether_recursive, time_offset]
		//  whether_recursive means whether the move extends in xmove, ymove, tmove direction indefinetely 

		//rooks
		// var bpawn_moves = [[0,1,0,1,1], [0,-1,0,1,1], [1,0,0,1,1], [-1,0,0,1,1] ];
		// var wpawn_moves = bpawn_moves;

		//standard variation
		var bpawn_moves = [[-1, 1,0,0,1], [0, 1,0,0,1], [1, 1,0,0,1]];
		var wpawn_moves = [[-1,-1,0,0,1], [0,-1,0,0,1], [1,-1,0,0,1]];

		//sideways pawns. For testing
		// var bpawn_moves = [[-1, 1,1,0], [0, 1,1,0], [1, 1,1,0], [1,0,1,0], [-1,0,1,0]];
		// var wpawn_moves = [[-1,-1,1,0], [0,-1,1,0], [1,-1,1,0], [1,0,1,0], [-1,0,1,0]];

		//temporaly retarded pawns
		// var bpawn_moves = [[-1, 1,0,0], [0, 1,0,0], [1, 1,0,0]];
		// var wpawn_moves = [[-1,-1,0,0], [0,-1,0,0], [1,-1,0,0]];

		//temporaly confused pawns
		// var bpawn_moves = [[-1, 1,-1,0], [0, 1,-1,0], [1, 1,-1,0]];
		// var wpawn_moves = [[-1,-1,-1,0], [0,-1,-1,0], [1,-1,-1,0]];

		if (PlayField.debug) bpawn_moves.push([-1,0,0,0,1]);
		if (PlayField.debug) bpawn_moves.push([ 1,0,0,0,1]);
		if (PlayField.debug) wpawn_moves.push([-1,0,0,0,1]);
		if (PlayField.debug) wpawn_moves.push([ 1,0,0,0,1]);


		pieces.push( new PieceDat('B', 'BlackPawn', '♟', bpawn_moves, 
			"assets/images/BlackPawn.png", "assets/mplus-1c-heavy.ttf", "assets/mplus-1c-heavy.ttf") ) ;
		pieces.push( new PieceDat('W', 'WhitePawn', '♙', wpawn_moves, 
			"assets/images/WhitePawn.png", "assets/mplus-1c-heavy.ttf", "assets/mplus-1c-heavy.ttf") ) ;
		// pieces.push( new PieceDat('B', 'BlackPawn', '♟', bpawn_moves, 
		// 	"assets/images/black_hnefetafl.png", "assets/mplus-1c-heavy.ttf", "assets/mplus-1c-heavy.ttf") ) ;
		// pieces.push( new PieceDat('W', 'WhitePawn', '♙', wpawn_moves, 
		// 	"assets/images/white_hnefetafl.png", "assets/mplus-1c-heavy.ttf", "assets/mplus-1c-heavy.ttf") ) ;
	}

	public function print_actions() {
		Sys.print("Printing turns\n");
		for (t in 0...turns.length){
			var turn = turns[t];
			Sys.print('turn:' + Std.string(t)+'\n');
			for (a in turn.actions){
				Sys.print('\t');
				Sys.print('\taction:' + a.base_piece.dat.color + Std.string(a.base_piece.pnum) + Std.string(a.base_piece.pos()));
				Sys.print(':  ');
				if (a.old_path==null)
					Sys.print(', null');
				else if (a.old_path.future==null)
					Sys.print(Std.string(a.old_path));
				else
					Sys.print(a.old_path.type + ' ' + a.old_path.future.dat.color +
						Std.string(a.old_path.future.pnum) +' '+ Std.string(a.old_path.future.pos()));
				Sys.print(', ');
				if (a.new_path==null)
					Sys.print(', null');
				else if (a.new_path.future==null)
					Sys.print(Std.string(a.new_path));
				else
					Sys.print(a.new_path.type + ' ' + a.new_path.future.dat.color +
						Std.string(a.new_path.future.pnum) +' '+ Std.string(a.new_path.future.pos()));
				Sys.print('\n');
			}
		}
	}

}


class S {

	public static function print(stuffA){
		Sys.print(stuffA);
	}
}

