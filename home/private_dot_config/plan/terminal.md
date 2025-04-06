{% for e in events %}{{ e.schedule.start.at|format:"HH:mm"}}-{{ e.schedule.end.at|format:"HH:mm" }} {{ e.title.full }}
{% endfor %}
