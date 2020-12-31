using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;

class Background extends WatchUi.Drawable {

    private var _color;

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function setColor(color) {
        self._color = color;
    }

    function draw(dc) {
        dc.setColor(Graphics.COLOR_TRANSPARENT, self._color);
        dc.clear();
    }
}

