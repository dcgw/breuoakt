package breuoakt;

import com.eclecticdesignstudio.motion.easing.Linear;
import com.eclecticdesignstudio.motion.easing.Cubic;
import flash.text.TextFormatAlign;
import nme.installer.Assets;
import com.eclecticdesignstudio.motion.Actuate;
import hopscotch.graphics.FontFace;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.display.BitmapData;
import hopscotch.graphics.IGraphic;
import hopscotch.graphics.Text;
import hopscotch.engine.ScreenSize;

class Banners implements IGraphic {
    static inline var MAX_BANNERS = 32;

    static inline var MIN_SUFFICIENTLY_IMPRESSIVE_POINTS = 4;
    static inline var SUFFICIENTLY_IMPRESSIVE_POINTS_DECREASE_INTERVAL_FRAMES = 60;

    static inline var SAYING_PROBABILITY = 0.5;

    public var active:Bool;
    public var visible:Bool;

    var sufficientlyImpressivePoints:Int;
    var sufficientlyImpressivePointsLastUpdatedFrame:Int;

    var frame:Int;

    var banners:Array<Text>;
    var nextBanner:Int;

    var sayings:Sayings;

    public function new() {
        active = true;
        visible = true;

        var fontFace = new FontFace(Assets.getFont("assets/04B_03__.ttf").fontName);

        frame = 0;

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

        sayings = new Sayings();

        reset();
    }

    public function reset() {
        sufficientlyImpressivePoints = MIN_SUFFICIENTLY_IMPRESSIVE_POINTS;
        sufficientlyImpressivePointsLastUpdatedFrame = frame;
    }

    public function onHitBrick(points:Int, x:Float, y:Float) {
        var banner = banners[nextBanner];

        if (points >= sufficientlyImpressivePoints) {
            banner.text = Std.string(points);
            Actuate.tween(banner, 1, { scale: 128, alpha: 0 })
                    .ease(Cubic.easeIn);

            sufficientlyImpressivePoints = nextHighestPowerOfTwo(points);
            sufficientlyImpressivePointsLastUpdatedFrame = frame;
        } else if (Math.random() < SAYING_PROBABILITY) {
            banner.text = sayings.forHitBrick();
            Actuate.tween(banner, 3, { scale: 8, alpha: 0, y: -24 })
                    .ease(Linear.easeNone);
        } else {
            return;
        }

        banner.centerOrigin();
        banner.scale = 1;
        banner.x = x;
        banner.y = y;
        banner.alpha = 0.8;

        nextBanner = (nextBanner + 1) % MAX_BANNERS;
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

    function nextHighestPowerOfTwo(value:Int) {
        value |= value >> 1;
        value |= value >> 2;
        value |= value >> 4;
        value |= value >> 8;
        value |= value >> 16;
        return value + 1;
    }
}
