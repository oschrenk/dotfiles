# -*- coding: utf-8 -*-

from datetime import datetime
import sublime_plugin


class TimestampCommand(sublime_plugin.EventListener):
    """Expand `utc`, `date`, `tod`, `today `,`time`, `tim` and `now`
    """
    def on_query_completions(self, view, prefix, locations):
        if prefix == 'utc':
            val = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S')
        elif prefix in ('date', 'today', 'tod'):
            val = datetime.now().strftime('%Y-%m-%d')
        elif prefix in ('time', 'tim', 'now'):
            val = datetime.now().strftime('%H:%M:%S')
        else:
            val = None

        return [(prefix, prefix, val)] if val else []