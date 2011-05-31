#include <png.h>
#include "debug.h"

extern "C"
{
#include "pseudo/pseudo_fileio.h"
}

#include "touchscreen.h"
#include "alloc.h"

namespace
{
	
void* mymalloc(png_structp png_ptr, png_alloc_size_t size)
{
	return malloc(size);
}

void myfree(png_structp png_ptr, void* ptr)
{
	free(ptr);
}

   /* The replacement fread wrapper which we will pass to png_set_read_fn(). */
   void Example_PNG_fread(png_structp png_ptr, png_bytep data, png_size_t length)
   {
       png_size_t  lenread;

       if ( ! (length > 0) )
           debug("Length < 0");

       /* The file 'handle', a pointer, is stored in png_ptr->io_ptr */
       if ( png_get_io_ptr(png_ptr) == NULL )
           debug("Null Image Handle");

       lenread = (png_size_t)pseudo_fread((void*)data, (size_t)length, 1, (PSEUDO_FILE *)png_get_io_ptr(png_ptr));
       if ( lenread < length )
           debug("Buffer Underrun");
   }

   /* Convert a PNG image to the example's format */
   int ExamplePNG2Raw(char *raw, const char *pPicToCheck, long numbytes)
   {
       PSEUDO_FILE *fp;
       png_bytep   *row_pointers;
	   int width, height;

       if ((fp = pseudo_fopen(pPicToCheck, numbytes)) == NULL)
           debug("Pseudo open failed");
		   
       png_structp png_ptr = png_create_read_struct_2(PNG_LIBPNG_VER_STRING, (png_voidp)NULL, NULL, NULL, NULL, mymalloc, myfree);
       if ( !png_ptr )
           debug("Got no png ptr");

       png_infop info_ptr = png_create_info_struct(png_ptr);
       if ( !info_ptr )
       {
           png_destroy_read_struct(&png_ptr, (png_infopp)NULL, (png_infopp)NULL);
           debug("Got no info struct");
       }
	   
	   /* read file */
        if (setjmp(png_jmpbuf(png_ptr)))
		{
                debug("[read_png_file] Error");
				while(1);
		}

       /* Pass file 'handle' and function address to png_set_read_fn() */
       png_set_read_fn(png_ptr, (void *)fp, Example_PNG_fread);
       png_read_png(png_ptr, info_ptr, PNG_TRANSFORM_SWAP_ALPHA, NULL);
	   width = png_get_image_width(png_ptr, info_ptr);
       height = png_get_image_height(png_ptr, info_ptr);
      // png_get_IHDR(png_ptr, info_ptr, &width, &height, . . .);
		row_pointers = png_get_rows(png_ptr, info_ptr);

      //
	  //
	  
	  debug("W: %d H: %d",width,height);
	  
	  for( int x = 0; x < width; ++x )
	  {
		for( int y = 0; y < height; ++y )
		{
			SCREEN[y][x] = ((uint32_t *)row_pointers[y])[x];
		}
	  }
	  //
	  //

       png_destroy_read_struct(&png_ptr, &info_ptr, 0);
       pseudo_fclose(fp);

       return 0; /* all OK */
   }
   
}

void pngdemo()
{
	  char rawbuf[1];
	  ExamplePNG2Raw(rawbuf, (const char*)&snowFlakeStart, &snowFlakeEnd-&snowFlakeStart);
}
