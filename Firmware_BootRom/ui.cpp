
#include "ui.h"
#include "touchscreen.h"
#include "image.h"

namespace
{
   UIButton buttons [32];
   unsigned nextbutton = 0;

   void UI_Clear(UIButton & button)
   {
      for(size_t y = 0; y < button.height; ++y)
      {
         for(size_t x = 0; x < button.width; ++x)
         {
            setPixel( x+button.x, y+button.y, 0x0000CC00 );
         }
      }
   }

   void UI_Draw()
   {
   }
}

UIGraphic UI_NewGraphic(uint8_t const * start, uint8_t const * end)
{
   UIGraphic grphc = {start,end};
   return grphc;
}

UIButton * const UI_RegisterButton( UIButton button, UIGraphic pic )
{
   buttons[nextbutton] = button;

   printImage( button.x + button.width/2, button.y - button.height/2, pic.start, pic.end );

   return &buttons[nextbutton++];
}

void UI_RedrawButton( UIButton button, UIGraphic pic )
{
   UI_Clear( button );
}

void UI_handleClick( int x, int y )
{
   for( int i = 0; i < nextbutton; ++i )
   {
      if( x >= buttons[i].x && x < buttons[i].x + buttons[i].width &&
         y <= buttons[i].y && y > buttons[i].y - buttons[i].height )
      {
         buttons[i].callback();

         break;
      }
   }
}

