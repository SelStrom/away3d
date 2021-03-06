package away3d.controllers
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.math.*;
	import away3d.entities.*;
	import flash.geom.Vector3D;
	
	use namespace arcane;
	
	/**
	 * Extended camera used to hover round a specified target object.
	 *
	 * @see    away3d.containers.View3D
	 */
	public class HoverController extends LookAtController
	{
		arcane var _currentPanAngle:Number = 0;
		arcane var _currentTiltAngle:Number = 90;
		
		private var _panAngle:Number = 0;
		private var _tiltAngle:Number = 90;
		private var _distance:Number = 1000;
		private var _minPanAngle:Number = -Infinity;
		private var _maxPanAngle:Number = Infinity;
		private var _minTiltAngle:Number = -90;
		private var _maxTiltAngle:Number = 90;
		private var _steps:uint = 8;
		private var _yFactor:Number = 2;
		private var _wrapPanAngle:Boolean;
		private var _pos:Vector3D = new Vector3D();
		
		/**
		 * Fractional step taken each time the <code>hover()</code> method is called. Defaults to 8.
		 *
		 * Affects the speed at which the <code>tiltAngle</code> and <code>panAngle</code> resolve to their targets.
		 *
		 * @see    #tiltAngle
		 * @see    #panAngle
		 */
		public function get steps():uint
		{
			return _steps;
		}
		
		public function set steps(value:uint):void
		{
			value = Math.max(value, 1);
			if (_steps == value)
				return;
			
			_steps = value;
			notifyUpdate();
		}
		
		/**
		 * Rotation of the camera in degrees around the y axis. Defaults to 0.
		 */
		public function get panAngle():Number
		{
			return _panAngle;
		}
		
		public function set panAngle(value:Number):void
		{
			value = Math.max(_minPanAngle, Math.min(_maxPanAngle, value));
			
			if (_panAngle == value)
				return;
			
			_panAngle = value;
			
			notifyUpdate();
		}
		
		/**
		 * Elevation angle of the camera in degrees. Defaults to 90.
		 */
		public function get tiltAngle():Number
		{
			return _tiltAngle;
		}
		
		public function set tiltAngle(value:Number):void
		{
			value = Math.max(_minTiltAngle, Math.min(_maxTiltAngle, value));
			
			if (_tiltAngle == value)
				return;
			
			_tiltAngle = value;
			
			notifyUpdate();
		}
		
		/**
		 * Distance between the camera and the specified target. Defaults to 1000.
		 */
		public function get distance():Number
		{
			return _distance;
		}
		
		public function set distance(value:Number):void
		{
			if (_distance == value)
				return;
			
			_distance = value;
			
			notifyUpdate();
		}
		
		/**
		 * Minimum bounds for the <code>panAngle</code>. Defaults to -Infinity.
		 *
		 * @see    #panAngle
		 */
		public function get minPanAngle():Number
		{
			return _minPanAngle;
		}
		
		public function set minPanAngle(value:Number):void
		{
			if (_minPanAngle == value)
				return;
			
			_minPanAngle = value;
			
			panAngle = Math.max(_minPanAngle, Math.min(_maxPanAngle, _panAngle));
		}
		
		/**
		 * Maximum bounds for the <code>panAngle</code>. Defaults to Infinity.
		 *
		 * @see    #panAngle
		 */
		public function get maxPanAngle():Number
		{
			return _maxPanAngle;
		}
		
		public function set maxPanAngle(value:Number):void
		{
			if (_maxPanAngle == value)
				return;
			
			_maxPanAngle = value;
			
			panAngle = Math.max(_minPanAngle, Math.min(_maxPanAngle, _panAngle));
		}
		
		/**
		 * Minimum bounds for the <code>tiltAngle</code>. Defaults to -90.
		 *
		 * @see    #tiltAngle
		 */
		public function get minTiltAngle():Number
		{
			return _minTiltAngle;
		}
		
		public function set minTiltAngle(value:Number):void
		{
			if (_minTiltAngle == value)
				return;
			
			_minTiltAngle = value;
			
			tiltAngle = Math.max(_minTiltAngle, Math.min(_maxTiltAngle, _tiltAngle));
		}
		
		/**
		 * Maximum bounds for the <code>tiltAngle</code>. Defaults to 90.
		 *
		 * @see    #tiltAngle
		 */
		public function get maxTiltAngle():Number
		{
			return _maxTiltAngle;
		}
		
		public function set maxTiltAngle(value:Number):void
		{
			if (_maxTiltAngle == value)
				return;
			
			_maxTiltAngle = value;
			
			tiltAngle = Math.max(_minTiltAngle, Math.min(_maxTiltAngle, _tiltAngle));
		}
		
		/**
		 * Fractional difference in distance between the horizontal camera orientation and vertical camera orientation. Defaults to 2.
		 *
		 * @see    #distance
		 */
		public function get yFactor():Number
		{
			return _yFactor;
		}
		
		public function set yFactor(value:Number):void
		{
			if (_yFactor == value)
				return;
			
			_yFactor = value;
			
			notifyUpdate();
		}
		
		/**
		 * Defines whether the value of the pan angle wraps when over 360 degrees or under 0 degrees. Defaults to false.
		 */
		public function get wrapPanAngle():Boolean
		{
			return _wrapPanAngle;
		}
		
		public function set wrapPanAngle(value:Boolean):void
		{
			if (_wrapPanAngle == value)
				return;
			
			_wrapPanAngle = value;
			
			notifyUpdate();
		}
		
		/**
		 * Creates a new <code>HoverController</code> object.
		 */
		public function HoverController(targetObject:Entity = null, lookAtObject:ObjectContainer3D = null, panAngle:Number = 0, tiltAngle:Number = 90, distance:Number = 1000, minTiltAngle:Number = -90, maxTiltAngle:Number = 90, minPanAngle:Number = NaN, maxPanAngle:Number = NaN, steps:uint = 8, yFactor:Number = 2, wrapPanAngle:Boolean = false)
		{
			super(targetObject, lookAtObject);
			
			this.distance = distance;
			this.panAngle = panAngle;
			this.tiltAngle = tiltAngle;
			this.minPanAngle = minPanAngle || -Infinity;
			this.maxPanAngle = maxPanAngle || Infinity;
			this.minTiltAngle = minTiltAngle;
			this.maxTiltAngle = maxTiltAngle;
			this.steps = steps;
			this.yFactor = yFactor;
			this.wrapPanAngle = wrapPanAngle;
			
			//values passed in contrustor are applied immediately
			_currentPanAngle = _panAngle;
			_currentTiltAngle = _tiltAngle;
		}
		
		/**
		 * Updates the current tilt angle and pan angle values.
		 *
		 * Values are calculated using the defined <code>tiltAngle</code>, <code>panAngle</code> and <code>steps</code> variables.
		 *
		 * @param interpolate   If the update to a target pan- or tiltAngle is interpolated. Default is true.
		 *
		 * @see    #tiltAngle
		 * @see    #panAngle
		 * @see    #steps
		 */
		public override function update(interpolate:Boolean = true):void
		{
			if (_tiltAngle != _currentTiltAngle || _panAngle != _currentPanAngle) {
				
				notifyUpdate();
				
				if (_wrapPanAngle) {
					if (_panAngle < 0) {
						_currentPanAngle += _panAngle%360 + 360 - _panAngle;
						_panAngle = _panAngle%360 + 360;
					} else {
						_currentPanAngle += _panAngle%360 - _panAngle;
						_panAngle = _panAngle%360;
					}
					
					while (_panAngle - _currentPanAngle < -180)
						_currentPanAngle -= 360;
					
					while (_panAngle - _currentPanAngle > 180)
						_currentPanAngle += 360;
				}
				
				if (interpolate) {
					_currentTiltAngle += (_tiltAngle - _currentTiltAngle)/(steps + 1);
					_currentPanAngle += (_panAngle - _currentPanAngle)/(steps + 1);
				} else {
					_currentPanAngle = _panAngle;
					_currentTiltAngle = _tiltAngle;
				}
				
				//snap coords if angle differences are close
				if ((Math.abs(tiltAngle - _currentTiltAngle) < 0.01) && (Math.abs(_panAngle - _currentPanAngle) < 0.01)) {
					_currentTiltAngle = _tiltAngle;
					_currentPanAngle = _panAngle;
				}
			}

			if(!_targetObject) return;

			if (_lookAtPosition) {
				_pos.x = _lookAtPosition.x;
				_pos.y = _lookAtPosition.y;
				_pos.z = _lookAtPosition.z;
			} else if (_lookAtObject) {
				if(_targetObject.parent && _lookAtObject.parent) {
					if(_targetObject.parent != _lookAtObject.parent) {// different spaces
						_pos.x = _lookAtObject.scenePosition.x;
						_pos.y = _lookAtObject.scenePosition.y;
						_pos.z = _lookAtObject.scenePosition.z;
						Matrix3DUtils.transformVector(_targetObject.parent.inverseSceneTransform, _pos, _pos);
					}else{//one parent
						Matrix3DUtils.getTranslation(_lookAtObject.transform, _pos);
					}
				}else if(_lookAtObject.scene){
					_pos.x = _lookAtObject.scenePosition.x;
					_pos.y = _lookAtObject.scenePosition.y;
					_pos.z = _lookAtObject.scenePosition.z;
				}else{
					Matrix3DUtils.getTranslation(_lookAtObject.transform, _pos);
				}
			}else{
				_pos.x = _origin.x;
				_pos.y = _origin.y;
				_pos.z = _origin.z;
			}

			_targetObject.x = _pos.x + _distance*Math.sin(_currentPanAngle*MathConsts.DEGREES_TO_RADIANS)*Math.cos(_currentTiltAngle*MathConsts.DEGREES_TO_RADIANS);
			_targetObject.z = _pos.z + _distance*Math.cos(_currentPanAngle*MathConsts.DEGREES_TO_RADIANS)*Math.cos(_currentTiltAngle*MathConsts.DEGREES_TO_RADIANS);
			_targetObject.y = _pos.y + _distance*Math.sin(_currentTiltAngle*MathConsts.DEGREES_TO_RADIANS)*_yFactor;
			super.update();
		}
	}
}
