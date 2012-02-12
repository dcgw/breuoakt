package net.noiseinstitute.battledore_and_shuttlecock {
    import flash.display.Graphics;
    import flash.display.Sprite;

    import net.flashpunk.FP;
    import net.flashpunk.Mask;

    public class BattledoreMask extends Mask {
        private var battledore:Battledore;

        private var collisionContainer:Sprite = new Sprite();
        private var mask:Sprite = new Sprite();
        private var hitObject:Sprite = new Sprite();

        public function BattledoreMask(battledore:Battledore) {
            this.battledore = battledore;

            collisionContainer.addChild(mask);
            collisionContainer.addChild(hitObject);

            _check[Mask] = collideMask;
        }

        public function updateMask():void {
            update();

            var halfWidth:Number = battledore.battledoreWidth * 0.5;
            var halfHeight:Number = battledore.battledoreHeight * 0.5;

            var graphics:Graphics = mask.graphics;
            graphics.clear();
            graphics.lineStyle();

            graphics.beginFill(0xffffff, 1);
            graphics.moveTo(battledore.prevX - halfWidth, battledore.prevY - halfHeight);
            graphics.lineTo(battledore.x - halfWidth, battledore.y - halfHeight);
            graphics.lineTo(battledore.x + halfWidth, battledore.y - halfHeight);
            graphics.lineTo(battledore.prevX + halfWidth, battledore.prevY - halfHeight);
            graphics.lineTo(battledore.prevX - halfWidth, battledore.prevY - halfHeight);
            graphics.endFill();

            graphics.beginFill(0xff0000, 1);
            graphics.moveTo(battledore.prevX + halfWidth, battledore.prevY - halfHeight);
            graphics.lineTo(battledore.x + halfWidth, battledore.y - halfHeight);
            graphics.lineTo(battledore.x + halfWidth, battledore.y + halfHeight);
            graphics.lineTo(battledore.prevX + halfWidth, battledore.prevY + halfHeight);
            graphics.lineTo(battledore.prevX + halfWidth, battledore.prevY - halfHeight);
            graphics.endFill();

            graphics.beginFill(0x00ff00, 1);
            graphics.moveTo(battledore.prevX + halfWidth, battledore.prevY + halfHeight);
            graphics.lineTo(battledore.x + halfWidth, battledore.y + halfHeight);
            graphics.lineTo(battledore.x - halfWidth, battledore.y + halfHeight);
            graphics.lineTo(battledore.prevX - halfWidth, battledore.prevY + halfHeight);
            graphics.lineTo(battledore.prevX + halfWidth, battledore.prevY + halfHeight);
            graphics.endFill();

            graphics.beginFill(0x0000ff, 1);
            graphics.moveTo(battledore.prevX - halfWidth, battledore.prevY + halfHeight);
            graphics.lineTo(battledore.x - halfWidth, battledore.y + halfHeight);
            graphics.lineTo(battledore.x - halfWidth, battledore.y - halfHeight);
            graphics.lineTo(battledore.prevX - halfWidth, battledore.prevY - halfHeight);
            graphics.lineTo(battledore.prevX - halfWidth, battledore.prevY + halfHeight);
            graphics.endFill();
        }

        override protected function update():void {
            parent.originX = parent.x;
            parent.originY = parent.y;
            parent.width = Main.WIDTH;
            parent.height = Main.HEIGHT;
        }

        private function collideMask(other:Mask):Boolean {
            var graphics:Graphics = hitObject.graphics;
            graphics.clear();
            graphics.beginFill(0xffff00, 1);
            graphics.drawRect(other.parent.x - other.parent.originX,
                    other.parent.y - other.parent.originY,
                    other.parent.width,
                    other.parent.height);
            graphics.endFill();

            return mask.hitTestObject(hitObject);
        }

        override public function renderDebug(g:Graphics):void {
            FP.engine.alpha = 0.5;
            FP.stage.addChild(collisionContainer);
        }
    }
}
