// from Mario Zechner - badlogic
// ported from js to haxe.
// https://github.com/badlogic/line-rasterization

// Standard DDA implementation for integer coordinate end points.
//
// Calculates the number of pixels on the major axis, then samples
// pixels at (deltaX / numPixels, deltaY / numPixels) steps.
//
// The current pixel coordinate under investigation is stored in (x, y)
// which is initially incremented by 0.5 on each axis so we can use
// Math.floor() instead of the more expensive Math.round().
// 
// Gives the same result as Bresenham's algorithm for integer
// start and end point coordinates, but uses floating point math.
//
// This implementation implicitely implements the diamond exit rule.

package pixelimageXY.algo;
import pixelimageXY.Pixelimage;
import pixelimageXY.pixel.Pixel32;
import pixelimageXY.pixel.PixelChannel;
/*
need to consider inline final
*/

// untested!
// wip

inline
function lineDDA( x1_: Float, y1_: Float, x2_: Float, y2_: Float ) {
    final x1 = Math.floor(x1_);
    final y1 = Math.floor(y1_);
    final x2 = Math.floor(x2_);
    final y2 = Math.floor(y2_);
    final deltaX = (x2 - x1);
    final deltaY = (y2 - y1);
    if (deltaX == 0 && deltaY == 0) {
        //drawPixel(x1, y1);
        trace( '$x1 : $y1' );
    } else {
    	final numPixels = (Math.abs(deltaX) > Math.abs(deltaY))? Math.abs(deltaX) : Math.abs(deltaY);
    	final stepX = deltaX / numPixels;
    	final stepY = deltaY / numPixels;
    	var x = x1 + 0.5;
    	var y = y1 + 0.5;
    	for( i in 0...Std.int(numPixels+1) ){
        	//steppedPoints.push({ x: x, y: y });
        	//drawPixel(Math.floor(x), Math.floor(y));
        	trace( Math.floor( x ) + ' ' + Math.floor( y ) );
        	x += stepX;
      	    y += stepY;
    	}
    }
}

// Sub-pixel DDA implementation for non-integer start and end points.
//
// Calculates the number of pixels on the major axis, then samples
// pixels at (deltaX / (numPixels - 1), deltaY / (numPixels - 1) intervals.
//
// This is basically a lerp between the start and end point with `numPixels - 1` steps.
inline
function lineSubpixelDDA( x1: Float, y1: Float, x2: Float, y2: Float ) {
    final deltaX = (x2 - x1);
    final deltaY = (y2 - y1);
    final numPixelsX = Math.abs(Math.floor(x2) - Math.floor(x1)) + 1;
    final numPixelsY = Math.abs(Math.floor(y2) - Math.floor(y1)) + 1;
    final numPixels = Std.int( ( numPixelsX > numPixelsY )? numPixelsX: numPixelsY );
    if( numPixels == 1 ){
        trace( Math.floor(x1) + ' ' + Math.floor(y1) );
    } else {
		final stepX = deltaX / (numPixels - 1);
        final stepY = deltaY / (numPixels - 1);
        var x = x1;
        var y = y1;
        for( i in 0...numPixels ){
            //steppedPoints.push({ x: x, y: y });
            trace( Math.floor(x), Math.floor(y) );
            x += stepX;
            y += stepY;
        }
    }
}

// Sub-pixel DDA for non-integer start and end points.
//
// Instead of sampling the line at `numPixels - 1` intervals, it
// sample's the pixels between the start and end points at the
// pixel-center on the major axis. This makes it more similar to
// sub-pixel Bresenham.
//
// This function omits the end point pixel to be more in line with the
// diamond exit rule.
inline
function lineSubpixelDDACenterSampling( x1: Float, y1: Float, x2: Float, y2: Float ) {
    final deltaX = ( x2 - x1 );
    final deltaY = ( y2 - y1 );
    final numPixelsX = Math.abs( Math.floor( x2 ) - Math.floor( x1 ) ) + 1;
    final numPixelsY = Math.abs( Math.floor( y2 ) - Math.floor( y1 ) ) + 1;
    final numPixels = ( Math.abs( deltaX ) > Math.abs( deltaY ) )? numPixelsX: numPixelsY;
    if( numPixels == 0 ){
        trace( Math.floor(x1) + ' ' + Math.floor(y1) );
    } else {
        var x = 0.;
        var y = 0.; 
        var stepX = 0.;
        var stepY = 0.;
        if( Math.abs( deltaX ) > Math.abs( deltaY ) ){
            stepX = ( x1 < x2 )? 1: -1;
            stepY = deltaY / Math.abs(deltaX);
            x = Math.floor( x1 ) + 0.5 + stepX;
            y = y1 + Math.abs( x - x1 ) * stepY;
        } else {
            stepY = ( y1 < y2 )? 1: -1;
            stepX = deltaX / Math.abs( deltaY );
            y = Math.floor( y1) + 0.5 + stepY;
            x = x1 + Math.abs( y - y1 ) * stepX;
        }
        trace( Math.floor( x1 ) + ' ' + Math.floor( y1 ) );
        for( i in 1...Std.int( numPixels ) ){
            // steppedPoints.push({ x: x, y: y });
            trace( Math.floor( x ) + ' ' + Math.floor( y ) );
            x += stepX;
            y += stepY;
        }
    }
}

