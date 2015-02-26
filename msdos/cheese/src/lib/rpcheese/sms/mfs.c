#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sms.h>
#include "mfs.h"

UBYTE *page0_bank = 0xFFFD;
UBYTE *page1_bank = 0xFFFE;
UBYTE *page2_bank = 0xFFFF;

UBYTE *page0_addr = 0x0000;
UBYTE *page1_addr = 0x4000;
UBYTE *page2_addr = 0x8000;

void mfs_str_to_fname(char *fname, char *str)
{
	UBYTE i;

	for(i = 0; (i != 8) && (*str != '.'); i++, fname++, str++){
		*fname = *str;
	}

	for( ; i != 8; i++, fname++){
		*fname = ' ';
	}

	for( ; i != 12; i++, fname++, str++){
		*fname = *str;
	}

	for( ; i != 12; i++, fname++){
		*fname = ' ';
	}
}

mfs_dir_entry* mfs_find_dir_entry(char *fname) {
	char filename[12];
	UWORD max, min, i;
	WORD tmp;
	UBYTE done;
	mfs_header *head = page2_addr;
	mfs_dir_entry *directory = (page2_addr + sizeof(mfs_header));

	mfs_str_to_fname(filename, fname);

	PAGE2_BANK = 2;

	min = 0;
	max = head->len;
	done = FALSE;
	while(!done){
		i = (max+min) >> 1;

		if(i == min){
			done = TRUE;
		}

		tmp = strncmp(directory[i].filename,filename,12);

		if(tmp < 0){
			min = i;
		}else if(tmp > 0){
			max = i;
		}else{
			done = TRUE;
		}
	}

	if(tmp == 0){
		return directory + i;
	}else{
		return NULL;
	}
}

void mfs_decode_entry(mfs_pointer *dest, mfs_dir_entry *source) {
	dest->bank = ((source->offs_l >> BANK_SHIFT) | (source->offs_h << (16-BANK_SHIFT))) + INITIAL_BANK;
	dest->offs = source->offs_l & BANK_MASK;
	dest->size = source->len;
}

UBYTE *mfs_fetch(mfs_pointer *ref) {
	PAGE2_BANK = ref->bank;
	return page2_addr + ref->offs;
}

UBYTE *mfs_fetch_file(char *fname) {
	mfs_dir_entry *entry;
	mfs_pointer dest;

	entry = mfs_find_dir_entry(fname);
	mfs_decode_entry(&dest, entry);

	return mfs_fetch(&dest);
}
