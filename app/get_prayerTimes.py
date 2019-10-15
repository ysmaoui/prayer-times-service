from praytimes import PrayTimes

places = {'berlin': (52.511, 13.44013)}


def getTimes(for_date):
    prayTimes = PrayTimes()
    prayTimes.setMethod('test')
    new_settings = {
        "imsak": '10 min',
        "dhuhr": '0 min',
        "asr": 'Standard',
        "highLats": 'AngleBased',
        "maghrib": '-6 min'
    }

    offset = {
        "fajr": -2,
        "dhuhr": +5,
        "asr": +5,
        "maghrib": 0,
        "isha": -3
    }

    prayTimes.adjust(new_settings)
    prayTimes.tune(offset)
    isSummerTime = 1
    times = prayTimes.getTimes(for_date, places['berlin'], 1, dst=isSummerTime)

    return times
