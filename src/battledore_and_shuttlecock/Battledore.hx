package battledore_and_shuttlecock;

import hopscotch.input.analogue.IPointer;
import flash.display.BitmapData;
import hopscotch.graphics.Image;
import flash.geom.Point;
import hopscotch.Entity;

class Battledore extends Entity {
    public static inline var WIDTH = 8;
    public static inline var HEIGHT = 64;

    public var offsetX:Float;

    public var prevX(default, null):Float;
    public var prevY(default, null):Float;

    public var velocity(default, null):Point;

    var pointer:IPointer;

    var battledoreMask:BattledoreMask;

    public function new(pointer:IPointer) {
        super();

        offsetX = 0;

        prevX = 0;
        prevY = 0;

        velocity = new Point();

        var image = new Image(new BitmapData(WIDTH, HEIGHT, false, 0xffffff));
        image.centerOrigin();
        graphic = image;

        this.pointer = pointer;

        battledoreMask = new BattledoreMask(this);
        collisionMask = battledoreMask;
    }

    override public function update (frame:Int) {
        super.update(frame);

        prevX = x;
        prevY = y;

        x = pointer.x + offsetX;
        y = pointer.y;

        // TODO smooth velocity
        velocity.x = x - prevX;
        velocity.y = y - prevY;

        battledoreMask.updateMask();
    }
}
