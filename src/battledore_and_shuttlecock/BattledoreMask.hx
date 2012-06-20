package battledore_and_shuttlecock;

import flash.display.Sprite;
import hopscotch.collision.BoxMask;
import hopscotch.collision.Mask;

class BattledoreMask extends Mask {
    static inline var HALF_WIDTH = Battledore.WIDTH * 0.5;
    static inline var HALF_HEIGHT = Battledore.HEIGHT * 0.5;

    var battledore:Battledore;

    var collisionContainer:Sprite;
    var mask:Sprite;
    var hitObject:Sprite;

    public function new(battledore:Battledore) {
        super();

        this.battledore = battledore;

        collisionContainer = new Sprite();
        mask = new Sprite();
        hitObject = new Sprite();

        collisionContainer.addChild(mask);
        collisionContainer.addChild(hitObject);

        implement(BoxMask, collideBoxMask);
    }

    public function updateMask() {
        var graphics = mask.graphics;
        graphics.clear();
        graphics.lineStyle();

        graphics.beginFill(0xffffff, 1);
        graphics.moveTo(battledore.prevX - HALF_WIDTH, battledore.prevY - HALF_HEIGHT);
        graphics.lineTo(battledore.x - HALF_WIDTH, battledore.y - HALF_HEIGHT);
        graphics.lineTo(battledore.x + HALF_WIDTH, battledore.y - HALF_HEIGHT);
        graphics.lineTo(battledore.prevX + HALF_WIDTH, battledore.prevY - HALF_HEIGHT);
        graphics.lineTo(battledore.prevX - HALF_WIDTH, battledore.prevY - HALF_HEIGHT);
        graphics.endFill();

        graphics.beginFill(0xff0000, 1);
        graphics.moveTo(battledore.prevX + HALF_WIDTH, battledore.prevY - HALF_HEIGHT);
        graphics.lineTo(battledore.x + HALF_WIDTH, battledore.y - HALF_HEIGHT);
        graphics.lineTo(battledore.x + HALF_WIDTH, battledore.y + HALF_HEIGHT);
        graphics.lineTo(battledore.prevX + HALF_WIDTH, battledore.prevY + HALF_HEIGHT);
        graphics.lineTo(battledore.prevX + HALF_WIDTH, battledore.prevY - HALF_HEIGHT);
        graphics.endFill();

        graphics.beginFill(0x00ff00, 1);
        graphics.moveTo(battledore.prevX + HALF_WIDTH, battledore.prevY + HALF_HEIGHT);
        graphics.lineTo(battledore.x + HALF_WIDTH, battledore.y + HALF_HEIGHT);
        graphics.lineTo(battledore.x - HALF_WIDTH, battledore.y + HALF_HEIGHT);
        graphics.lineTo(battledore.prevX - HALF_WIDTH, battledore.prevY + HALF_HEIGHT);
        graphics.lineTo(battledore.prevX + HALF_WIDTH, battledore.prevY + HALF_HEIGHT);
        graphics.endFill();

        graphics.beginFill(0x0000ff, 1);
        graphics.moveTo(battledore.prevX - HALF_WIDTH, battledore.prevY + HALF_HEIGHT);
        graphics.lineTo(battledore.x - HALF_WIDTH, battledore.y + HALF_HEIGHT);
        graphics.lineTo(battledore.x - HALF_WIDTH, battledore.y - HALF_HEIGHT);
        graphics.lineTo(battledore.prevX - HALF_WIDTH, battledore.prevY - HALF_HEIGHT);
        graphics.lineTo(battledore.prevX - HALF_WIDTH, battledore.prevY + HALF_HEIGHT);
        graphics.endFill();
    }

    function collideBoxMask(mask2:BoxMask, x1:Float, y1:Float, x2:Float, y2:Float) {
        var graphics = hitObject.graphics;
        graphics.clear();
        graphics.beginFill(0xffff00, 1);
        graphics.drawRect(x2 + mask2.x, y2 + mask2.y, mask2.width, mask2.height);
        graphics.endFill();

        return mask.hitTestObject(hitObject);
    }
}