// Same as above, but does not omit the last pixel
inline
function lineSubpixelDDACenterSamplingIncludeEndpoint(x1, y1, x2, y2) {
    final deltaX = (x2 - x1);
    final deltaY = (y2 - y1);

    final numPixelsX: Int = Std.int( Math.abs(Math.floor(x2) - Math.floor(x1)) + 1 );
    final numPixelsY: Int = Std.int( Math.abs(Math.floor(y2) - Math.floor(y1)) + 1 );
    final numPixels: Int = Math.abs(deltaX) > Math.abs(deltaY) ? numPixelsX : numPixelsY;

    if (numPixels == 1) {
        trace( Math.floor(x1) + ' ' + Math.floor(y1) );
    } else {
		var x: Float;
    	var y: Float;
    	var stepX: Float;
    	var stepY: Float;

    	if( Math.abs( deltaX ) > Math.abs( deltaY ) ){
            stepX = x1 < x2 ? 1 : -1;
            stepY = deltaY / Math.abs(deltaX);
            x = Math.floor(x1) + 0.5 + stepX;
            y = y1 + Math.abs(x - x1) * stepY;
    	} else {
            stepY = y1 < y2 ? 1 : -1;
            stepX = deltaX / Math.abs(deltaY);
            y = Math.floor(y1) + 0.5 + stepY;
            x = x1 + Math.abs(y - y1) * stepX;
    	}
		trace( Math.floor(x1) + ' ' + Math.floor(y1));
  
    	for( i in 1...(numPixels - 1) ){
            //steppedPoints.push({ x: x, y: y });
            trace( Math.floor(x) + ' ' + Math.floor(y) );
            x += stepX;
            y += stepY;
    	}

        // Last calculated pixel coordinate != end point pixel coordinate?
        // Plot both calculated pixel and end point pixel.
        // E.g.
        // p1 = {x: 5.49375, y: 5.478125}
        // p2 = {x: 10.121875, y: 10.890625}
        if (Math.floor(x2) != Math.floor(x) || Math.floor(y2) != Math.floor(y)) {
            // FIXME Check if the calculated sub-pixel coordinate is outside
            // the line segment. E.g. 
            // p1 = {x: 5.49375, y: 5.478125}
            // p2 = {x: 1.1999999999999993, y: 10.21875}
            //steppedPoints.push({ x: x, y: y });
            trace( Math.floor(x) + ' ' + Math.floor(y));
        }
        trace( Math.floor(x2) + ' ' + Math.floor(y2));
    }
}

//
// Basic Bresenham for all octants. `x` and `y` are
// set to the start point coordinates. `error` starts out
// storing the the (absolute) distance from the point on
// line sampled at the next coordinate along the major axis to the pixel
// border "above" it. If that distance is > 0.5, we move
// "up" by 1 on the minor axis, and decrement the error by 1.
//
inline
function lineBresenham1(x1_: Float, y1_: Float, x2_: Float, y2_: Float ) {
    final x1: Int = Math.floor(x1_);
    final y1: Int = Math.floor(y1_);
    final x2: Int = Math.floor(x2_);
    final y2: Int = Math.floor(y2_);
    final deltaX: Int = Std.int( Math.abs(x2 - x1) );
    final deltaY: Int = Std.int( Math.abs(y2 - y1) );
    final stepX: Int = (x1 < x2) ? 1 : -1;
    final stepY: Int = (y1 < y2) ? 1 : -1;
    var x: Float = x1;
    var y: Float = y1;

    if( deltaX == 0 && deltaY == 0 ) {
        trace( x + ' ' + y );
        
    } else {
        if( deltaX >= deltaY ){
            var slope = deltaY / deltaX;
            var error = slope;
            var i = 0.;
            var n: Float = deltaX;
            while( i <= n ) {
                //steppedPoints.push({ x: x + 0.5, y: y + 0.5 });
                trace( x + ' ' + y );
                if( error > 0.5 ){
                    error -= 1;
                    y += stepY;
                }
                x += stepX;
                error += slope;
                i++;
            }
        } else {
            var slope = deltaX / deltaY;
            var error = slope;
            var i = 0.;
            var n: Float = deltaY;
            while( i <= n ) {
                // steppedPoints.push({ x: x + 0.5, y: y + 0.5 });
                trace( x + ' ' + y);
                if( error > 0.5 ){
                    error -= 1;
                    x += stepX;
                }
                y += stepY;
                error += slope;
                i++;
            }
        }
        if( x != Math.floor( x2 ) && y != Math.floor( y2 ) ){
            trace( x + ' ' + y );
        }
    }
}

