# SMLIGHT SLZB-Ultima3 — scripts

Scripts I use with a [SMLIGHT SLZB-Ultima3](https://smlight.tech) as a
dual Zigbee gateway for Home Assistant: one radio runs ZHA, another
runs Zigbee2MQTT, each fully independent (own firmware, own channel).
Full write-up (Italian, with an English translation) is in this repo;
technical background on why I split the two networks and what else the
device can do is in `recensione-facebook.txt` / `recensione-facebook-en.txt`.

## What's here

Three scripts run **natively on the device**, in SLZB-OS's own Berry
scripting engine (uploaded from the device's web UI, Scripts → Files —
not part of Home Assistant at all):

- **`zigbee_watchdog.be`** — watches each Zigbee radio's connected
  client count; if ZHA or Zigbee2MQTT disconnects from its radio,
  sends a Telegram alert (no automatic restart, on purpose). Also
  alerts on Internet loss (Telegram + buzzer) and low free RAM.
- **`stato_giornaliero.be`** — a daily Telegram status report (uptime,
  free RAM, connected clients per radio), sent once at boot and then
  every 24 hours.
- **`buzzer_mqtt.be`** — listens on an MQTT topic and plays the
  matching RTTTL melody on the device's built-in buzzer, confirming via
  Telegram which sound was played.

One script is Home Assistant-side:

- **`gateway_zigbee_suono.yaml`** — a Home Assistant script that
  publishes the chosen sound name to MQTT. All the logic lives on the
  device (`buzzer_mqtt.be` above); this is just the "remote control".

Both native scripts that talk to Telegram require the TELEGRAM
integration configured first, on the device itself
(Scripts → Integrations → TELEGRAM, bot token + chat id).

## Notes if you reuse these

- `ZB.getZbClients()` needs a radio index as an argument (undocumented
  publicly at the time I wrote this) — index `0` doesn't exist, valid
  indices start at `1`. Verify yours before assuming radio 1 / radio 2
  map the way they do on my unit.
- The MQTT topic in `buzzer_mqtt.be` / `gateway_zigbee_suono.yaml`
  (`zhub/suono`) is specific to my broker ACL setup — adjust to
  whatever topic your own MQTT user can actually publish/subscribe to.
- SLZB-OS supports up to 3 concurrent scripts, which is exactly how
  many native ones are here.
