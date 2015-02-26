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

#declare Blade=difference {
   cylinder {
      <0, 0,  1>, 
      <0, 0, -1>,
      30
   }
     
   cylinder {<0, 22, 2>, <0, 22, -2>, 15}   
   cylinder {<0, 22, 2>, <0, 22, -2>, 15 rotate z*120}   
   cylinder {<0, 22, 2>, <0, 22, -2>, 15 rotate z*240}   
}

union {
   object { 
      Blade 
      texture{T_Silver_5D}
   }
   
   sphere {
      <0, 0, 0>, 5
      texture{pigment{Blue} finish{Glossy}}
   }
   
   torus {
      18, 4
      texture{pigment{Red} finish{Glossy}}     
      rotate x*90
   }
   
   scale 4.2
   
   rotate z*clock*120
}