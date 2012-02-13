package net.noiseinstitute.battledore_and_shuttlecock {
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.getDefinitionByName;

    [SWF(width="640", height="480", frameRate="60", backgroundColor="000000")]
    public class Preloader extends Sprite {
        private static const MAIN_CLASS_NAME:String ="net.noiseinstitute.battledore_and_shuttlecock.Main";

        private static const BACKGROUND_COLOUR:uint = 0x000000;
        private static const FOREGROUND_COLOUR:uint = 0xFFFFFF;

        [Embed(source="/net/flashpunk/graphics/04B_03__.TTF", embedAsCFF="false", fontFamily="default")]
        private static const FONT:Class;

        private var progressBar:Shape;
        private var text:TextField;

        private var progressBarX:int;
        private var progressBarY:int;

        private var progressBarWidth:int;
        private var progressBarHeight:int;

        private static const PROGRESS_BAR_FRAME_SIZE:int = 2;

        public function Preloader() {
            const stageWidth:int = stage.stageWidth;
            const stageHeight:int = stage.stageHeight;

            graphics.beginFill(BACKGROUND_COLOUR);
            graphics.drawRect(0, 0, stageWidth, stageHeight);
            graphics.endFill();

            progressBarWidth = stageWidth * 0.8;
            progressBarHeight = 20;

            progressBarX = (stageWidth - progressBarWidth) * 0.5;
            progressBarY = (stageHeight - progressBarHeight) * 0.5;

            graphics.beginFill(FOREGROUND_COLOUR);
            graphics.drawRect(progressBarX - PROGRESS_BAR_FRAME_SIZE,
                    progressBarY - PROGRESS_BAR_FRAME_SIZE,
                    progressBarWidth + PROGRESS_BAR_FRAME_SIZE * 2,
                    progressBarHeight + PROGRESS_BAR_FRAME_SIZE * 2);
            graphics.endFill();

            progressBar = new Shape();
            addChild(progressBar);

            text = new TextField();
            text.textColor = FOREGROUND_COLOUR;
            text.selectable = false;
            text.mouseEnabled = false;
            text.defaultTextFormat = new TextFormat("default", 16);
            text.embedFonts = true;
            text.autoSize = TextFieldAutoSize.LEFT;
            text.text = "0%";
            text.x = (stageWidth - text.width) * 0.5;
            text.y = stageHeight * 0.5 + progressBarHeight;

            addChild(text);

            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onEnterFrame(e:Event):void {
            if (hasLoaded()) {
                graphics.clear();
                graphics.beginFill(BACKGROUND_COLOUR);
                graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
                graphics.endFill();

                start();
            } else {
                var progress:Number = (loaderInfo.bytesLoaded / loaderInfo.bytesTotal);
                if (isNaN(progress)) {
                    progress = 0;
                }

                progressBar.graphics.clear();
                progressBar.graphics.beginFill(BACKGROUND_COLOUR);
                progressBar.graphics.drawRect(0, 0,
                        progress * progressBarWidth, progressBarHeight);
                progressBar.graphics.endFill();

                text.text = String(Math.round(progress * 100)) + "%";

                text.x = (stage.stageWidth - text.width) * 0.5;
            }
        }

        private function hasLoaded():Boolean {
            return (loaderInfo.bytesLoaded >= loaderInfo.bytesTotal);
        }

        private function start():void {
            stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

            var mainClass:Class = Class(getDefinitionByName(MAIN_CLASS_NAME));
            parent.addChild(DisplayObject(new mainClass));

            parent.removeChild(this);
        }
    }
}
