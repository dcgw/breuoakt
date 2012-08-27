package breuoakt;

import hopscotch.graphics.Image;
import flash.display.BitmapData;
import hopscotch.Entity;

class Ceiling extends Entity {
    public static inline var WIDTH = Game.WIDTH;
    public static inline var HEIGHT = 8;

    public function new() {
        super();

        graphic = new Image(new BitmapData(WIDTH, HEIGHT, false, 0xffffffff));
    }
}
