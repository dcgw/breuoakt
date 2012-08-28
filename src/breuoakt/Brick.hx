package breuoakt;

import com.eclecticdesignstudio.motion.easing.Elastic;
import com.eclecticdesignstudio.motion.Actuate;
import hopscotch.collision.BoxMask;
import flash.display.BitmapData;
import hopscotch.graphics.Image;
import hopscotch.Entity;

class Brick extends Entity {
    public static inline var WIDTH = 34;
    public static inline var HEIGHT = 14;

    static var MIN_HIDDEN_FRAMES = 1200;
    static var SPAWN_PROBABILITY_INCREASE_PER_FRAME = 0.0000005;

    static var colors = [0x99dd92, 0x94c4d3, 0x949ace, 0xcc96b1];

    var images:Array<Image>;

    var frame:Int;
    var hitFrame:Int;

    var spawnProbability:Float;

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

            var image = nextColor();

            image.scale = 0;
            image.y = -16 - Math.random() * 32;
            image.angle = (Math.random() - 0.5) * Math.PI/4;
            Actuate.tween(image, 2, { scale: 1, y: 0, angle: 0 })
                    .ease(Elastic.easeOut)
                    .delay(Math.random() * 1);
        }
    }

    public function hit() {
        visible = false;
    }

    function nextColor():Image {
        var image = images[Std.random(images.length)];
        graphic = image;
        return image;
    }
}
