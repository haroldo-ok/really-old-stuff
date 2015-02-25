
#define _PKG_SWITCH       1
#define _PKG_REQ_PROG     2
#define _PKG_SEND_PROG    3
#define _PKG_REQ_KEYCONF  4
#define _PKG_SEND_KEYCONF 5
#define _PKG_REQ_LIST     6
#define _PKG_SEND_LIST    7
#define _PKG_END          8
#define _PKG_CLOSECON	  9

void negotiate_connect();
UBYTE send_package(UBYTE kind, UBYTE len, UWORD ofs, unsigned char *data);
UBYTE receive_package(UBYTE *kind, UBYTE *len, UWORD *ofs, unsigned char *data);
void check_io_requests();
