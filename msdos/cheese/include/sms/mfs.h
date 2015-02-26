#ifndef _MFS_H_
#define _MFS_H_

#define PAGE0_BANK (*page0_bank)
#define PAGE1_BANK (*page1_bank)
#define PAGE2_BANK (*page2_bank)

#define INITIAL_BANK 2
#define BANK_MASK 0x3FFF
#define BANK_SHIFT 14

extern UBYTE *page0_bank;
extern UBYTE *page1_bank;
extern UBYTE *page2_bank;

extern UBYTE *page0_addr;
extern UBYTE *page1_addr;
extern UBYTE *page2_addr;

typedef struct _mfs_header {
	char signature[4];
	UWORD len;
	UWORD filler;
} mfs_header;

typedef struct _mfs_dir_entry {
	char filename[12];
	UWORD offs_l;
	UWORD offs_h;
	UWORD len;
} mfs_dir_entry;

typedef struct _mfs_pointer {
	UBYTE bank;
	UWORD offs;
	UWORD size;
} mfs_pointer;

extern void mfs_str_to_fname(char *fname, char *str);
extern mfs_dir_entry* mfs_find_dir_entry(char *fname);
extern UBYTE *mfs_fetch(mfs_pointer *ref);
extern UBYTE *mfs_fetch_file(char *fname);

#endif /*_MFS_H_*/
