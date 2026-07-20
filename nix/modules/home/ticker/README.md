# ticker notes

Terminal watchlist ([achannarasappa/ticker](https://github.com/achannarasappa/ticker)).
Managed by nix — edit `nix/modules/home/ticker.nix`, not this deployed dir.

## Config file

`.ticker.yaml` (YAML). ticker (viper) searches, in order: `~/`, `./`,
`$XDG_CONFIG_HOME`, `$XDG_CONFIG_HOME/ticker`. We use the last →
`~/.config/ticker/.ticker.yaml`.

## Symbols (Yahoo Finance)

Suffix conventions: `=F` futures · `=X` forex · `-USD` crypto.

- **`KC=F`** — Coffee "C" (washed Arabica), the ICE benchmark, **front-month** future.
  - The label (e.g. "Coffee Sep 26") is the active contract: **month + year**
    (September 2026), *not* a day. Coffee delivers Mar/May/Jul/Sep/Dec; `=F`
    auto-rolls to the nearest one, so it changes over time on its own.
  - Price is in **US cents per pound** (304.7 = $3.047/lb).
- **`JO`** — iPath Coffee **ETN**: an investable coffee-price tracker in
  USD (Arabica-based; rolls contracts, so it drifts from `KC=F` over time).
- **Robusta coffee — not available.** Yahoo's symbol search returns nothing and every
  futures candidate 404s (`RC=F`, `RM=F`, `LRC=F`, `D=F`). Robusta trades on ICE Europe
  (London), which Yahoo barely covers, and ticker only sources Yahoo / Coinbase. Use
  `KC=F` (Arabica) as the coffee benchmark; Robusta tracks it closely anyway.
- **`EURGTQ=X`** — EUR/GTQ = **quetzales per euro** (read directly, no inversion).
  Yahoo has no `GTQEUR=X`: GTQ is a minor currency, only quoted as the counter side.

## Decimal precision — no config option, and forex is always 2 dp

Hardcoded across `internal/ui/util/format.go` and
`internal/monitor/yahoo/unary/helpers-quote.go`:

- Variable precision is enabled **only for cryptocurrency**:
  `isVariablePrecision := (assetClass == Cryptocurrency)`. For crypto, `<10` → 4
  decimals, `10–99` → 3, etc.
- **Everything else — stocks, futures, forex — is fixed at 2 decimals.**

So `EURGTQ=X` shows **`8.71`** (2 dp). There is no `precision`/`decimals` setting,
and forex never takes the crypto variable-precision path. (Verified in source, not
just inferred.)

Because you only get 2 decimals, the pair **direction** matters: `EURGTQ=X` (8.71)
keeps ~0.1% resolution, while the inverse GTQ→EUR (~0.11) at 2 dp collapses to ~9%
resolution — nearly useless. So read **quetzales-per-euro directly; don't invert.**
