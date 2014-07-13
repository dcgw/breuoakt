package breuoakt;

import motion.easing.Linear;
import motion.easing.Cubic;
import motion.easing.Quad;
import flash.text.TextFormatAlign;
import openfl.Assets;
import motion.Actuate;
import hopscotch.graphics.FontFace;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.display.BitmapData;
import hopscotch.graphics.IGraphic;
import hopscotch.graphics.Text;
import hopscotch.engine.ScreenSize;

class Banners implements IGraphic {
    static inline var MAX_BANNERS = 64;

    static inline var MIN_SUFFICIENTLY_IMPRESSIVE_POINTS = 4;
    static inline var SUFFICIENTLY_IMPRESSIVE_POINTS_DECREASE_INTERVAL_FRAMES = 1 * Game.LOGIC_RATE;
    static inline var MIN_HIT_BRICK_BANNER_INTERVAL_FRAMES = 0.1 * Game.LOGIC_RATE;

    static inline var HURT_BRICK_PROBABILITY = 0.2;

    public var active:Bool;
    public var visible:Bool;

    var coolStuffSayings:Array<String>;
    var hurtBrickSayings:Array<String>;
    var lostBallSayings:Array<String>;
    var newBallSayings:Array<String>;

    var sufficientlyImpressivePoints:Int;
    var sufficientlyImpressivePointsLastUpdatedFrame:Int;
    var lastHitBrickBannerFrame:Int;

    var frame:Int;

    var banners:Array<Text>;
    var nextBanner:Int;

    public function new() {
        active = true;
        visible = true;

        coolStuffSayings = ["wizard!", "first rate!", "first class!", "my word!",
                "jolly good!", "well done!", "hurrah!", "superb!", "blimey!", "cor!",
                "crikey!", "top hole!", "goodness!", "spiffing", "i say!", "tremendous!"];

        hurtBrickSayings = ["ow!", "that hurt!", "you rotter!", "oi!", "steady on!"];

        lostBallSayings = ["chin up", "never mind", "not to worry", "oh no", "bad show",
                "that must be a bit of a blow for you", "it'll all sort itself out",
                "time for a nice cup of tea", "perhaps next time", "that's a shame",
                "these things happen"];

        newBallSayings = ["new ball", "multiball"];

        frame = 0;

        var fontFace = new FontFace(Assets.getFont("assets/04B_03__.ttf").fontName);

        banners = [];
        for (i in 0...MAX_BANNERS) {
            var banner = new Text();
            banner.text = "";
            banner.fontFace = fontFace;
            banner.fontSize = 16;
            banner.wordWrap = false;
            banner.color = 0xffffff;
            banner.align = TextFormatAlign.CENTER;
            banner.scale = 1;
            banners[i] = banner;
        }
        nextBanner = 0;

        reset();
    }

    public function reset() {
        sufficientlyImpressivePoints = MIN_SUFFICIENTLY_IMPRESSIVE_POINTS;
        sufficientlyImpressivePointsLastUpdatedFrame = frame;
        lastHitBrickBannerFrame = frame;
    }

    public function onHitBrick(points:Int, x:Float, y:Float, hitTop:Bool) {
        if (frame - lastHitBrickBannerFrame < MIN_HIT_BRICK_BANNER_INTERVAL_FRAMES) {
            return;
        }

        var banner = getNextBanner();

        if (points >= sufficientlyImpressivePoints) {
            banner.text = Std.string(nextSmallestSignificantNumber(points));
            Actuate.tween(banner, 1, { scale: 128, alpha: 0 })
                    .ease(Cubic.easeIn);

            sufficientlyImpressivePoints = nextHighestPowerOfTwo(points);
            sufficientlyImpressivePointsLastUpdatedFrame = frame;
        } else if (hitTop) {
            banner.text = coolStuffSayings[Std.random(coolStuffSayings.length)];
            Actuate.tween(banner, 3, { scale: 8, alpha: 0, y: y - 64 - Std.random(64) })
                    .ease(Linear.easeNone);
        } else if (Math.random() < HURT_BRICK_PROBABILITY) {
            banner.text = hurtBrickSayings[Std.random(hurtBrickSayings.length)];
            Actuate.tween(banner, 3, { scale: 8, alpha: 0, y: y - 64 - Std.random(64) })
                    .ease(Linear.easeNone);
        } else {
            return;
        }

        banner.centerOrigin();
        banner.scale = 1;
        banner.x = x;
        banner.y = y;
        banner.alpha = 0.8;

        lastHitBrickBannerFrame = frame;
    }

