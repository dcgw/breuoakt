package breuoakt;

import hopscotch.collision.BoxMask;
import flash.display.BitmapData;
import hopscotch.graphics.Image;
import hopscotch.Entity;

class Brick extends Entity {
    public static inline var WIDTH = 34;
    public static inline var HEIGHT = 14;

    public function new() {
        super();
        var image = new Image(new BitmapData(WIDTH, HEIGHT, false, 0xffffffff));
        image.centerOrigin();
        graphic = image;

        collisionMask = new BoxMask(-image.originX, -image.originY, image.width, image.height);
    }

    public function reset() {
        visible = true;
    }

    public function hit() {
        visible = false;
    }
}
