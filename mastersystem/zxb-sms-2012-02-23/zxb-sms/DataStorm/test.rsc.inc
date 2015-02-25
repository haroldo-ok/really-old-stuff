
.section "Resource pointer table" free
resource_pointer_table:
    
    ; ShipPal
    .db :rsc__ShipPal   ; Bank #
    .dw rsc__ShipPal    ; Offset

    ; ShipTil
    .db :rsc__ShipTil   ; Bank #
    .dw rsc__ShipTil    ; Offset

.ends


.section "Resource: ShipPal" superfree
    .dw rsc_end__ShipPal - rsc__ShipPal ; Resource size
rsc__ShipPal:
	.incbin "data\SHIP.PAL"
rsc_end__ShipPal:
.ends


.section "Resource: ShipTil" superfree
    .dw rsc_end__ShipTil - rsc__ShipTil ; Resource size
rsc__ShipTil:
	.incbin "data\SHIP.TIL"
rsc_end__ShipTil:
.ends


