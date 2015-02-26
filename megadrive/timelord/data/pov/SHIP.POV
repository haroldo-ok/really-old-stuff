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

#declare Egg=union{
   intersection{
      sphere{
         <0,0,0>, 1
         scale <1,1.6,1> 
      }
      box{
         <-2, 3,-2>,
         < 2, 0, 2>
      }
   }
   sphere{
      <0,0,0>, 1
   }
}

#declare Ship_Shaper_1=union{
   intersection{
      object{
         Egg
         scale <1,1,1.6>
      }
      box{
         <-3, 3, 0>,
         < 3,-3, 3>
      }
   }
   object{
      Egg
      scale <1,1,0.5>
   }
}

#declare Ship_Base_Body_1=intersection{
   object{
      Egg
      scale <1,1,0.6>
      translate <0,0,-0.2>
   }
   object{
      Ship_Shaper_1
      scale <0.8,1,1>
      translate <0.2,0,0>
   }
   object{
      Ship_Shaper_1
      scale <0.8,1,1>
      translate <-0.2,0,0>
   }
   rotate x*15
}

#declare Ship_CockPit=union{
   object{
      Egg
      scale 0.96
      pigment{ Blue }
      finish{ Shiny }
   }
   difference{
      object{Egg}
      object{
         Egg
         scale 0.99
         translate <0,0.3,-0.6>
      }
   }
   scale <0.5,1,0.8>
}

#declare Reactor_Fire=texture{
   pigment{ 
      cylindrical
      color_map{
         [ 0.0 0.5 color <1.0,0.0,0.0> color <1.0,1.0,0.5> ]
         [ 0.5 1.0 color <1.0,1.0,0.5> color <1.0,1.0,1.0> ]
      }
   }
   finish{ ambient 1.0 }
}

#declare Ship_Left_Wing=union{
   difference{
      object{
         Egg
         scale <0.5,-1.7,0.5>
      }
      cylinder{
         <0,-3, 0>,
         <0, 3, 0>,
         0.3
      }
      scale 0.5
   }
   sphere{
      <0,0,0>, 0.16
      texture{ Reactor_Fire scale 0.16 }
      scale <1, 0.3, 1>
      translate <0,0.5,0>
   	  no_shadow
   }
   sphere{
      <0,0,0>, 0.16
      texture{ Reactor_Fire scale 0.16 }
      scale <1, 0.3, 1>
      translate <0,-0.9,0>
   	  no_shadow
   }
   cylinder{
      <0,-0.5, 0>,
      <1,-0.5, 0>,
      0.1
      pigment{ color <0.3,0.3,0.5> }
   }
   cylinder{
      <0,-0.2, 0>,
      <1,-0.0, 0>,
      0.1
      pigment{ color <0.3,0.3,0.5> }
   }
   translate <-1, 0, 0>
   rotate y*15
}

#declare Ship_Base_Body_2=difference{ 
   union{
      object{ Ship_Base_Body_1 }
/*      object{ Ship_Left_Wing }
      object{ Ship_Left_Wing scale <-1,1,1> }*/
   }
   sphere{ 
      <0,0,-0.4>, 0.6 
      scale <0.8,1,0.7>
      pigment{ color <0.3,0.3,0.5> }
   }
   sphere{ 
      <0,0,0>, 0.6
      scale <0.3,2,1>
      pigment{ Gray50 }
      translate <0,1.3,0>
   }
}

#declare Ship=union{
   object{ Ship_Base_Body_2 }
   object{ 
      Ship_CockPit 
      scale 0.5
      translate <0,-0.2,-0.3>
   }
   pigment{ White }
}

/*
object{
   Ship
   pigment{ White }
   scale 70
//   rotate <90,90,0>
//   rotate <90,180,0>
//   rotate <90,0,0>
//   rotate <120,-135,0>
}
*/

object{
   Ship
   pigment{ White }
   scale 108
   translate -20*y
   scale 1.00
//   rotate 90*z
//   rotate 45*z
   rotate 360*clock*z
}
