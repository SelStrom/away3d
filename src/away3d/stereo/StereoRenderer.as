package away3d.stereo
{
	import away3d.arcane;
	import away3d.core.context3DProxy.Context3DProxy;
	import away3d.core.managers.RTTBufferManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.Debug;
	import away3d.stereo.methods.InterleavedStereoRenderMethod;
	import away3d.stereo.methods.StereoRenderMethodBase;
	import flash.display3D.Context3DClearMask;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;

	use namespace arcane;

	public class StereoRenderer
	{
		private var _leftTexture:Texture;
		private var _rightTexture:Texture;
		
		private var _rttManager:RTTBufferManager;
		private var _program3D:Program3D;
		
		private var _method:StereoRenderMethodBase;
		
		private var _program3DInvalid:Boolean = true;
		private var _leftTextureInvalid:Boolean = true;
		private var _rightTextureInvalid:Boolean = true;
		
		public function StereoRenderer(renderMethod:StereoRenderMethodBase = null)
		{
			_method = renderMethod || new InterleavedStereoRenderMethod();
		}
		
		public function get renderMethod():StereoRenderMethodBase
		{
			return _method;
		}
		
		public function set renderMethod(value:StereoRenderMethodBase):void
		{
			_method = value;
			_program3DInvalid = true;
		}
		
		public function getLeftInputTexture(stage3DProxy:Stage3DProxy):Texture
		{
			if (_leftTextureInvalid) {
				if (!_rttManager)
					setupRTTManager(stage3DProxy);
				
				_leftTexture = stage3DProxy.context3D.createTexture(
					_rttManager.textureWidth, _rttManager.textureHeight, Context3DTextureFormat.BGRA, true);
				_leftTextureInvalid = false;
			}
			
			return _leftTexture;
		}
		
		public function getRightInputTexture(stage3DProxy:Stage3DProxy):Texture
		{
			if (_rightTextureInvalid) {
				if (!_rttManager)
					setupRTTManager(stage3DProxy);
				
				_rightTexture = stage3DProxy.context3D.createTexture(
					_rttManager.textureWidth, _rttManager.textureHeight, Context3DTextureFormat.BGRA, true);
				_rightTextureInvalid = false;
			}
			
			return _rightTexture;
		}
		
		public function render(stage3DProxy:Stage3DProxy):void
		{
			var vertexBuffer:VertexBuffer3D;
			var indexBuffer:IndexBuffer3D;
			var context3DProxy:Context3DProxy;
			
			if (!_rttManager)
				setupRTTManager(stage3DProxy);
			
			stage3DProxy.clearScissorRectangle();
			stage3DProxy.setRenderTarget(null);
			
			context3DProxy = stage3DProxy._context3DProxy;
			vertexBuffer = _rttManager.renderToScreenVertexBuffer;
			indexBuffer = _rttManager.indexBuffer;
			
			_method.activate(stage3DProxy);
			
			context3DProxy.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3DProxy.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			
			context3DProxy.setTextureAt(0, _leftTexture);
			context3DProxy.setTextureAt(1, _rightTexture);
			context3DProxy.setProgram(getProgram3D(stage3DProxy));
			context3DProxy.clear(0.0, 0.0, 0.0, 1.0, 1, 0, Context3DClearMask.ALL);
			context3DProxy.drawTriangles(indexBuffer, 0, 2);
			
			// Clean up
			_method.deactivate(stage3DProxy);
			context3DProxy.setTextureAt(0, null);
			context3DProxy.setTextureAt(1, null);
			context3DProxy.clearVertexBufferAt(0);
			context3DProxy.clearVertexBufferAt(0);
		}
		
		private function setupRTTManager(stage3DProxy:Stage3DProxy):void
		{
			_rttManager = RTTBufferManager.getInstance(stage3DProxy);
			_rttManager.addEventListener(Event.RESIZE, onRttBufferManagerResize);
		}
		
		private function getProgram3D(stage3DProxy:Stage3DProxy):Program3D
		{
			if (_program3DInvalid) {
				var assembler:AGALMiniAssembler;
				var vertexCode:String;
				var fragmentCode:String;
				
				vertexCode = "mov op, va0\n" +
					"mov v0, va0\n" +
					"mov v1, va1\n";
				
				fragmentCode = _method.getFragmentCode();
				
				if (_program3D)
					_program3D.dispose();
				assembler = new AGALMiniAssembler(Debug.active);
				
				_program3D = stage3DProxy.context3D.createProgram();
				_program3D.upload(assembler.assemble(Context3DProgramType.VERTEX, vertexCode),
					assembler.assemble(Context3DProgramType.FRAGMENT, fragmentCode));
				
				_program3DInvalid = false;
			}
			
			return _program3D;
		}
		
		private function onRttBufferManagerResize(ev:Event):void
		{
			_leftTextureInvalid = true;
			_rightTextureInvalid = true;
			_method.invalidateTextureSize();
		}
	}
}
