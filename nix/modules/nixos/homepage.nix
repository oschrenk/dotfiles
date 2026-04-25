{ config, pkgs, ... }:
let
  cfg  = config.services.homelab-proxy;
  html = ''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>${cfg.domain}</title>
      <style>
        body { font-family: system-ui, sans-serif; max-width: 400px; margin: 4rem auto; padding: 0 1rem; }
        ul { list-style: none; padding: 0; }
        li { margin: 0.75rem 0; }
        a { color: #0070f3; font-size: 1.1rem; text-decoration: none; }
        a:hover { text-decoration: underline; }
      </style>
    </head>
    <body>
      <h1>${cfg.domain}</h1>
      <ul>
        <li><a href="http://beszel.${cfg.domain}">Beszel</a></li>
        <li><a href="http://gatus.${cfg.domain}">Gatus</a></li>
        <li><a href="http://adguard.${cfg.domain}">AdGuard Home</a></li>
      </ul>
    </body>
    </html>
  '';
in
{
  services.nginx = {
    enable = true;
    virtualHosts."homelab-homepage" = {
      listen = [{ addr = "127.0.0.1"; port = cfg.homepagePort; ssl = false; }];
      root = pkgs.writeTextDir "index.html" html;
      locations."/".index = "index.html";
    };
  };
}
