#!/usr/bin/env python
from flask import Flask, render_template
from flask_restful import Api

# from praytime_raspberrypi import myPrayTimes_experiments as praytimes
import get_prayerTimes as prayertimes

import datetime

app = Flask(__name__)
api = Api(app)


@app.route('/')
def home():
    date = datetime.date.today()
    weekday = date.strftime("%A   %Y-%m-%d")
    prayertimes_today = (weekday, prayertimes.getTimes(date))

    prayertimes_next_7_days = []

    for i in range(1, 8):
        date = datetime.date.today() + datetime.timedelta(days=i)
        weekday = date.strftime("%A   %Y-%m-%d")
        prayertimes_dict = (weekday, prayertimes.getTimes(date))
        prayertimes_next_7_days.append(prayertimes_dict)

    return render_template('prayers.html',
                           times_today=prayertimes_today,
                           times_next_days=prayertimes_next_7_days)

    # return json.dumps(prayertimes.getTimes())


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=80)
