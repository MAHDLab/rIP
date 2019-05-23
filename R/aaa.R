# @author Bob Rudis (bob@@rud.is)

httr::user_agent(
  sprintf(
    "rIP package v%s: (<%s>)",
    utils::packageVersion("rIP"),
    utils::packageDescription("rIP")$URL
  )
) -> .RIP_UA

c(
  "vpn", "asn", "node", "time", "inf",
  "risk", "port", "seen", "days", "tag"
) -> .valid_proxycheck_params