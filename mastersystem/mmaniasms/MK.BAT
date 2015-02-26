utils\hmac header.s header.asm
if errorlevel 1 goto hell
ggasm\ggasm -o header.s
if errorlevel 1 goto hell
utils\hmac test.s test.asm
if errorlevel 1 goto hell
ggasm\ggasm -o test.s
if errorlevel 1 goto hell
utils\hmac routines.s routines.asm
if errorlevel 1 goto hell
ggasm\ggasm -o routines.s
if errorlevel 1 goto hell
ggasm\gglink -- -G -yo4 test.sms header.rel test.rel routines.rel  

