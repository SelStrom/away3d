﻿package away3d.textures
{
	import away3d.materials.utils.MipmapGenerator;
	import away3d.tools.utils.TextureUtils;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	
	public class RenderCubeTexture extends CubeTextureBase
	{
		public function RenderCubeTexture(size:Number)
		{
			super();
			setSize(size, size);
		}
		
		public function set size(value:int):void
		{
			if (value == _width)
				return;
			
			if (!TextureUtils.isDimensionValid(value))
				throw new Error("Invalid size: Width and height must be power of 2 and cannot exceed 2048");
			
			invalidateContent();
			setSize(value, value);
		}
		
		override protected function uploadContent(texture:TextureBase):void
		{
			for (var i:int = 0; i < 6; ++i)
				MipmapGenerator.generateMipMaps(MipmapGenerator.getMipMapHolder(_size, _size, false), texture, false, i);
		}
		
		override protected function createTexture(context3D:Context3D):TextureBase
		{
			return context3D.createCubeTexture(_size, Context3DTextureFormat.BGRA, true);
		}
	}
}