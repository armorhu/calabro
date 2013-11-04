/**
* VERSION: 1.00
* DATE: 5/10/2010
* ACTIONSCRIPT VERSION: 3.0 
* UPDATES AND DOCUMENTATION AT: http://www.TweenMax.com;
* by a〇
**/
package com.greensock.plugins 
{
        import com.greensock.plugins.TransformAroundPointPlugin;
        import com.greensock.TweenLite;
        import flash.geom.Matrix;
        import flash.geom.Point;
        import flash.geom.Transform;
        
        public class TransformAroundGridPlugin extends TransformAroundPointPlugin
        {
                /** @private **/
                public static const API:Number = 1.0;
                
                public function TransformAroundGridPlugin() 
                {
                        super();
                        this.propName = "transformAroundGrid";
                        this.overwriteProps = ["scaleX", "scaleY", "rotation"];
                }
                
                override public function onInitTween(target:Object, value:*, tween:TweenLite):Boolean 
                {
                        _transform = target.transform as Transform;
                        _matrix = _transform.matrix;
                        var matrix:Matrix, _point:Point = new Point(0, 0);
                        matrix = _matrix.clone();
                        _transform.matrix = new Matrix(1, 0, 0, 1);
                        if ("position" in value) {
                                switch(Number(value.position))
                                {
                                        case 0:
                                                _point = new Point(0, 0);
                                                break;
                                        case 1:
                                                _point = new Point(target.width / 2, 0);
                                                break;
                                        case 2:
                                                _point = new Point(target.width, 0);
                                                break;
                                        case 3:
                                                _point = new Point(0, target.height / 2);
                                                break;
                                        case 4:
                                                _point = new Point(target.width / 2, target.height / 2);
                                                break;
                                        case 5:
                                                _point = new Point(target.width, target.height / 2);
                                                break;
                                        case 6:
                                                _point = new Point(0, target.height);
                                                break;
                                        case 7:
                                                _point = new Point(target.width / 2, target.height);
                                                break;
                                        case 8:
                                                _point = new Point(target.width, target.height);
                                                break;
                                }
                        }
                        value.point = new Point(_matrix.tx + _point.x * matrix.a + _point.y * matrix.c, _matrix.ty + _point.x * matrix.b + _point.y * matrix.d);
                        _transform.matrix = matrix;
                        super.onInitTween(target, value, tween);
                        return true;
                }                
                
        }

}