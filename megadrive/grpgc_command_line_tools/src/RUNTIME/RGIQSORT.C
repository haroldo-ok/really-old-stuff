/* +++Date last modified: 22-Oct-2004 */

/*
** quicksort.c -- quicksort integer array
**
** public domain by Raymond Gardner     12/91
*/

/*#include "snipsort.h"*/

/* Haroldo/2004: Hacked the source for use in Genesis RPG Creator */
#include "genesis.h"
#include "zopint.h"
#include "rpgwalk.h"
#include "actor.h"
#include "rgiqsort.h"

static void swap(a, b)
int *a;
int *b;
{
      register int t;

      t = *a;
      *a = *b;
      *b = t;
}

static void swapc(a, b)
char *a;
char *b;
{
      register int t;

      t = *a;
      *a = *b;
      *b = t;
}

void quicksort(v, n)
int v[];
unsigned n;
{
      unsigned i, j, ln, rn;

      while (n > 1)
      {
            swap(&v[0], &v[n/2]);
            for (i = 0, j = n; ; )
            {
                  do
                        --j;
                  while (v[j] > v[0]);
                  do
                        ++i;
                  while (i < j && v[i] < v[0]);
                  if (i >= j)
                        break;
                  swap(&v[i], &v[j]);
            }
            swap(&v[j], &v[0]);
            ln = j;
            rn = n - ++j;
            if (ln < rn)
            {
                  quicksort(v, ln);
                  v += j;
                  n = rn;
            }
            else
            {
                  quicksort(v + j, rn);
                  n = ln;
            }
      }
}

void quicksort_zorder(v, z, n)
register unsigned char v[];
register int z[];
register unsigned n;
{
      register unsigned i, j, ln, rn;

      while (n > 1)
      {
            swapc(&v[0], &v[n >> 1]);
            swap(&z[0], &z[n >> 1]);
            for (i = 0, j = n; ; )
            {
                  do
                     --j;
                  while (z[j] > z[0]);

                  do             
					 ++i;
                  while (i < j && z[i] < z[0]);

                  if (i >= j)
                        break;
                  swapc(&v[i], &v[j]);
                  swap(&z[i], &z[j]);
            }
            swapc(&v[j], &v[0]);
            swap(&z[j], &z[0]);
            ln = j;
            rn = n - ++j;
            if (ln < rn)
            {
                  quicksort_zorder(v, z, ln);
                  v += j;
                  z += j;
                  n = rn;
            }
            else
            {
                  quicksort_zorder(v + j, z + j, rn);
                  n = ln;
            }
      }
}
