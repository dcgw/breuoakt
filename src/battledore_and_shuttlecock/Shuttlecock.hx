package battledore_and_shuttlecock;

import flash.geom.Point;
import hopscotch.Entity;

class Shuttlecock extends Entity {
    public static inline var WIDTH = 8;
    public static inline var HEIGHT = 8;

    static inline var GRAVITY = 0.1;

    public var velocity:Point;

    public var prevX(default, null):Float;
    public var prevY(default, null):Float;

    public function new() {
        super();

        velocity = new Point();

        prevX = 0;
        prevY = 0;
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
    }
}
