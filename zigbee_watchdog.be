#META {"start":1}
# Watchdog di rete e radio Zigbee per SLZB-Ultima3.
#
# ZB.getZbClients() vuole un indice di radio (scoperto sul dispositivo
# reale, non era documentato pubblicamente): 0 non esiste ("Selected
# radio module does not exist!"), gli indici validi partono da 1. Sul
# mio gateway la radio 1 e la radio 2 hanno un client Zigbee collegato
# (ZHA e Zigbee2MQTT), la radio 3 e' inutilizzata (0 client). Se riusi
# questo script su un setup diverso, verifica prima i tuoi indici con
# SLZB.log("radio " .. str(i) .. ": " .. str(ZB.getZbClients(i))) per
# i da 1 a 3.
#
# - Se la radio 1 o la radio 2 perde il client Zigbee collegato al
#   socket, avvisa via Telegram. Non riavvia nulla in automatico: la
#   decisione resta a te.
# - Se l'host di controllo Internet non risponde per ~1 minuto, avvisa
#   via Telegram + buzzer.
# - Se la RAM libera scende sotto soglia, avvisa via Telegram (al
#   massimo ogni 30 minuti).
#
# Richiede l'integrazione TELEGRAM già configurata da
# Scripts -> Integrations (bot token + chat id).

import ZB
import PING
import TELEGRAM
import BUZZER

var CHECK_MS = 15000
var PING_HOST = "1.1.1.1"
var PING_FAIL_THRESHOLD = 4
var HEAP_MIN_BYTES = 20000
var HEAP_WARN_COOLDOWN_MS = 30 * 60 * 1000

var lastClients1 = 0
var lastClients2 = 0
var pingFailStreak = 0
var pingWasDown = false
var lastHeapWarnAt = 0

while true

  # --- radio 1 (ZHA sul mio gateway): client disconnesso dal socket ---
  var cur1 = ZB.getZbClients(1)
  if cur1 == 0 && lastClients1 > 0
    SLZB.log("Zigbee radio 1: client disconnesso")
    TELEGRAM.send("[Gateway Zigbee] La radio 1 ha perso il client Zigbee. Non riavviata automaticamente: controlla tu se serve.")
  end
  lastClients1 = cur1

  # --- radio 2 (Zigbee2MQTT sul mio gateway): client disconnesso dal socket ---
  var cur2 = ZB.getZbClients(2)
  if cur2 == 0 && lastClients2 > 0
    SLZB.log("Zigbee radio 2: client disconnesso")
    TELEGRAM.send("[Gateway Zigbee] La radio 2 ha perso il client Zigbee. Non riavviata automaticamente: controlla tu se serve.")
  end
  lastClients2 = cur2

  # --- connettivita' Internet ---
  var ok = PING.alive(PING_HOST)
  if !ok
    pingFailStreak = pingFailStreak + 1
    if pingFailStreak == PING_FAIL_THRESHOLD && !pingWasDown
      pingWasDown = true
      SLZB.log("Internet: irraggiungibile")
      TELEGRAM.send("[Gateway Zigbee] Internet irraggiungibile da circa 1 minuto.")
      BUZZER.play("Allerta:d=8,o=5,b=160:c6,p,c6,p,c6,p")
    end
  else
    pingFailStreak = 0
    if pingWasDown
      pingWasDown = false
      SLZB.log("Internet: di nuovo raggiungibile")
      TELEGRAM.send("[Gateway Zigbee] Internet di nuovo raggiungibile.")
    end
  end

  # --- memoria libera ---
  var heap = SLZB.freeHeap()
  var now = SLZB.millis()
  if heap < HEAP_MIN_BYTES && (now - lastHeapWarnAt) > HEAP_WARN_COOLDOWN_MS
    lastHeapWarnAt = now
    SLZB.log("RAM libera bassa: " .. str(heap) .. " byte")
    TELEGRAM.send("[Gateway Zigbee] RAM libera bassa: " .. str(heap) .. " byte.")
  end

  SLZB.delay(CHECK_MS)
end
