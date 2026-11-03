---
name: timesheet
description: Fill Oliver's Timewax timesheet (apps.timewax.com/timesheets) from his calendar hours (`plan hours`). Triggers on "fill my timesheet", "do my hours", "timesheet for last week".
user-invocable: true
---

# Fill the Timewax timesheet

Hours come from `plan hours` and go into one row, **Development / General**, as a draft.
Never press **Submit**: Oliver checks and submits the week himself.

## Needs Chrome

The page is an ExtJS app; it needs the Claude in Chrome tools (`mcp__claude-in-chrome__*`).
Load the `anthropic-skills:chrome-browser` skill first.
A session without those tools spawns a peer: `spawn-claude --chrome orchestrator tab tw-timesheet <your-name>`.
Writing real timesheet data needs Oliver's approval typed in the session that writes. A relayed approval does not count.

## Steps

1. Get the hours. The default is last week; another week needs `--weeks-ago N`.

   ```bash
   plan hours --json --select-title imewax --weeks-ago 1
   ```

   The output has `days[]`, each with a `date` (yyyy-mm-dd) and a `total` in decimal hours.
2. Show Oliver one line per day with a non-zero `total`: date, weekday, hours, and the week total.
   Weekend days count like any other day. Wait for his OK.
3. In Chrome, open https://apps.timewax.com/timesheets/. If the login page shows, stop and ask Oliver to log in. Never type credentials.
4. Fill each day (see **Page** below), one cell at a time. Wait 1–3 s after each edit, then find the record again.
5. Read back every cell, plus the total of each period. Compare them with the plan numbers, and report a table: date, plan, timesheet, match.
6. Stop. Tell Oliver to check the week and submit it himself.

## Page

All work happens through JS in the iframe. The Chrome accessibility tree cannot see it, so `find` and `read_page` do not help.

```js
const f = document.querySelector('iframe[src*="/_/timesheets/"]'), w = f.contentWindow, Ext = w.Ext, d = f.contentDocument;
```

- **Weeks:** a URL cannot open a week. Open one from the list:
  `[...d.querySelectorAll('span.tim-link[data-type="master-open"]')].find(e => e.textContent.trim() === 'Week 44a').click()`.
  Then wait about 4 s. To step to the next or previous period, use
  `Ext.ComponentQuery.query('button[reference=nextWeek]').find(b => b.isVisible()).el.dom.click()` (or `previousWeek`), then wait about 3.5 s.
  To confirm the week, read `Ext.ComponentQuery.query('tim-time-page-header')[0].el.dom.innerText`, which shows for example `< Week 44b, 2026 >`.
- **Month split:** a week that crosses a month boundary is two periods, `Week Na` and `Week Nb`. Both show all 7 columns, but a column outside the period has an empty header.
  So a date belongs to the period whose header shows it as `Mon 26/10` .. `Sun 01/11`. Example: 44a is Mon 26 to Sat 31 Oct, and 44b is Sun 1 Nov only. `nextWeek` steps from 44a to 44b.
- **Cells:** the column `weekDay1` .. `weekDay7` is Mon .. Sun (the ISO weekday). Find the row by its names, not by its position:

  ```js
  const tg = Ext.ComponentQuery.query('tim-time-grid').find(g => g.isVisible()), s = tg.getStore(), ce = tg.findPlugin('cellediting');
  const rec = s.getAt(s.findBy(r => r.get('projectName') === 'Development' && r.get('activityName') === 'General'));
  ce.startEdit(rec, tg.getColumns().find(c => c.dataIndex === 'weekDay3'));
  ce.getActiveEditor().field.setValue('5.5'); ce.completeEdit();   // saves at once
  ```

- **Format:** decimal hours with a dot, for example `'5.5'`. Negative values become 0. Skip a day with 0 hours; writing 0 into an empty cell is untested.
- **Saving:** `completeEdit` saves at once (`POST /timesheets/api/`). There is no Save button, no toast and no autosync step, and the edited cell turns yellow. The store then reloads, but no `load` event fires, so wait and find `rec` again.
- **Read back:** use `rec.get('weekDayN').totalTime`, which can be a string or a number. Do not trust the label text: after an edit the grid switches its separator from `5.50` to `5,50`. For a period total, read `Ext.ComponentQuery.query('label[reference=weekDaysTotal]').find(l => l.isVisible()).text`, and change `,` to `.`.
- **Existing hours:** if a cell already holds a different value, stop and ask Oliver before you overwrite it.
- **Chrome tool quirk:** JS results that contain `key=value` text come back as `[BLOCKED: Cookie/query string data]`. Return JSON instead.
