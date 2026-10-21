# eMudhra CA compromise (2026-10-20); drop once nixpkgs has nss-cacert >= 3.131.1
_:

{
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
  ];
}
