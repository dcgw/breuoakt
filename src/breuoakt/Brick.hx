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

    static var EXPLODE_SPEED = 120 / Game.LOGIC_RATE;

    static var colors = [0x99dd92, 0x94c4d3, 0x949ace, 0xcc96b1];

    public var collidable(default, null):Bool;

    var colorIndex:Int;

    var images:Array<Image>;
    var shatteredGraphics:Array<ShatteredBrickGraphic>;
    var shatteredGraphicList:GraphicList;

    var tmpBallPosition:Point;
    var tmpBallVelocity:Point;

    var spawnActuateTarget = {};

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
        Actuate.stop(spawnActuateTarget, null, false, false);

        respawnInternal(true);
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
    }

    public function respawn() {
        respawnInternal(false);
    }

    function respawnInternal(collidableImmediately:Bool) {
        if (!collidable) {
            collidable = collidableImmediately;

            var image = nextColor();

            image.scale = 0;
            image.y = -16 - Math.random() * 32;
            image.angle = (Math.random() - 0.5) * Math.PI / 4;

            Actuate.tween(spawnActuateTarget, Math.random() * 1, {})
                    .onComplete(function() {
                        Actuate.tween(image, 2, {scale:1, y:0, angle:0})
                                .ease(Elastic.easeOut);
                        if (!collidableImmediately) {
                            Actuate.tween(spawnActuateTarget, 0.2, {})
                                    .onComplete(function() {
                                        collidable = true;
                                    });
                        }
                    });
        }
    }

    function nextColor() {
        colorIndex = Std.random(images.length);
        var image = images[colorIndex];
        graphic = image;
        return image;
    }
}