    public function onLoseBall(x:Float) {
        var banner = getNextBanner();

        banner.text = lostBallSayings[Std.random(lostBallSayings.length)];
        banner.centerOrigin();
        banner.scale = 1;
        banner.x = x;
        banner.y = Game.HEIGHT - 12;
        banner.alpha = 0.8;

        Actuate.tween(banner, 1.5, { scale: 1.4, alpha: 0, y: Game.HEIGHT-48 })
                .ease(Linear.easeNone);
    }

    public function onNewBall() {
        var banner = getNextBanner();

        banner.text = newBallSayings[Std.random(newBallSayings.length)];
        banner.centerOrigin();
        banner.scale = 1;
        banner.x = Game.WIDTH * 0.5;
        banner.y = Game.HEIGHT * 0.5;
        banner.alpha = 0.8;

        Actuate.tween(banner, 1, { scale: 128, alpha: 0 })
                .ease(Cubic.easeIn);
    }

    public function onClear(points: Int) {
        var mainBanner = getNextBanner();

        mainBanner.text = "clear!\n ";
        mainBanner.centerOrigin();
        mainBanner.scale = 256;
        mainBanner.x = Game.WIDTH * 0.5;
        mainBanner.y = Game.HEIGHT * 0.5;// - 16;
        mainBanner.alpha = 0;

        var scoreBanner = getNextBanner();
        scoreBanner.text = "\n0";
        scoreBanner.centerOrigin();
        scoreBanner.scale = 2;
        scoreBanner.x = Game.WIDTH * 0.5;
        scoreBanner.y = Game.HEIGHT * 0.5;// + 16;
        scoreBanner.alpha = 0;

        Actuate.tween(mainBanner, 1, { scale: 2, alpha: 1 })
                .ease(Cubic.easeOut);

        Actuate.tween(mainBanner, 2, { alpha: 0 }, false)
                .ease(Cubic.easeIn)
                .delay(1);

        Actuate.tween(scoreBanner, 2.2, { scale: 16 })
                .ease(Quad.easeIn)
                .delay(0.8);

        Actuate.tween(scoreBanner, 0.2, { alpha: 1 }, false)
                .ease(Quad.easeInOut)
                .delay(0.8);

        Actuate.tween(scoreBanner, 2, { alpha : 0 }, false)
                .ease(Cubic.easeIn)
                .delay(1);

        function updateScoreBanner(score:Int) {
            scoreBanner.text = "\n" + score;
            scoreBanner.centerOrigin();
        }

        Actuate.update(updateScoreBanner, 1.2, [0], [points])
                .ease(Linear.easeNone)
                .delay(0.8);

        for (i in 0...10) {
            var childBanner = getNextBanner();

            childBanner.text = mainBanner.text;
            childBanner.centerOrigin();
            childBanner.x = mainBanner.x;
            childBanner.y = mainBanner.y;
            childBanner.alpha = 0;

            Actuate.timer(1 + i * 0.2)
                    .onComplete(function () {
                        childBanner.alpha = mainBanner.alpha;
                        childBanner.scale = mainBanner.scale;

                        Actuate.tween(childBanner, 0.8, { scale: childBanner.scale + 30, alpha: 0 })
                                .ease(Linear.easeNone);
                    });
        }
    }

    public function beginGraphic(frame:Int) {
        this.frame = frame;

        for (banner in banners) {
            banner.beginGraphic(frame);
        }
    }

    public function endGraphic() {
        for (banner in banners) {
            banner.endGraphic();
        }
    }

    public function updateGraphic(frame:Int, screenSize:ScreenSize) {
        this.frame = frame;

        if (sufficientlyImpressivePoints > MIN_SUFFICIENTLY_IMPRESSIVE_POINTS
                && frame - sufficientlyImpressivePointsLastUpdatedFrame
                >= SUFFICIENTLY_IMPRESSIVE_POINTS_DECREASE_INTERVAL_FRAMES) {
            sufficientlyImpressivePoints >>= 1;
            sufficientlyImpressivePointsLastUpdatedFrame = frame;
        }
    }

    public function render(target:BitmapData, position:Point, camera:Matrix) {
        for (banner in banners) {
            banner.render(target, position, camera);
        }
    }

    function getNextBanner():Text {
        var banner = banners[nextBanner];
        nextBanner = (nextBanner + 1) % MAX_BANNERS;
        return banner;
    }

    function nextHighestPowerOfTwo(value:Int) {
        value |= value >> 1;
        value |= value >> 2;
        value |= value >> 4;
        value |= value >> 8;
        value |= value >> 16;
        return value + 1;
    }

    function nextSmallestSignificantNumber(value:Int) {
        var digits = Std.string(value);
        return Std.parseInt(StringTools.rpad(digits.charAt(0), "0", digits.length));
    }
}
