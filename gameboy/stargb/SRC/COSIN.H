#ifndef _COSIN_H
#define _COSIN_H

extern WORD cos_table[];

#define _COS(x) cos_table[x & 0x0F]
#define _SIN(x) cos_table[x+4 & 0x0F]

#endif /*_COSIN_H*/
