package net.noiseinstitute.battledore_and_shuttlecock {
    import flash.geom.Point;

    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Image;
    import net.flashpunk.utils.Input;

    public class Battledore extends Entity {
        public var offsetX:Number = 0;

        public var prevX:Number = 0;
        public var prevY:Number = 0;

        public var battledoreWidth:Number = 8;
        public var battledoreHeight:Number = 64;

        public var velocity:Point = new Point;

        private var battledoreMask:BattledoreMask;

        public function Battledore() {
            var image:Image = Image.createRect(battledoreWidth, battledoreHeight);
            image.centerOrigin();
            graphic = image;

            mask = battledoreMask = new BattledoreMask(this);
        }

        override public function update():void {
            prevX = x;
            prevY = y;

            x = Input.mouseX + offsetX;
            y = Input.mouseY;

            velocity.x = x - prevX;
            velocity.y = y - prevY;

            battledoreMask.updateMask();

            super.update();
        }
    }
}
