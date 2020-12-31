using Toybox.WatchUi;
using Toybox.FitContributor as Fit;
using Toybox.Application as App;

class AtomDataGNView extends WatchUi.SimpleDataField {

    private var _fitContibution;
    private var _doseRate;
    private var _temperature;
    private var _useR;

    function initialize() {
        SimpleDataField.initialize();
        self._fitContibution = new AtomFitContribution(self);
        self._doseRate = 0.0;
        self._useR = false;
        label = App.loadResource(Rez.Strings.label_dose_rate);
    }

//    function onLayout(dc) {
//        View.setLayout(Rez.Layouts.MainLayout(dc));
//        View.findDrawableById("label").setText(Rez.Strings.label_dose_rate);
//        return true;
//    }

    function compute(info) {
        App.getApp().onCompute();
        var result = "--.--";
        self._useR = App.getApp().isRoentgen();
        var ready = App.getApp().isReady();
        if(ready) {
            var d = App.getApp().getDoseRate();
            if(self._useR) {
                result = (d * 100.0).format("%.2f");
            } else {
                result = (d).format("%.2f");
            }

            self._fitContibution.update({
                :doseRate => d,
                :temperature => App.getApp().getTemperature(),
                :sessionDoze => App.getApp().getSessionDoseAccumulated()
            });
            self._doseRate = d;
        }
        return result;
    }

//    function onUpdate(dc) {
//        var label = App.loadResource(Rez.Strings.label_dose_rate);
//
//        // Set the background color
//        View.findDrawableById("Background").setColor(getBackgroundColor());
//
//        // Set the foreground color and value
//        var value = View.findDrawableById("value");
//        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
//            value.setColor(Graphics.COLOR_WHITE);
//        } else {
//            value.setColor(Graphics.COLOR_BLACK);
//        }
//        value.setText(self._doseRate.format("%.2f"));
//        label = Lang.format("$1$ ($2$)", [label,
//            (self._useR ? App.loadResource(Rez.Strings.text_micro_roentgen_hours)
//               : App.loadResource(Rez.Strings.text_micro_sieverts_hours))]);
//
//        // Call parent's onUpdate(dc) to redraw the layout
//        View.onUpdate(dc);
//    }
}
