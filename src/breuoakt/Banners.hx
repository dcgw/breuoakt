package breuoakt;

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

    public var active:Bool;
    public var visible:Bool;

    var banners:Array<Text>;
    var nextBanner:Int;

    public function new() {
        active = false;
        visible = true;

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
    }

    public function spawn(text:String, x:Float, y:Float) {
        var banner = banners[nextBanner];
        banner.text = text;
        banner.scale = 1;
        banner.centerOrigin();
        banner.x = x;
        banner.y = y;
        banner.alpha = 0.8;

        Actuate.tween(banner, 1, { scale: 128, alpha: 0 })
                .ease(Cubic.easeIn);

        nextBanner = (nextBanner + 1) % MAX_BANNERS;
    }

    public function beginGraphic (frame:Int) {
        for (banner in banners) {
            banner.beginGraphic(frame);
        }
    }

    public function endGraphic () {
        for (banner in banners) {
            banner.endGraphic();
        }
    }

    public function updateGraphic (frame:Int, screenSize:ScreenSize) {
    }

    public function render (target:BitmapData, position:Point, camera:Matrix) {
        for (banner in banners) {
            banner.render(target, position, camera);
        }
    }
}
