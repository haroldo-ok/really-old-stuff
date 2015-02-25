
.section "Resource pointer table" free
resource_pointer_table:
    
    ; MyText
    .db :rsc__MyText   ; Bank #
    .dw rsc__MyText    ; Offset

.ends


.section "Resource: MyText" superfree
    .dw rsc_end__MyText - rsc__MyText ; Resource size
rsc__MyText:
	.incbin "test.txt"
rsc_end__MyText:
.ends


