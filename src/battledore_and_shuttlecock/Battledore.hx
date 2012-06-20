package battledore_and_shuttlecock;

import flash.geom.Point;
import hopscotch.Entity;

class Battledore extends Entity {
    public static inline var WIDTH = 8;
    public static inline var HEIGHT = 64;

    public var offsetX:Float;

    public var prevX(default, null):Float;
    public var prevY(default, null):Float;

    public var velocity(default, null):Point;

    public function new() {
        super();

        offsetX = 0;

        prevX = 0;
        prevY = 0;

        velocity = new Point();
    }

    override public function update (frame:Int) {
        super.update(frame);

        prevX = x;
        prevY = y;

        // TODO movement

        // TODO smooth velocity
        velocity.x = x - prevX;
        velocity.y = y - prevY;
    }
}
