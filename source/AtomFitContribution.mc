using Toybox.FitContributor as Fit;

class AtomFitContribution {

    const FIELD_DOSE_POWER = 0;
    const FIELD_TEMPERATURE = 1;
    const FIELD_SESSION_DOSE = 2;

    private var _doseRate;
    private var _temperature;
    private var _sessionDoze;

    function initialize(activity) {
        self._doseRate = activity.createField("dose_rate",
            FIELD_DOSE_POWER,
            Fit.DATA_TYPE_FLOAT, {
                :units => "microsieverts"
            });

        self._temperature = activity.createField("temperature",
            FIELD_TEMPERATURE,
            Fit.DATA_TYPE_SINT8, {
                :units => "celsius"
            });

        self._sessionDoze = activity.createField("session_dose",
            FIELD_SESSION_DOSE,
            Fit.DATA_TYPE_FLOAT, {
                :units => "millisieverts",
                :mesgType => Fit.MESG_TYPE_SESSION,
            });
    }

    function update(data) {
        self._doseRate.setData(data.get(:doseRate));
        self._temperature.setData(data.get(:temperature));
        self._sessionDoze.setData(data.get(:sessionDoze));
    }
}
