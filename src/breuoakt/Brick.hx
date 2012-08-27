package breuoakt;

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
    }
}
