package net.noiseinstitute.battledore_and_shuttlecock {
    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Image;
    import net.flashpunk.utils.Input;

    public class Battledore extends Entity {
        public var offsetX:Number = 0;

        public function Battledore() {
            var image:Image = Image.createRect(8, 64);
            image.centerOrigin();
            graphic = image;

            setHitbox(image.width, image.height, image.originX, image.originY);
        }

        override public function update():void {
            x = Input.mouseX + offsetX;
            y = Input.mouseY;

            super.update();
        }
    }
}
