package breuoakt;

import motion.easing.Elastic;
import motion.Actuate;
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

    public var collidable(default, null):Bool;
    public var prevCollidable(default, null):Bool;

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

        collisionMask = new BoxMask(-WIDTH * 0.5, -HEIGHT * 0.5, WIDTH, HEIGHT);

        collidable = true;
        prevCollidable = true;
    }

    public function reset() {
        respawn();

        prevCollidable = true;
        collidable = true;
    }

    public function hit() {
        visible = false;
        collidable = false;
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
                respawn();
            } else {
                spawnProbability += SPAWN_PROBABILITY_INCREASE_PER_FRAME;
            }
        }

        prevCollidable = collidable;
    }

    function respawn() {
        if (!visible) {
            prevCollidable = false;
            collidable = false;
            visible = true;

            var image = nextColor();

            image.scale = 0;
            image.y = -16 - Math.random() * 32;
            image.angle = (Math.random() - 0.5) * Math.PI / 4;
            Actuate.timer(Math.random() * 1)
                    .onComplete(function() {
                        Actuate.tween(image, 2, {scale:1, y:0, angle:0})
                                .ease(Elastic.easeOut);
                        Actuate.timer(0.2)
                                .onComplete(function() {
                                    collidable = visible;
                                    prevCollidable = visible;
                                });
                    });

            hitFrame = 0;
            spawnProbability = 0;
        }
    }

    function nextColor() {
        var image = images[Std.random(images.length)];
        graphic = image;
        return image;
    }
}
