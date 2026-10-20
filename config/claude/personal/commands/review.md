---
description: Run a goal check-in (weekly, monthly, or quarterly)
argument-hint: <weekly|monthly|quarterly>
---

# Goal Review

Run an interactive check-in against the user's 2026 goals.

## Arguments

`$ARGUMENTS` should be one of: `weekly`, `monthly`, `quarterly`. If empty, ask which type of review to run.

## Goal Files

Determine the current year from today's date. Goal files live at `20 Areas/Plan/Goals/<current year>/`. List the directory to discover which goal files exist — do not hardcode filenames.

Review templates live at `20 Areas/Plan/Meta/Reviews/`:
- `Monthly.md`
- `Quarterly.md`

## Instructions

### Step 0: Determine review type

If `$ARGUMENTS` is empty or not one of `weekly`/`monthly`/`quarterly`, ask the user which review to run using AskUserQuestion.

### Step 1: Read goal files

Read ALL 7 goal files from `20 Areas/Plan/Goals/<current year>/`. Identify the current month's progress section in each.

### Step 2: Run the review

Use **progressive disclosure**: start with a summary, then go deeper only where the user wants.

---

#### Weekly Review

**Purpose**: Close the week that ended and open the week ahead.

The vault already defines this review. **Read `20 Areas/Plan/Routines/Weekly Review.md`
first and follow its sections.** Do not invent a structure. It splits into two sittings,
Saturday 05:30 looks back (sections 0 to 3), Sunday 05:30 looks forward (sections 0, 4 to 6).
Say which sitting you are running; on any other day, or when asked for the whole review, run
both back to back.

**Also read, every time:**

- `20 Areas/Plan/Routines/Daily Schedule.md` — fixed points, the four career blocks, the
  weekend hobby blocks, the Sunday work block. **It describes the optimal week, not a real
  one.** The macOS calendar holds the actual week. A difference between them is the design
  meeting reality, not a mistake in either: never edit the file to match the calendar, and do
  not list the gap as a finding. Sustained drift over several weeks is a monthly-review
  question about whether the design still fits; a single week's difference is just that week
- `20 Areas/Plan/Routines/Daily Non-Negotiables.md` — the three habits being counted
- **Last week's weekly note**, `40 Journals/Personal/YYYY-Www.md` — this is the record of
  what was planned. Open it and walk its `## Goals` and `## Tasks` line by line
- The current month's section in each `20 Areas/Plan/Goals/<year>/*.md`

**This review is a conversation, not a report.** Oliver disengages when handed tables to
read. Every step ends in a question. Data exists to set up a question, never as the output.
If you have written more than a short paragraph without asking something, cut it and ask.

##### Saturday — close the week

1. **Open last week's note.** Read its Goals and Tasks aloud, then ask item by item what
   happened. An unchecked box is a question, never a verdict. If the note is empty or missing,
   say so and ask the counts directly.

2. **Count, do not estimate.** Section 2 of the routine is the only feedback loop the plan has.
   Ask one item per question, at most four per AskUserQuestion call, with frequency options
   ("Every day", "3 to 5 days", "1 to 2 days", "None"). The three habits, the five morning
   movement sessions (full or floor), the four yoga classes, the four career blocks and whether
   they ended on time, the days that cleared 8,000 steps, weight, and what slipped first.
   Mobility, protein, steps and yoga are four questions, not one.

3. **Say what you cannot verify, then ask.** There are usually no daily journal files, so the
   habit checkboxes carry no data. Never infer that a habit held because nothing contradicts it.

4. **Ask what got in the way** for whatever came back below target. Do not propose the reason.

5. **Run the system checklist**, then ask rather than report:

```
arbol status --plain --state attention
```

   Name only the repositories that are old — weeks, not hours — and ask which he wants on next
   week's list.

6. **Money, section 3.** Ask whether anything unexpected showed up in the accounts.

##### Sunday — open the week

Ask about all four of these. They are separate conversations, not one planning question.

7. **Career and Spanish.** Four blocks are fixed in the schedule: Mon CKA, Wed AI, Thu CKA,
   Fri AI, plus Tuesday Spanish. Ask what goes in each one. Then ask about the Monday double,
   yes or no now rather than on Monday, and confirm the four yoga bookings.

8. **Work.** Ask what the week's work commitments are, and specifically what the Sunday 08:00
   to 10:00 block has to prepare so Monday does not open cold for European time.

9. **Personal.** Ask what the week holds outside work: appointments, people, Liza, travel,
   anything already booked. Build the plan around these rather than on top of them.