//
// Rewrites the "move up" condition from error > 0.5 to error > 0
// by subtracting 0.5 from the initial error.
//
inline
function lineBresenham2(x1_: Float, y1_: Float, x2_: Float, y2_: Float ) {
    final x1: Int = Math.floor(x1_);
    final y1: Int = Math.floor(y1_);
    final x2: Int = Math.floor(x2_);
    final y2: Int = Math.floor(y2_);
    final deltaX: Int = Std.int( Math.abs(x2 - x1) );
    final deltaY: Int = Std.int( Math.abs(y2 - y1) );
    final stepX: Int = (x1 < x2) ? 1 : -1;
    final stepY: Int = (y1 < y2) ? 1 : -1;
    var x: Float = x1;
    var y: Float = y1;

    if (deltaX == 0 && deltaY == 0) {
        trace( x + ' ' + y );
        
    } else {
        if( deltaX >= deltaY ){
            var slope = deltaY / deltaX;
            var error = slope - 0.5;
            var i = 0;
            var n: Float = deltaX;
            while( i <= n ) { 
                //steppedPoints.push({ x: x + 0.5, y: y + 0.5 });
                trace( x + ' ' + y);
                if( error > 0 ){
                    error -= 1;
                    y += stepY;
                }
                x += stepX;
                error += slope;
                i++;
            }
        } else {
            var slope = deltaX / deltaY;
            var error = slope - 0.5;
            var i = 0;
            var n: Float = deltaY;
            while( i <= n ) { 
                //steppedPoints.push({ x: x + 0.5, y: y + 0.5 });
                trace( x + ' ' + y );
                if( error > 0 ){
                    error -= 1;
                    x += stepX;
                }
                y += stepY;
                error += slope;
                i++;
            }
        }
    }
}

//
// Gets rid of the division to calculate the slope by
// multiplying the right hand side of assignments to
// error by deltaX or deltaY, depending on the major axis.
// This also eliminates `slope` everywhere.
inline
function lineBresenham3(x1_: Float, y1_: Float, x2_: Float, y2_: Float ) {
    final x1: Int = Math.floor(x1_);
    final y1: Int = Math.floor(y1_);
    final x2: Int = Math.floor(x2_);
    final y2: Int = Math.floor(y2_);
    final deltaX: Int = Std.int( Math.abs(x2 - x1) );
    final deltaY: Int = Std.int( Math.abs(y2 - y1) );
    final stepX: Int = (x1 < x2) ? 1 : -1;
    final stepY: Int = (y1 < y2) ? 1 : -1;
    var x: Float = x1;
    var y: Float = y1;
    if( deltaX == 0 && deltaY == 0 ) {
        trace( x + ' ' + y );
    } else {
        if( deltaX >= deltaY ){
            var error = deltaY - 0.5 * deltaX;
            var i = 0;
            var n: Float = deltaX;
            while( i <= n ) { 
                //steppedPoints.push({ x: x + 0.5, y: y + 0.5 });
                trace( x + ' ' + y);
                if( error > 0 ){
                    error -= deltaX;
                    y += stepY;
                }
                x += stepX;
                error += deltaY;
                i++;
            }
        } else {
            var error = deltaY - 0.5 * deltaX;
            var i = 0;
            var n: Float = deltaY;
            while( i <= n ) { 
                //steppedPoints.push({ x: x + 0.5, y: y + 0.5 });
                trace( x + ' ' + y );
                if( error > 0 ){
                    error -= deltaY;
                    x += stepX;
                }
                y += stepY;
                error += deltaX;
                i++;
            }
        }
    }
}


