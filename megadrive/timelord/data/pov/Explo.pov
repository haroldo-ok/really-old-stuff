#include "metals.inc"
#include "glass.inc"
#include "textures.inc"
#include "colors.inc"
#include "finish.inc"

camera {
    direction <0, 0, 1.5>
//    location <0,  0, -180>
    location <0,  0, -400>
//    location <0,  0, -90>
    look_at <0, 0, 0>
}

light_source {<-60, 60, -200> color White}

sky_sphere {
   pigment {
//      Cyan
      Black
   }
}

union {
   sphere {
      <0, 0, 0>, 20 + 60*abs(sin(180*clock)) - 20*clock
      texture{ 
         pigment{ rgbt <0.5, 0.5, 0> + <1, 1, 1>*abs(sin(180*clock)) + <1, 0, 0, 1>*clock } 
         finish{ ambient abs(sin(180*clock)) }
      }
   }
   
   #if (clock > 0.3)      
      sphere {
         <0, 0, 0>, 120*clock
         texture{ 
            pigment{ rgbt <0.5, 0.5, 0> + <2, 0, 0, 2>*(clock-0.5) } 
            finish{ ambient 1.0-clock }
         }
         scale <1, 0.05, 0.05> + <0, 1, 1>*(1-clock)
      }
   #end
   
   rotate 360*clock
}