10. **Hobby blocks.** Four blocks across the weekend, assigned a week ahead. **One named
    project per block, never a category.** Ask about each block separately — "what goes in
    Saturday morning" is a different question from "what goes in Sunday afternoon", because
    the lengths differ and so does what fits. Oliver stated the lengths on 2026-09-26 as
    4h, 3.5h, 3.5h and 2h. Deciding at 08:00 on the day is how four hours becomes two hours
    of deciding — that is why this is asked now.

11. **How, not whether, per goal area.** For each area with something live this month, ask how
    he will tackle it rather than whether he will. "Career wants one article this month — which
    session writes it?" is the question shape. "Will you write the article?" is not.

12. **Write.** Section 5 is the weekly journal entry. Read the plan back, get a yes, then write
    the weekly note.

##### The weekly note

- Path: `40 Journals/Personal/YYYY-Www.md`, for example `2026-W40.md`
- Template: `99 Templates/Journal/Personal/Weekly.md`
- Frontmatter: `tags: ["#notes/weekly"]`, `journal: Personal weekly`, `journal-date: <first day of the week>`.
  The plugin uses locale weeks, which start Sunday.
- Body: a `calendar-nav` block, the `# <title>` heading, then `## Goals` and `## Tasks`
- Sections, in order: `## Goals` for the recurring standards, `## Tasks` for one-off actions,
  `## Career Blocks` for the five weekday sessions, `## Hobby Blocks` grouped under a dated
  heading per weekend day with times, and `## Work` for the Sunday block
- Write a constraint next to the block it constrains, not in a separate note
- Cancelled items use `- [-]`, the vault's existing convention
- The next week's review reads this file first, so write it to be read cold

#### Monthly Review

**Purpose**: Reflect and adjust. 15-20 minutes.

1. **Read the Monthly review template** from `20 Areas/Plan/Meta/Reviews/Monthly.md`.

2. **Show progress summary**: For each goal area, compare what was planned for the current month vs what's filled in. Highlight gaps.

3. **Walk through progressively** — don't dump everything at once:

   **Round 1 — Big picture** (AskUserQuestion):
   - "What are 3 things you accomplished this month that you're proud of?"
   - Let the user type freely.

   **Round 2 — Life Audit** (AskUserQuestion):
   Rate each dimension 1-10:
   - Body (movement, rest, nutrition)
   - Mind (emotions, mindfulness, stress, confidence)
   - Home (living environment, location)
   - Earth (connection to nature, sustainability)
   - Connection (relationships, family, partner, community)
   - Purpose (meaningful work, career direction, contribution)
   - Recreation (passions, downtime, fun, adventures)
   - Growth (learning, habits, goal progress)

   Present the lowest 2-3 scores and ask: "Which of these do you want to focus on next month?"

   **Round 3 — Goal review** (AskUserQuestion):
   For each goal area, ask: "Start, Stop, or Continue?" — but only for areas where there's something to discuss (gaps, completed items, or stale goals).

   **Round 4 — Plan next month**:
   Based on the conversation, propose updates to next month's progress sections in the goal files. Show the proposed changes and ask for approval before writing.

4. **Update goal files** with the month's actuals and next month's plan.

---

#### Quarterly Review

**Purpose**: Deeper reflection and course correction. 30 minutes.

1. **Read the Quarterly review template** from `20 Areas/Plan/Meta/Reviews/Quarterly.md`.

2. **Read all 3 months of progress** for the quarter from each goal file.

3. **Walk through progressively**:

   **Round 1 — Highlights**:
   Summarize the quarter's progress across all areas in a compact table. Ask: "What are 3 things you accomplished this quarter that you're proud of?"

   **Round 2 — Life Audit** (same 8 dimensions as monthly, but with quarter context).

   **Round 3 — Goal relevance check**:
   For each goal area, present:
   - What was planned for the quarter
   - What actually happened
   - Ask: "Does this goal still feel relevant? Adjust, release, or continue?"

   **Round 4 — Lessons**: "What are 3 lessons you've learned this quarter?"

   **Round 5 — Next quarter planning**:
   Propose the next 3 months of progress entries across all goal files. Show changes, get approval, then write.

4. **Update goal files** with quarter actuals and next quarter plan.

## Rules

- **Progressive disclosure**: Never dump all questions at once. Go round by round.
- **Be conversational**: This is a reflection session, not a form to fill out.
- **Use AskUserQuestion** for structured choices, but let the user type freely for reflections (wins, lessons, etc.).
- **Always show proposed file changes** before writing to goal files.
- **Don't judge**: Frame gaps neutrally. "This didn't happen" not "You failed at this."
- **Keep weekly reviews under 5 minutes**, monthly under 20, quarterly under 30.
- **Current date context**: Use today's date to determine which month/quarter/week we're in.