// Multiplies the right hand side of all assignments to error
// by 2 to remove the multiplication by 0.5 when calculating
// the initial error. This makes the algorithm integer only.
inline
function lineBresenham(x1_: Float, y1_: Float, x2_: Float, y2_: Float ) {
    final x1: Int = Math.floor(x1_);
    final y1: Int = Math.floor(y1_);
    final x2: Int = Math.floor(x2_);
    final y2: Int = Math.floor(y2_);
    final deltaX: Int = Std.int( Math.abs(x2 - x1) );
    final deltaY: Int = Std.int( Math.abs(y2 - y1) );
    final stepX: Int = (x1 < x2) ? 1 : -1;
    final stepY: Int = (y1 < y2) ? 1 : -1;
    var x: Float = x1;
    var y: Float = y1;
    if( deltaX == 0 && deltaY == 0 ) {
        trace( x + ' ' + y );
    } else {
        if( deltaX >= deltaY ){
        	var error = 2 * deltaY - deltaX;
        	var i = 0;
        	var n: Float = deltaX;
        	while( i <= n ){ 
                //steppedPoints.push({ x: x + 0.5, y: y + 0.5 });
                trace( x + ' ' + y );
                if( error > 0 ){
                    error -= deltaX * 2;
                    y += stepY;
                }
                x += stepX;
                error += deltaY * 2;
                i++;
        	}
    	} else {
            var error = 2 * deltaX - deltaY;
            var i = 0;
            var n: Float = deltaY;
            while( i <= n ){ 
            //steppedPoints.push({ x: x + 0.5, y: y + 0.5 });
            trace( x + ' ' + y );
                if( error > 0 ){
                    error -= deltaY * 2;
                    x += stepX;
                }
                y += stepY;
                error += deltaX * 2;
                i++;
            }
    	}
    }
}

inline
function lineSubPixelBresenham( x1: Float, y1: Float, x2: Float, y2: Float ) {
    final deltaX: Int = Std.int( Math.abs(x2 - x1) );
    final deltaY: Int = Std.int( Math.abs(y2 - y1) );
    final stepX: Int = (x1 < x2) ? 1 : -1;
    final stepY: Int = (y1 < y2) ? 1 : -1;
    var x = Math.ffloor( x1 );
    var y = Math.ffloor( y1 );

    if( deltaX > deltaY ) {
        var dist_next_pixel = Math.abs( Math.floor( x1 ) + 0.5 + stepX - x1 );
        var dist_pixel_edge = Math.abs( y1 ) - Math.floor( Math.abs( y1 ) );
        if (y1 > y2) dist_pixel_edge = 1 - dist_pixel_edge;
        var error = dist_pixel_edge * deltaX + dist_next_pixel * deltaY;
        var numPixels = Std.int( Math.abs( Math.floor( x2 ) - x ) );
        for( i in 0... numPixels ){
            //steppedPoints.push({ x: x + 0.5, y: y + 0.5 });
            //helperLines.push({ x1: x + 0.5, y1: y + (y2 < y1 ? -stepY : 0), x2: x + 0.5, y2: y + (y2 < y1 ? -error / deltaX : error / deltaX) + (y2 < y1 ? -stepY : 0) });
            trace( x + ' ' + y );
            if( error >= deltaX ){
                error -= deltaX;
                y += stepY;
            }
            x += stepX;
            error += deltaY;
        }
        if( x != Math.floor( x2 ) || y != Math.floor( y2 ) ){
            if( y != Math.floor( y2 ) + stepY ) trace( x + ' ' + y );
        }
    } else {
        var dist_next_pixel = Math.abs( Math.floor( y1 ) + 0.5 + stepY - y1 );
        var dist_pixel_edge = Math.abs( x1 ) - Math.floor( Math.abs( x1 ) );
        if( x1 > x2 ) dist_pixel_edge = 1 - dist_pixel_edge;
        var error = dist_pixel_edge * deltaY + dist_next_pixel * deltaX;
        var numPixels = Std.int( Math.abs( Math.floor( y2 ) - y ) );
        for( t in 0...numPixels ){
            //steppedPoints.push({ x: x + 0.5, y: y + 0.5 });
            //helperLines.push({ x1: x + (x2 < x1 ? -stepX : 0), y1: y + 0.5, x2: x + (x2 < x1 ? -error / deltaY : error / deltaY) + (x2 < x1 ? -stepX : 0), y2: y + 0.5 });
            trace( x + ' ' + y );
            if (error >= deltaY) {
                error -= deltaY;
                x += stepX;
            }
            y += stepY;
            error += deltaX;
        }
        if( x != Math.floor( x2 ) || y != Math.floor( y2 )) {
            if( x != Math.floor( x2 ) + stepX ) trace( x + ' ' + y );
        }
    }
}
