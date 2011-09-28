
#pragma once

#include "stdint.h"
#include "stddef.h"

struct UIButton
{
   int x;
   int y;
   int width;
   int height;
   void (* callback)(void);
};

struct UIGraphic
{
   uint8_t const * start;
   uint8_t const * end;
};

UIGraphic UI_NewGraphic(uint8_t const * start, uint8_t const * end);
UIButton * const UI_RegisterButton( UIButton button, UIGraphic pic );
void UI_RedrawButton( UIButton button, UIGraphic pic );
void UI_handleClick( int x, int y );

