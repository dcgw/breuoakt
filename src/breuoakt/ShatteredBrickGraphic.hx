package breuoakt;

import flash.display.DisplayObjectContainer;
import breuoakt.Game;
import breuoakt.Game;
import flash.geom.ColorTransform;
import hopscotch.engine.ScreenSize;
import hopscotch.engine.ScreenSize;
import hopscotch.Static;
import hopscotch.math.VectorMath;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.display.BitmapData;
import hopscotch.graphics.Graphic;

class ShatteredBrickGraphic extends Graphic {
    private static inline var GRAVITY = 0.2;

    private var displayObjectContainer:DisplayObjectContainer;
    private var rectangle:Sprite;
    private var mask:Sprite;

    private var colorTransform:ColorTransform;

    private var angle:Float;
    
    private var position:Point; 
    private var velocity:Point;

    public function new() {
        super();

        displayObjectContainer = new Sprite();

        rectangle = new Sprite();
        var graphics = rectangle.graphics;
        graphics.moveTo(-Brick.WIDTH * 0.5, -Brick.HEIGHT * 0.5);
        graphics.beginFill(0xffffff);
        graphics.lineTo(Brick.WIDTH * 0.5, -Brick.HEIGHT * 0.5);
        graphics.lineTo(Brick.WIDTH * 0.5, Brick.HEIGHT * 0.5);
        graphics.lineTo(-Brick.WIDTH * 0.5, Brick.HEIGHT * 0.5);
        graphics.lineTo(-Brick.WIDTH * 0.5, -Brick.HEIGHT * 0.5);
        graphics.endFill();

        displayObjectContainer.addChild(rectangle);

        mask = new Sprite();
        graphics = mask.graphics;
        graphics.moveTo(0, 0);
        graphics.beginFill(0xffffff);
        VectorMath.toPolar(Static.point, Math.PI/4, Brick.WIDTH + Brick.HEIGHT);
        graphics.lineTo(Static.point.x, Static.point.y);
        VectorMath.toPolar(Static.point, -Math.PI/4, Brick.WIDTH + Brick.HEIGHT);
        graphics.lineTo(Static.point.x, Static.point.y);
        graphics.lineTo(0, 0);
        graphics.endFill();

        displayObjectContainer.addChild(mask);

        colorTransform = new ColorTransform();
        
        rectangle.mask = mask;
        
        this.position = new Point();
        this.velocity = new Point();
    }

    public function reset() {
        this.active = false;
        this.visible = false;
    }

    public function start(color:Int, angle:Float, velocity:Point) {
        this.active = true;
        this.visible = true;

        colorTransform.color = color;

        var maskMatrix = mask.transform.matrix;
        maskMatrix.identity();
        maskMatrix.rotate(angle);
        mask.transform.matrix = maskMatrix;
        
        this.position.x = 0;
        this.position.y = 0;
        this.velocity.x = velocity.x;
        this.velocity.y = velocity.y;
    }

    override public function updateGraphic(frame:Int, screenSize:ScreenSize) {
        position.x += velocity.x;
        position.y += velocity.y;

        if (position.y > Game.HEIGHT + Brick.HEIGHT + Brick.WIDTH) {
            reset();
        }
        
        velocity.y += GRAVITY; 
    }

    override public function render(target:BitmapData, position:Point, camera:Matrix) {
        Static.matrix.identity();
        Static.matrix.tx = position.x + this.position.x;
        Static.matrix.ty = position.y + this.position.y;
        Static.matrix.concat(camera);

        target.draw(displayObjectContainer, Static.matrix, colorTransform, null, null, true);
    }
}