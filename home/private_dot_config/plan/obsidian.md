## Schedule

{% for e in events %}- {{ e.schedule.start.at|format:"HH:mm"}} - {{ e.schedule.end.at|format:"HH:mm"}}{% if e.calendar.label|lowercase == "timewax" and e.services["meet"] %} [[30 Areas/Timewax/Meetings/{{e.schedule.start.at|format:"yyyy-MM-dd"}}-meeting|{{e.title.full}}]]{% else %}{{ e.title.full }}{% endif %} [📅]({{e.services["ical"]}}) #calendar/{{ e.calendar.label|lowercase }}
{% endfor %}
