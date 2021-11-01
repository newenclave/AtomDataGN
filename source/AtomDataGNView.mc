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
        var prefix = "";
        var postfix = "";
        var d = App.getApp().getDoseRate();

        if(ready) {
            self._fitContibution.update({
                :doseRate => d,
                :temperature => App.getApp().getTemperature(),
                :sessionDoze => App.getApp().getSessionDoseAccumulated()
            });
        } else {
            prefix = "(";
            postfix = ")";
        }

        if(self._useR) {
            result = prefix + (d * 100.0).format("%.2f") + postfix;
        } else {
            result = prefix + (d).format("%.2f") + postfix;
        }

        self._doseRate = d;

        return result;
    }
}
