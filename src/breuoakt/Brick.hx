package breuoakt;

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

        frame = -1;

        nextColor();

        collisionMask = new BoxMask(-WIDTH*0.5, -HEIGHT*0.5, WIDTH, HEIGHT);
    }

    public function reset() {
        if (!visible) {
            visible = true;
            nextColor();

            hitFrame = 0;
            spawnProbability = 0;
        }
    }

    public function hit() {
        visible = false;
        hitFrame = frame;
        spawnProbability = 0;
    }

    override public function begin(frame:Int) {
        this.frame = frame;

        super.begin(frame);
    }

    override public function update(frame:Int) {
        this.frame = frame;

        super.update(frame);

        if (!visible && hitFrame + MIN_HIDDEN_FRAMES < frame) {
            if (Math.random() > 1 - spawnProbability) {
                reset();
            } else {
                spawnProbability += SPAWN_PROBABILITY_INCREASE_PER_FRAME;
            }
        }
    }

    function nextColor() {
        graphic = images[Std.random(images.length)];
    }
}
