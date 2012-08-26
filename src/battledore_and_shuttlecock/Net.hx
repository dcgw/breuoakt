package battledore_and_shuttlecock;

import hopscotch.collision.BoxMask;
import flash.display.BitmapData;
import hopscotch.graphics.Image;
import hopscotch.Entity;

class Net extends Entity {
    static inline var WIDTH = 8;
    static inline var HEIGHT = 240;

    public function new() {
        super();

        var image = new Image(new BitmapData(WIDTH, HEIGHT, false, 0xffffff));
        image.originX = WIDTH * 0.5;
        image.originY = HEIGHT;
        graphic = image;

        collisionMask = new BoxMask(-image.originX, -image.originY, WIDTH, HEIGHT);
    }
}
