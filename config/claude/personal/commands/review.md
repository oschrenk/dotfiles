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

**Purpose**: Quick pulse check. 5 minutes.

1. **Show a dashboard** of this week's commitments across all areas. Pull from the current month's planned items in each goal file. Present as a compact checklist:

```
This week (March W1):
Career:  [ ] CKA study: core concepts  [ ] Blog post
Health:  [ ] Ran 3x  [ ] Yoga 2x
Mental:  [ ] Weekly journal entry
Spanish: [ ] Classes attended
Reading: [ ] 15 pages/day
```

2. **Ask one question**: "How did this week go?" using AskUserQuestion with options:
   - "On track" — acknowledge, done
   - "Mixed" — ask which areas need attention, offer to adjust next week
   - "Off track" — ask what got in the way, help reprioritize

3. **If the user wants to go deeper** on any area, read that specific goal file and discuss. Otherwise, wrap up.

---

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
