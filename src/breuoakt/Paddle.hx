package breuoakt;

import hopscotch.math.Range;
import hopscotch.input.analogue.IPointer;
import flash.display.BitmapData;
import hopscotch.graphics.Image;
import flash.geom.Point;
import hopscotch.Entity;

class Paddle extends Entity {
    public static inline var WIDTH = 64;
    public static inline var HEIGHT = 8;

    public static inline var OFFSET_Y = -8;

    static inline var MIN_X = Std.int(Wall.WIDTH + WIDTH * 0.5);
    static inline var MAX_X = Std.int(Game.WIDTH - Wall.WIDTH - WIDTH * 0.5);
    static inline var MIN_Y = Std.int(Game.HEIGHT * 0.5);

    public var prevX(default, null):Float;
    public var prevY(default, null):Float;

    public var velocity(default, null):Point;

    var pointer:IPointer;

    var movingBoxMask:MovingBoxMask;

    public function new (pointer:IPointer) {
        super();

        x = Game.WIDTH * 0.5;
        y = Game.HEIGHT * 0.85;

        prevX = x;
        prevY = y;

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

        x = Range.clampFloat(x + (targetX - x) * 0.2, MIN_X, MAX_X);
        y = Math.max(y + (targetY - y) * 0.2, MIN_Y);

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
