package breuoakt;

import hopscotch.collision.BoxMask;
import flash.display.BitmapData;
import hopscotch.graphics.Image;
import hopscotch.Entity;

class Brick extends Entity {
    public static inline var WIDTH = 34;
    public static inline var HEIGHT = 14;

    static var colors = [0x99dd92, 0x94c4d3, 0x949ace, 0xcc96b1];

    var images:Array<Image>;

    public function new() {
        super();

        images = [];
        for (color in colors) {
            var image = new Image(new BitmapData(WIDTH, HEIGHT, false, color));
            image.centerOrigin();
            images.push(image);
        }

        nextColor();

        collisionMask = new BoxMask(-WIDTH*0.5, -HEIGHT*0.5, WIDTH, HEIGHT);
    }

    public function reset() {
        if (!visible) {
            visible = true;
            nextColor();
        }
    }

    public function hit() {
        visible = false;
    }

    function nextColor() {
        graphic = images[Std.random(images.length)];
    }
}
