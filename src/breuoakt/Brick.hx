package breuoakt;

import hopscotch.math.VectorMath;
import flash.geom.Point;
import hopscotch.Static;
import hopscotch.graphics.GraphicList;
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

    static var EXPLODE_SPEED = 2;

    static var colors = [0x99dd92, 0x94c4d3, 0x949ace, 0xcc96b1];

    public var collidable(default, null):Bool;

    var colorIndex:Int;

    var images:Array<Image>;
    var shatteredGraphics:Array<ShatteredBrickGraphic>;
    var shatteredGraphicList:GraphicList;

    var frame:Int;
    var hitFrame:Int;

    var spawnProbability:Float;

    var tmpBallPosition:Point;
    var tmpBallVelocity:Point;

    public function new() {
        super();

        images = [];
        for (color in colors) {
            var image = new Image(new BitmapData(WIDTH, HEIGHT, false, color));
            image.centerOrigin();
            images.push(image);
        }

        shatteredGraphics = [];
        for (i in 0...3) {
            var shatteredGraphic = new ShatteredBrickGraphic();
            shatteredGraphics.push(shatteredGraphic);
        }
        shatteredGraphicList = new GraphicList(shatteredGraphics);
        shatteredGraphicList.active = true;

        nextColor();

        collisionMask = new BoxMask(-WIDTH * 0.5, -HEIGHT * 0.5, WIDTH, HEIGHT);

        collidable = true;

        tmpBallPosition = new Point();
        tmpBallVelocity = new Point();
    }

    public function reset() {
        respawn();

        collidable = true;
    }

    public function hit(ballPosition:Point, ballVelocity:Point) {
        tmpBallPosition.x = ballPosition.x;
        tmpBallPosition.y = ballPosition.y;

        tmpBallVelocity.x = ballVelocity.x;
        tmpBallVelocity.y = ballVelocity.y;

        Static.point.x = tmpBallPosition.x - x;
        Static.point.y = tmpBallPosition.y - y;

        var angleToBall = VectorMath.angle(Static.point);

        for (i in 0...shatteredGraphics.length) {
            var shatteredGraphic = shatteredGraphics[i];
            var angle = angleToBall + Math.PI * 2 * (i + 0.5) / shatteredGraphics.length;

            VectorMath.toPolar(Static.point, angle, EXPLODE_SPEED);
            VectorMath.add(Static.point, tmpBallVelocity);

            shatteredGraphic.start(colors[colorIndex], angle, Static.point);
        }

        graphic = shatteredGraphicList;

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

        if (!collidable && hitFrame + MIN_HIDDEN_FRAMES < frame) {
            if (Math.random() > 1 - spawnProbability) {
                respawn();
            } else {
                spawnProbability += SPAWN_PROBABILITY_INCREASE_PER_FRAME;
            }
        }
    }

    function respawn() {
        if (!collidable) {
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
                                    collidable = true;
                                });
                    });

            hitFrame = 0;
            spawnProbability = 0;
        }
    }

    function nextColor() {
        colorIndex = Std.random(images.length);
        var image = images[colorIndex];
        graphic = image;
        return image;
    }
}
