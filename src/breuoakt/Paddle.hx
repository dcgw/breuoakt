package breuoakt;

import hopscotch.input.analogue.IPointer;
import flash.display.BitmapData;
import hopscotch.graphics.Image;
import flash.geom.Point;
import hopscotch.Entity;

class Paddle extends Entity {
    public static inline var WIDTH = 64;
    public static inline var HEIGHT = 8;

    public static inline var OFFSET_Y = -8;

    public var prevX(default, null):Float;
    public var prevY(default, null):Float;

    public var velocity(default, null):Point;

    var pointer:IPointer;

    var movingBoxMask:MovingBoxMask;

    public function new (pointer:IPointer) {
        super();

        prevX = 0;
        prevY = 0;

        velocity = new Point();

        var image = new Image(new BitmapData(WIDTH, HEIGHT, false, 0xffffff));
        image.centerOrigin();
        graphic = image;

        this.pointer = pointer;

        movingBoxMask = new MovingBoxMask();
        collisionMask = movingBoxMask;
    }

    override public function update (frame:Int) {
        super.update(frame);

        prevX = x;
        prevY = y;

        var targetX = pointer.x;
        var targetY = pointer.y + OFFSET_Y;

        x += (targetX - x) * 0.2;
        y += (targetY - y) * 0.2;

        velocity.x = x - prevX;
        velocity.y = y - prevY;

        movingBoxMask.updateMask(
                prevX - x - WIDTH * 0.5,
                prevY - y - HEIGHT * 0.5,
                WIDTH,
                HEIGHT,
                -WIDTH * 0.5,
                -HEIGHT * 0.5,
                WIDTH,
                HEIGHT);
    }
}
