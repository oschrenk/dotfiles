# Brew Coffee

Dial in a coffee bean for the user's setup. Refer to SKILL.md for gear defaults and file paths.

## Step 1: Quick Setup Check

Use AskUserQuestion to confirm or adjust the session:

**Question 1 - Serving size:**
- Header: "Serving"
- Question: "Brewing for how many?"
- Options:
  - "Just me (15g)" - Default single dose
  - "Two people (24g)" - Default double dose
  - "Custom" - Specify different amount

**Question 2 - Equipment:**
- Header: "Setup"
- Question: "Using your usual setup? (Ode + Switch)"
- Options:
  - "Yes, defaults" - Use Fellow Ode SSP MP + Switch
  - "Different grinder" - Using K Ultra today
  - "Different brewer" - V60 or Aeropress

**Question 3 - Water:**
- Header: "Water"
- Question: "Water prep today?"
- Options:
  - "Usual mix" - Tap + demineralized (default)
  - "Straight tap" - No mixing today
  - "Special prep" - Different mineral content

## Step 2: Recipe Selection

Check the user's recipe catalog before generating anything.

1. Use Glob to find recipes for the selected brewer (e.g., `[Base]/Recipes/Switch/*.md` — see SKILL.md for base path)
2. Read the found recipe files to get their names and summaries
3. Present available recipes plus a "Generate new" option

**Question - Recipe choice:**
- Header: "Recipe"
- Question: "Which recipe do you want to use?"
- Options:
  - [List saved recipes by name from the catalog]
  - "Generate new" - Let me create a custom recipe based on your bean

**If user selects a saved recipe:**
- Read the full recipe file
- Apply the appropriate variant based on bean type (light/medium/dark)
- Adjust dose based on serving size
- Skip to output (no need for flavor goals questions)

**If user selects "Generate new":**
- Continue to Step 3

## Step 3: Bean Information

**Question - Bean details:**
- Header: "Bean"
- Question: "Tell me about the bean (roast, origin, process, any tasting notes on the bag)"
- Options:
  - "Light washed" - Bright, clean, acidic
  - "Light natural" - Fruity, funky, sweet
  - "Medium washed" - Balanced, approachable
  - "Medium natural" - Sweet, fruity body
  - (User will likely select "Other" to give specifics)

## Step 4: Flavor Goals

**Question - Target profile:**
- Header: "Goal"
- Question: "What are you aiming for with this cup?"
- Options:
  - "Balanced" - Even extraction, no extremes
  - "Bright & acidic" - Highlight origin character
  - "Sweet & smooth" - Mellow, approachable
  - "Full body" - Rich, heavy mouthfeel

**Question - Past issues (optional):**
- Header: "Issues"
- Question: "Any problems with this bean previously?"
- Options:
  - "None / First time" - No history
  - "Too sour/acidic" - Under-extracted last time
  - "Too bitter/harsh" - Over-extracted last time
  - "Weak/watery" - Lacking body or strength

## Step 5: Output Style

**Question - Recipe format:**
- Header: "Style"
- Question: "How detailed should the recipe be?"
- Options:
  - "Coaching" - Full explanation with reasoning and troubleshooting
  - "Quick card" - Just the data, no fluff

## Output Format

**IF Style = "Coaching":**
1. **Strategy:** Why this recipe suits this bean on the Switch
2. **Recipe:**
   - Dose / Ratio / Total water
   - Grind setting (Ode SSP MP - use calibration from SKILL.md)
   - Water temp (°C primary, °F secondary)
3. **Step-by-Step:**
   - Bloom details (time, water amount, agitation)
   - Immersion phase (valve closed timing)
   - Release/percolation phase
   - Total target time
4. **Dial-in Guide:**
   - What to taste for
   - If sour → adjust X
   - If bitter → adjust Y
   - If thin → adjust Z

**IF Style = "Quick card":**

Single temp:
```
Dose:     Xg
Water:    Xg (1:XX ratio)
Grind:    X on Ode SSP MP
Temp:     XX°C

Steps:
0:00  |  Bloom Xg, swirl
0:XX  |  Close valve, pour to Xg
X:XX  |  Open valve, drain
X:XX  |  Target finish

Notes: [One line adjustment tip]
```

Multi-temp (show temp per step):
```
Dose:     Xg
Water:    Xg (1:XX ratio)
Grind:    X.X on Ode SSP MP

Steps:
0:00  |  Bloom Xg @ XX°C, valve closed
0:XX  |  Open valve
0:XX  |  Pour to Xg @ XX°C, valve open
X:XX  |  Close valve, pour to Xg @ XX°C
X:XX  |  Open valve, drain
X:XX  |  Target finish

Notes: [One line adjustment tip]
```

## After Brewing

Ask if the user wants to log results. If yes, read `log.md` in this skill directory and follow its instructions.
