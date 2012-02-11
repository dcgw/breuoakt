package net.noiseinstitute.battledore_and_shuttlecock {
    import net.flashpunk.Entity;
    import net.flashpunk.graphics.Image;

    public class Net extends Entity {
        public function Net () {
            var image:Image = Image.createRect(8, 240);
            image.originX = image.width * 0.5;
            image.originY = image.height;
            graphic = image;

            setHitbox(image.width, image.height, image.originX, image.originY);
        }
    }
}
