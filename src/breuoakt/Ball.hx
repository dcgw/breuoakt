package breuoakt;

import hopscotch.collision.BoxMask;
import hopscotch.graphics.Image;
import flash.display.BitmapData;
import flash.geom.Point;
import hopscotch.Entity;

class Ball extends Entity {
    public static inline var WIDTH = 8;
    public static inline var HEIGHT = 8;

    public static inline var START_X = Game.WIDTH * 0.5;
    public static inline var START_Y = Game.HEIGHT * 0.6;

    static inline var GRAVITY = 0.1;

    public var prevX(default, null):Float;
    public var prevY(default, null):Float;

    public var velocity(default, null):Point;

    public var yayPrimed:Bool;

    var movingBoxMask:MovingBoxMask;

    public function new() {
        super();

        velocity = new Point();

        var image = new Image(new BitmapData(WIDTH, HEIGHT, false, 0xffffff));
        image.centerOrigin();
        graphic = image;

        movingBoxMask = new MovingBoxMask();
        collisionMask = movingBoxMask;

        reset();
    }

    public function spawn(x, y) {
        reset();

        this.prevX = x;
        this.prevY = y;

        this.x = x;
        this.y = y;

        active = true;
        visible = true;
    }

    public function reset() {
        prevX = START_X;
        prevY = START_Y;

        x = START_X;
        y = START_Y;

        velocity.x = 0;
        velocity.y = 0;

        active = false;
        visible = false;

        yayPrimed = true;
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
