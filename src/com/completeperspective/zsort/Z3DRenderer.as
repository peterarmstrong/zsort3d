package com.completeperspective.zsort
{
	import flash.utils.Timer;
	import flash.events.*;
	import flash.display.Sprite;
	/**
	 *  Renders a collection of ZSortable objects in 3D Space,
	 *  implements Factory Design Pattern.
	 */
	public class Z3DRenderer extends Sprite
	{
		private var _canvas : Sprite
		private var _canvasWidth : Number;
		private var _canvasHeight : Number;
		private var _data : Array;
		//private var _updater : Timer;
		private var _centerX : Number = 0;
 		private var _centerY : Number = 0;
		private var _currentX : Number = 0;
		private var _currentY : Number = 0;
		private var _diffX : Number = 0;
		private var _diffY : Number = 0;
		private var _offsetY : Number = 0;
		private var _offsetX : Number = 0;
		private var _addX : Number = 0;
		private var _addY : Number = 0;
		private var _angleX : Number = 0;
		private var _angleY : Number = 0;
		private var _perspective : Number = 150;
		private var _mouseDrag : Boolean = false;
		private var _depths : Array = new Array();
		
		public function get currentX() : Number { return _currentX; }
		public function set currentX( x : Number ) : void { _currentX = x; }
		
		public function get currentY() : Number { return _currentY; }
		public function set currentY( y : Number ) : void { _currentY = y; }
		
		public function Z3DRenderer( w : Number, h : Number, data : Array ) 
		{
			// set required vars for new instance
			_canvasWidth = w;
			_canvasHeight = h;
			_centerX = w / 2;
			_centerY = h / 2;
			_data = data;
			init();
		}
		
		private function init() : void
		{
			// create 3D stage
			draw();
			// react to user gestures
			registerEvents();
			
		}
				
		private function draw() : void
		{
			// draw the display stage
			//_canvas = new Sprite();
			// fill the stage trap user gestures of this instance
			//_canvas.graphics.beginFill(0xFFFFFF, 0);
			//_canvas.graphics.drawRect(0, 0, _canvasWidth, _canvasHeight);
			
			// add display objects from dataProvider to display list
			// set initial positions randomly
			var c : Number = 0;
			while (c < _data.length) {
				_data[c]._xnum = int(Math.random() * 200)-100;
				_data[c]._ynum = int(Math.random() * 200)-100;
				_data[c]._znum = int(Math.random() * 200)-100;
				_depths[c] = c
				addChild( _data[c] );
				c++;
			}
			
			// add the 3D stage to display list
			//addChild(_canvas);
			
		}
		
		private function registerEvents() : void
		{
			// register stage to listen for user gestures
			//addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			//addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			//addEventListener(MouseEvent.MOUSE_UP, onMouseUp)
			addEventListener(Event.ENTER_FRAME, onUpdateEvent);
		}
		
		private function onUpdateEvent( e : Event ) : void
		{
			// consider user gestures,
			calculateDelta();
		}
		
		private function onMouseMove( e : MouseEvent ) : void
		{
			// if user is draging mouse, update current x and y vars
			if(_mouseDrag) {
				_currentX = e.localX;
				_currentY = e.localY;
			}
		}
		
		private function onMouseDown( e : MouseEvent ) : void
		{
			// set mouse down toggle
			_mouseDrag = true;
		}
		
		private function onMouseUp( e : MouseEvent ) : void
		{
			// user released, untoggle mouse down
			_mouseDrag = false;
		}
		
		private function calculateDelta() : void
		{
			// calculate the distance and direction of the users cursor
			_diffX = _currentX - _offsetX;
			_diffY = _currentY - _offsetY;
			_offsetX += _diffX / 20;
			_offsetY += _diffY / 20;
			if (_offsetX > 0) {
				_addX = int(_offsetX/360) * - 360;
			} else {
				_addX = (int(_offsetX/360) -1) * - 360;
			}
			if (_offsetY > 0) {
				_addY = int(_offsetY/360) * - 360;
			} else {
				_addY = (int(_offsetY/360) -1) * - 360;
			}
			// angles for movement
			_angleY = (_offsetX + _addX);
			_angleX = (_offsetY + _addY);
			// render display objects		
			render3DStage();
		}
		
		private function render3DStage() : void
		{
			var c : Number = 0;
			while (c < _data.length) {
				var angX : Number = _angleX * ( Math.PI / 180 );
				var angY : Number = _angleY * ( Math.PI / 180 );
				// calculate x plane
				_data[c]._xpos = _data[c]._znum * Math.sin(angY)  + _data[c]._xnum * Math.cos(angY);
				// update z plane
				_data[c]._zpos = _data[c]._znum * Math.cos(angY)  - _data[c]._xnum * Math.sin(angY);
				// calculate y plane
				_data[c]._ypos = _data[c]._ynum * Math.cos(angX)  - _data[c]._zpos * Math.sin(angX);
				// update z plane
				_data[c]._zpos = _data[c]._ynum * Math.sin(angX)  + _data[c]._zpos * Math.cos(angX);
				// simulate depth
				_depths[c] = (1 / ((_data[c]._zpos / _perspective ) + 1));
				// render display object
				_data[c].x = _data[c]._xpos * _depths[c] + _centerX;
				_data[c].y = _data[c]._ypos * _depths[c] + _centerY;
				_data[c].scaleX = _data[c].scaleY = _depths[c] * .15; // 1.75;
				_data[c].alpha = _depths[c] / 1.75;
				c++;		
			}
			// DO2D : display object dynamic depth based on scale
			_data.sortOn("scaleX", Array.NUMERIC);
			_data.sortOn("scaleY", Array.NUMERIC);
			var i:int = _data.length;
			while(i--){
				// adjust display list index
				if (getChildAt(i) != _data[i]) {
			    	setChildIndex(_data[i], i);
			    }
			}
		}
	}
}