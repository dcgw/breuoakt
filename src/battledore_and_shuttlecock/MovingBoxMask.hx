package battledore_and_shuttlecock;

import hopscotch.collision.BoxMask;
import flash.display.Sprite;
import hopscotch.collision.Mask;

class MovingBoxMask extends Mask {
    var collisionContainer:Sprite;
    var movingBox:Sprite;
    var box:Sprite;

    public function new () {
        super();

        collisionContainer = new Sprite();
        movingBox = new Sprite();
        box = new Sprite();

        collisionContainer.addChild(movingBox);
        collisionContainer.addChild(box);

        implement(BoxMask, collideBoxMask);
        implement(MovingBoxMask, collideMovingBoxMask);
    }

    public function updateMask (x1:Float, y1:Float, w1:Float, h1:Float,
    x2:Float, y2:Float, w2:Float, h2:Float) {
        var graphics = movingBox.graphics;
        graphics.clear();
        graphics.lineStyle();

        graphics.beginFill(0xff00ff, 1);
        graphics.moveTo(x1, y1);
        graphics.lineTo(x1 + w1, y1);
        graphics.lineTo(x1 + w1, y1 + h1);
        graphics.lineTo(x1, y1 + h1);
        graphics.lineTo(x1, y1);
        graphics.endFill();

        graphics.beginFill(0x00ffff, 1);
        graphics.moveTo(x2, y2);
        graphics.lineTo(x2 + w2, y2);
        graphics.lineTo(x2 + w2, y2 + h2);
        graphics.lineTo(x2, y2 + h2);
        graphics.lineTo(x2, y2);
        graphics.endFill();

        graphics.beginFill(0xffffff, 1);
        graphics.moveTo(x1, y1);
        graphics.lineTo(x2, y2);
        graphics.lineTo(x2 + w2, y2);
        graphics.lineTo(x1 + w1, y1);
        graphics.lineTo(x1, y1);
        graphics.endFill();

        graphics.beginFill(0xff0000, 1);
        graphics.moveTo(x1 + w1, y1);
        graphics.lineTo(x2 + w2, y2);
        graphics.lineTo(x2 + w2, y2 + h2);
        graphics.lineTo(x1 + w1, y1 + h1);
        graphics.lineTo(x1 + w1, y1);
        graphics.endFill();

        graphics.beginFill(0x00ff00, 1);
        graphics.moveTo(x1 + w1, y1 + h1);
        graphics.lineTo(x2 + w2, y2 + h2);
        graphics.lineTo(x2, y2 + h2);
        graphics.lineTo(x1, y1 + h1);
        graphics.lineTo(x1 + w1, y1 + h1);
        graphics.endFill();

        graphics.beginFill(0x0000ff, 1);
        graphics.moveTo(x1, y1 + h1);
        graphics.lineTo(x2, y2 + h2);
        graphics.lineTo(x2, y2);
        graphics.lineTo(x1, y1);
        graphics.lineTo(x1, y1 + h1);
        graphics.endFill();
    }

    function collideBoxMask (mask2:BoxMask, x1:Float, y1:Float, x2:Float, y2:Float) {
        var graphics = box.graphics;
        graphics.clear();
        graphics.beginFill(0xffff00, 1);
        graphics.drawRect(x2 + mask2.x, y2 + mask2.y, mask2.width, mask2.height);
        graphics.endFill();

        movingBox.x = x1;
        movingBox.y = y1;

        return movingBox.hitTestObject(box);
    }

    function collideMovingBoxMask (mask2:MovingBoxMask, x1:Float, y1:Float, x2:Float, y2:Float) {
        collisionContainer.addChild(mask2.movingBox);

        movingBox.x = x1;
        movingBox.y = y1;

        mask2.movingBox.x = x2;
        mask2.movingBox.y = y2;

        var result = movingBox.hitTestObject(mask2.movingBox);

        mask2.collisionContainer.addChild(mask2.movingBox);

        return result;
    }
}
