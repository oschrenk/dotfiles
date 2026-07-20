# ticker — terminal stock/crypto watchlist (achannarasappa/ticker).
{ pkgs, ... }:
{
  home.packages = [ pkgs.ticker ];

  # ticker (viper) searches ~/, ./, $XDG_CONFIG_HOME and $XDG_CONFIG_HOME/ticker
  # for .ticker.yaml; we use the ticker/ subdir. Edit the watchlist to taste.
  xdg.configFile."ticker/.ticker.yaml".text = ''
    show-summary: true
    show-tags: true
    interval: 5
    watchlist:
      # coffee
      - KC=F      # Coffee (Arabica) front-month future — ICE Coffee C, US cents/lb
      - JO        # iPath Coffee ETN — coffee-price tracker (USD)
      # forex (all fixed 2 dp)
      - EURGTQ=X  # EUR/GTQ — quetzales per euro
      - GTQ=X     # USD/GTQ — quetzales per dollar
      - EUR=X     # USD/EUR — euros per dollar
      - EURUSD=X  # EUR/USD — dollars per euro
  '';

  # Notes on symbols / precision (see README.md), deployed alongside the config.
  xdg.configFile."ticker/README.md".source = ./ticker/README.md;
}
