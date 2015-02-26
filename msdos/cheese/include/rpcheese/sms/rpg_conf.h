#ifndef _RPG_CONF_H_
#define _RPG_CONF_H_

#include <sms.h>
#include "rpg_defs.h"

typedef struct _rpg_display_data {
} rpg_display_data;

typedef struct _rpg_extra_data {
    rpg_display_data *display;
    void *map;
    rpg_envyro *env;
    char *data_ptr;
} rpg_extra_data;

#define ENVYRO_EXTRA(envyro) ((rpg_extra_data *)((envyro).extra))

#endif /*  _RPG_CONF_H_ */
