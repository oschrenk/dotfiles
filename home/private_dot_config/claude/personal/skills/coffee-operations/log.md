# Log Brew

Save a brew to the coffee journal. Refer to SKILL.md for file paths.

## Location

`[Base]/Brews/YYYY-MM-DD.md` (see SKILL.md for base path)

- If the file already exists for today, append a new brew entry with a time stamp.

## Gathering Info

If invoked after brewing (recipe details already known), pre-fill from the session. Otherwise ask conversationally:

> "What did you brew? (bean, method, dose, grind, temp — whatever you remember)"

Then ask for tasting notes:

> "How was it? Any notes on aroma, flavor, acidity, sweetness, body?"

## Log Template

```markdown
# YYYY-MM-DD

- Beans: #beans/[origin-roaster]
- Recipe: #recipe/[method]
- Water Recipe: #water/[type]
- Grinder: Fellow Ode SSP MP
- Grind Size: [setting]
- Total Dissolved Solids:
- Temperature: [temp]
- Yield: [water amount]
- Concentration:
- Aroma: [notes]
- Flavour: [notes]
- Aftertaste: [notes]
- Acidity: [notes]
- Sweetness: [notes]
- Bitterness: [notes]
- Weight: [dose]
- Texture: [notes]
- Afterfeel: [notes]
- Balance: [notes]
```

Leave fields blank if the user doesn't provide them — don't prompt for every single field. Fill in what's naturally mentioned.
