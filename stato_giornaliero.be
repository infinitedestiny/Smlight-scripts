#META {"start":1}
# Report di stato giornaliero della SLZB-Ultima3 via Telegram.
# Invia un primo messaggio subito all'avvio (utile per verificare che
# funzioni appena caricato), poi uno ogni 24 ore.
#
# ZB.getZbClients() vuole un indice di radio (1, 2 o 3 sul mio
# dispositivo, 0 non esiste): vedi la nota in zigbee_watchdog.be per
# come l'ho scoperto. Qui riporto radio 1 e radio 2 (ZHA e Zigbee2MQTT
# sul mio gateway).
#
# Richiede l'integrazione TELEGRAM già configurata da
# Scripts -> Integrations (bot token + chat id).

import TELEGRAM
import ZB

var DAY_MS = 24 * 60 * 60 * 1000

while true
  var uptimeH = SLZB.millis() / 3600000
  var heap = SLZB.freeHeap()
  var clients1 = ZB.getZbClients(1)
  var clients2 = ZB.getZbClients(2)
  var msg = "[Gateway Zigbee] Stato giornaliero - " .. SLZB.deviceModel() ..
    " - uptime " .. str(uptimeH) .. "h - RAM libera " .. str(heap) ..
    " byte - client radio 1: " .. str(clients1) ..
    " - client radio 2: " .. str(clients2)
  SLZB.log(msg)
  TELEGRAM.send(msg)
  SLZB.delay(DAY_MS)
end
