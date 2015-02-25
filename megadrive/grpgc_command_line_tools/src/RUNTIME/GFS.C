/* Sega Genesis File System routines                             */
/* by Haroldo O. Pinheiro                                        */
/*                                                               */
/* You may do wathever you want with these sources, as long as   */
/* you give proper credit.                                       */

#include "genesis.h"
#include "gfs.h"
#include "psgsound.h"
#include <string.h>

ulong gfs_filecount;
gfs_dir_entry *gfs_directory;

void str_to_fname(fname, str)
char *fname;
char *str;
{
	register uint i;

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

void init_GFS()
{
	gfs_filecount = *((ulong *)_GFS_START_OFFSET);
	gfs_directory = (gfs_dir_entry *)(_GFS_START_OFFSET+4UL);
}

gfs_dir_entry* find_GFS_dir_entry(fname)
char *fname;
{
	char filename[12];
	register uint max, min, i;
	register int tmp;
	char done;

	str_to_fname(filename, fname);

	min = 0;
	max = gfs_filecount;
	done = FALSE;
	while(!done){
		i = (max+min) >> 1;

		if(i == min){
			done = TRUE;
		}

		tmp = strncmp(gfs_directory[i].filename,filename,12);

		if(tmp < 0){
			min = i;
		}else if(tmp > 0){
			max = i;
		}else{
			done = TRUE;
		}
	}

	if(tmp == 0){
		return &gfs_directory[i];
	}else{
		return NULL;
	}
}

void get_GFS_fileaddr(faddr ,fname)
ulong *faddr;
char *fname;
{
	*faddr = find_GFS_dir_entry(fname)->offs+_GFS_START_OFFSET;
}

void get_GFS_filesize(fsize ,fname)
ulong *fsize;
char *fname;
{
	*fsize = find_GFS_dir_entry(fname)->len;
}

void get_GFS_file(faddr, fsize ,fname)
ulong *faddr;
ulong *fsize;
char *fname;
{
	gfs_dir_entry *entry;

	entry = find_GFS_dir_entry(fname);
	if (entry != NULL) {
		*faddr = entry->offs+_GFS_START_OFFSET;
		*fsize = entry->len;
	} else {
		*faddr = 0;
		*fsize = 0;
	}

/*
	if (*faddr == 0) {
		cputs("warning: resource \"");
		cputs(fname);
		cputs("\"not found.\n");
		wait_pressnrelease();
	}
*/
}
