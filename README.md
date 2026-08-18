# SMLIGHT SLZB-Ultima3 — script

Script che uso con una [SMLIGHT SLZB-Ultima3](https://smlight.tech) come
doppio gateway Zigbee per Home Assistant: una radio gestisce ZHA, l'altra
Zigbee2MQTT, ciascuna completamente indipendente (firmware proprio,
canale proprio).

## Cosa c'è

Tre script girano **nativamente sul dispositivo**, nel motore di
scripting Berry di SLZB-OS (caricati dall'interfaccia web del
dispositivo, Scripts → Files — non fanno parte di Home Assistant):

- **`zigbee_watchdog.be`** — controlla il numero di client collegati su
  ciascuna radio Zigbee; se ZHA o Zigbee2MQTT si disconnette dalla
  propria radio, invia un avviso Telegram (nessun riavvio automatico,
  di proposito). Avvisa anche se Internet cade (Telegram + buzzer) o se
  la RAM libera scende sotto soglia.
- **`stato_giornaliero.be`** — un report di stato via Telegram (uptime,
  RAM libera, client collegati su ciascuna radio), inviato subito
  all'avvio e poi ogni 24 ore.
- **`buzzer_mqtt.be`** — resta in ascolto su un topic MQTT e fa suonare
  il buzzer integrato con la melodia RTTTL corrispondente, confermando
  via Telegram quale suono è stato riprodotto.

Uno script è lato Home Assistant:

- **`gateway_zigbee_suono.yaml`** — uno script Home Assistant che
  pubblica su MQTT il nome del suono scelto. Tutta la logica vive sul
  dispositivo (`buzzer_mqtt.be` sopra); questo è solo il "telecomando".

I due script nativi che parlano con Telegram richiedono l'integrazione
TELEGRAM configurata prima, sul dispositivo stesso
(Scripts → Integrations → TELEGRAM, bot token + chat id).

## Note se li riusi

- `ZB.getZbClients()` vuole un indice di radio come argomento (non
  documentato pubblicamente al momento in cui l'ho scritto) — l'indice
  `0` non esiste, gli indici validi partono da `1`. Verifica i tuoi
  prima di dare per scontato che radio 1 / radio 2 corrispondano come
  sul mio dispositivo.
- Il topic MQTT in `buzzer_mqtt.be` / `gateway_zigbee_suono.yaml`
  (`zhub/suono`) è specifico della mia configurazione ACL sul broker —
  adattalo al topic che il tuo utente MQTT può davvero
  pubblicare/sottoscrivere.
- SLZB-OS supporta fino a 3 script contemporanei, esattamente quanti
  sono quelli nativi qui.
