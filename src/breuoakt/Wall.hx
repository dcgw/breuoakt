package breuoakt;

import hopscotch.Entity;
import flash.display.BitmapData;
import hopscotch.graphics.Image;

class Wall extends Entity {
    public static inline var WIDTH = 8;
    public static inline var HEIGHT = Game.HEIGHT - Ceiling.HEIGHT;

    public function new() {
        super();

        graphic = new Image(new BitmapData(WIDTH, HEIGHT, false, 0xffffffff));
    }
}
