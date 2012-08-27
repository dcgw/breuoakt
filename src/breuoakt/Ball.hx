package breuoakt;

import hopscotch.graphics.Image;
import flash.display.BitmapData;
import flash.geom.Point;
import hopscotch.Entity;

class Ball extends Entity {
    public static inline var WIDTH = 8;
    public static inline var HEIGHT = 8;

    static inline var GRAVITY = 0.1;

    public var prevX(default, null):Float;
    public var prevY(default, null):Float;

    public var velocity:Point;

    var movingBoxMask:MovingBoxMask;

    public function new() {
        super();

        prevX = 0;
        prevY = 0;

        velocity = new Point();

        var image = new Image(new BitmapData(WIDTH, HEIGHT, false, 0xffffff));
        image.centerOrigin();
        graphic = image;

        movingBoxMask = new MovingBoxMask();
        collisionMask = movingBoxMask;
    }

    override public function begin(frame:Int) {
        super.begin(frame);

        prevX = 0;
        prevY = 0;
    }

    override public function update(frame:Int) {
        super.update(frame);

        prevX = x;
        prevY = y;

        velocity.y += GRAVITY;

        x += velocity.x;
        y += velocity.y;

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
