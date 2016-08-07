package utils
{
	import flash.display.BitmapData;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	
	public class Bicubic
	{
		/**
		 * Resize an Image with bicubic interpolation
		 * @param width the new desired width
		 * @param height the new desired height
		 * @param bitmapData the original sized BitmapData
		 * @return
		 */
		public static function interpolateBicubic(bitmapData:BitmapData, width:int, height:int):BitmapData
		{
			// same size no need to resize
			if( width == bitmapData.width && height == bitmapData.height )
			{
				return bitmapData.clone();
			}
			
			var interpolated    :BitmapData = new BitmapData( width, height, true, 0x00000000 );
			var original_copy   :BitmapData = bitmapData.clone();
			
			var xFactor:Number = bitmapData.width / interpolated.width;
			var yFactor:Number = bitmapData.height / interpolated.height;
			
			if (xFactor > 1 || yFactor > 1)
				original_copy.applyFilter(original_copy, original_copy.rect, new Point(0, 0), new BlurFilter(1.4*(xFactor/2),1.4*(yFactor/2),BitmapFilterQuality.HIGH));
			
			var step:int = 0;
			while ( step < interpolated.width )
			{
				for (var y:int = 0; y < interpolated.height; y++){
					interpolated.setPixel32(step, y, getPixelBicubic32(step * xFactor, y * yFactor, original_copy));
				}
				step++;
			}
			
			return interpolated;
		}
		
		private static function getPixelBicubic32( x:Number, y:Number, bitmapData:BitmapData ):Number
		{
			var i:int = int(x);
			var j:int = int(y);
			
			if (((i - 1) < 0) || ((j - 1) < 0))
				return bitmapData.getPixel32(i, j);
			else if (((i + 1) >= bitmapData.width) || ((i + 2) >= bitmapData.width) ||
				((j + 1) >= bitmapData.height) || ((j + 2) >= bitmapData.height))
				return bitmapData.getPixel32(i, j);
			
			var dx  :Number = x - i;
			var dy  :Number = y - j;
			var asum:Number = 0;
			var rsum:Number = 0;
			var gsum:Number = 0;
			var bsum:Number = 0;
			
			var Rmdx:Array = new Array(4);
			var Rdyn:Array = new Array(4);
			for( var m:int = -1; m <= 2; ++m )
				Rmdx[m + 1] = A(m - dx);
			for( var n:int = -1; n <= 2; ++n )
				Rdyn[n + 1] = A(dy - n);
			
			for( m = -1; m <= 2; ++m )
			{
				for (n = -1; n <= 2; ++n)
				{
					var rgb :int = bitmapData.getPixel32(i + m, j + n);
					var a   :int = (rgb >> 24) & 0x0FF;
					var r   :int = (rgb >> 16) & 0x0FF;
					var g   :int = (rgb >>  8) & 0x0FF;
					var b   :int = (rgb >>  0) & 0x0FF;
					
					var Rres:Number = Rmdx[m + 1] * Rdyn[n + 1];
					asum += a * Rres;
					rsum += r * Rres;
					gsum += g * Rres;
					bsum += b * Rres;
				}
			}
			
			var alpha:int = (int)(asum + 0.5);
			if(alpha < 0)
				alpha = 0;
			else if(alpha > 255)
				alpha = 255;
			
			var red:int = (int)(rsum + 0.5);
			if(red < 0)
				red = 0;
			else if(red > 255)
				red = 255;
			
			var green:int = (int)(gsum + 0.5);
			if(green < 0)
				green = 0;
			else if(green > 255)
				green = 255;
			
			var blue:int = (int)(bsum + 0.5);
			if(blue < 0)
				blue = 0;
			else if(blue > 255)
				blue = 255;
			
			return (alpha << 24) | (red << 16) | (green << 8) | (blue << 0);
		}
		
		private static function A( x:Number ):Number
		{
			var p0:Number = ((x + 2) > 0) ? (x + 2) : 0;
			var p1:Number = ((x + 1) > 0) ? (x + 1) : 0;
			var p2:Number = (x > 0) ? x : 0;
			var p3:Number = ((x - 1) > 0) ? (x - 1) : 0;
			
			return (1 / 6) * (p0 * p0 * p0 - 4 * (p1 * p1 * p1) + 6 * (p2 * p2 * p2) - 4 * (p3 * p3 * p3));
		}
	}
}