---
name: add-recipe
description: Add a new coffee recipe to your personal catalog. Stores recipes organized by brewer, with variants for different bean types.
---

# Add Recipe

Add a new coffee recipe to the user's personal catalog at `20 Areas/Interests/Coffee/Recipes/`.

## Approach

Be conversational. Don't force rigid multiple-choice for things that are naturally free-text (recipe name, parameters, steps). Use AskUserQuestion sparingly for true choices, and let the user describe things in their own words.

## Instructions

### Step 1: Brewer

**Question - Brewer:**
- Header: "Brewer"
- Question: "Which brewer is this recipe for?"
- Options: Switch, V60, Aeropress, Chemex (user can specify "Other")

### Step 2: Conversational Details

After brewer selection, ask in natural language (NOT multiple choice):

> "What's the recipe name, and where did it come from? (e.g., YouTube, personal creation, inspired by someone?)"

Let the user respond freely. Extract:
- Recipe name
- Source (Personal / YouTube / Blog / Friend / etc.)
- Inspiration credit if mentioned (e.g., "inspired by Tetsu Kasuya")

### Step 3: Recipe Parameters

Ask conversationally:

> "Walk me through the recipe - dose, ratio, grind setting, water temp(s), and the basic steps."

**Important:**
- Recipes may have multiple temperatures (bloom temp, pour temp, bypass temp)
- Don't assume single temp - capture all temps mentioned
- Grind setting is for Ode SSP MP unless user specifies different grinder
- Let the user describe steps naturally, then format them

### Step 4: Equipment & Accessories

Ask:

> "Any specific equipment or accessories? (filters, Lilidrip, WDT tool, etc.)"

### Step 5: Variants (optional)

**Question - Variants:**
- Header: "Variants"
- Question: "Add adjustments for light/medium/dark roasts?"
- Options: Yes, No

If yes, ask for adjustments conversationally.

## Recipe File Format

Save to: `20 Areas/Interests/Coffee/Recipes/[Brewer]/[Name].md`

```markdown
---
brewer: [brewer]
name: [recipe name]
source: [source]
inspired_by: [credit if any, omit if none]
created: [date]
---

# [Recipe Name]

[One-line description or inspiration credit if applicable]

## Base Recipe

| Parameter | Value |
|-----------|-------|
| Dose | Xg |
| Ratio | 1:XX |
| Water | Xg |
| Grind | X.X (Ode SSP MP) |
| Temp | XX°C (or multiple: XX°C / XX°C / XX°C) |
| Time | X:XX |

## Equipment

- [Brewer]
- [Filter type if specified]
- [Accessories if any]

## Steps

1. **0:00** — [Step with temp and valve state if applicable]
2. **X:XX** — [Next step]
...

## Variants

[Only include if user provided variants]

### Light Roast
- Grind: [adjustment]
- Temp: [adjustment]
- Notes: [why]

### Medium Roast
...

### Dark Roast
...

## Notes

[Any additional notes, tips, techniques, or observations]
```

## After Saving

Confirm with file path. Ask: "Add another recipe, or done for now?"
