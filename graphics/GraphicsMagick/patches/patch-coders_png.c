$NetBSD: patch-coders_png.c,v 1.1 2011/02/15 12:25:07 dillo Exp $

png.c taken from 1.4.020110207 for compatibility with png 1.5.

--- coders/png.c.orig	2010-03-03 20:26:23.000000000 +0000
+++ coders/png.c
@@ -88,26 +88,7 @@
 #include "zlib.h"
 
 
-/*
- * TO DO: rewrite using png_get_tRNS() instead of direct access to the
- * ping and ping_info structs.
- */
-#if PNG_LIBPNG_VER < 10400
-#    define trans_color  trans_values   /* Changed at libpng-1.4.0beta35 */
-#    define trans_alpha  trans          /* Changed at libpng-1.4.0beta74 */
-#else
-   /* We could parse PNG_LIBPNG_VER_STRING here but it's too much bother..
-    * Just don't use libpng-1.4.0beta32-34 or beta67-73
-    */
-#  ifndef  PNG_USER_CHUNK_CACHE_MAX     /* Added at libpng-1.4.0beta32 */
-#    define trans_color  trans_values   /* Changed at libpng-1.4.0beta35 */
-#  endif
-#  ifndef  PNG_TRANSFORM_GRAY_TO_RGB    /* Added at libpng-1.4.0beta67 */
-#    define trans_alpha  trans          /* Changed at libpng-1.4.0beta74 */
-#  endif
-#endif
-
-#if PNG_LIBPNG_VER > 95
+#if PNG_LIBPNG_VER > 10011
 /*
   Optional declarations. Define or undefine them as you like.
 */
@@ -164,10 +145,6 @@ static SemaphoreInfo
   PNG_MNG_FEATURES_SUPPORTED is disabled by default in libpng-1.0.9 and
   will be enabled by default in libpng-1.2.0.
 */
-#if (PNG_LIBPNG_VER == 10009)  /* work around libpng-1.0.9 bug */
-#  undef PNG_READ_EMPTY_PLTE_SUPPORTED
-#  undef PNG_WRITE_EMPTY_PLTE_SUPPORTED
-#endif
 #ifdef PNG_MNG_FEATURES_SUPPORTED
 #  ifndef PNG_READ_EMPTY_PLTE_SUPPORTED
 #    define PNG_READ_EMPTY_PLTE_SUPPORTED
@@ -244,6 +221,16 @@ static png_byte FARDATA mng_tIME[5]={116
 static png_byte FARDATA mng_zTXt[5]={122,  84,  88, 116, '\0'};
 */
 
+typedef struct _UShortPixelPacket
+{
+  unsigned short
+    red,
+    green,
+    blue,
+    opacity,
+    index;
+} UShortPixelPacket;
+
 typedef struct _MngBox
 {
   long
@@ -492,7 +479,6 @@ static const char* PngColorTypeToString(
   return result;
 }
 
-#if PNG_LIBPNG_VER > 95
 #if defined(PNG_SORT_PALETTE)
 /*
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@@ -785,7 +771,6 @@ static MagickPassFail CompressColormapTr
   return(MagickPass);
 }
 #endif
-#endif /* PNG_LIBPNG_VER > 95 */
 #endif /* HasPNG */
 
 /*
@@ -907,7 +892,7 @@ static MagickPassFail IsPNG(const unsign
 extern "C" {
 #endif
 
-#if (PNG_LIBPNG_VER > 95)
+#if (PNG_LIBPNG_VER > 10011)
 static size_t WriteBlobMSBULong(Image *image,const unsigned long value)
 {
   unsigned char
@@ -956,13 +941,13 @@ static void LogPNGChunk(int logging, png
         "  Writing %c%c%c%c chunk, length: %lu",
         type[0],type[1],type[2],type[3],length);
 }
-#endif /* PNG_LIBPNG_VER > 95 */
+#endif /* PNG_LIBPNG_VER > 10011 */
 
 #if defined(__cplusplus) || defined(c_plusplus)
 }
 #endif
 
-#if PNG_LIBPNG_VER > 95
+#if PNG_LIBPNG_VER > 10011
 /*
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
@@ -1351,7 +1336,11 @@ static void PNGErrorHandler(png_struct *
                         "  libpng-%.1024s error: %.1024s",
                         PNG_LIBPNG_VER_STRING, message);
   (void) ThrowException2(&image->exception,CoderError,message,image->filename);
+#if (PNG_LIBPNG_VER < 10500)
   longjmp(ping->jmpbuf,1);
+#else
+  png_longjmp(ping,1);
+#endif
 }
 
 static void PNGWarningHandler(png_struct *ping,png_const_charp message)
@@ -1372,19 +1361,8 @@ static void PNGWarningHandler(png_struct
 #ifdef PNG_USER_MEM_SUPPORTED
 static png_voidp png_IM_malloc(png_structp png_ptr,png_uint_32 size)
 {
-#if (PNG_LIBPNG_VER < 10011)
-  png_voidp
-    ret;
-  
-  png_ptr=png_ptr;
-  ret=MagickAllocateMemory(png_voidp,(size_t) size);
-  if (ret == NULL)
-    png_error("Insufficient memory.");
-  return (ret);
-#else
   png_ptr=png_ptr;
   return MagickAllocateMemory(png_voidp,(size_t) size);
-#endif
 }
 
 /*
@@ -1560,11 +1538,24 @@ static Image *ReadOnePNGImage(MngInfo *m
     logging,
     num_text,
     num_passes,
-    pass;
+    pass,
+    ping_bit_depth,
+    ping_colortype,
+    ping_interlace_method,
+    ping_compression_method,
+    ping_filter_method,
+    ping_num_trans;
 
-  PixelPacket
+  UShortPixelPacket
     transparent_color;
 
+  png_bytep
+     ping_trans_alpha;
+
+  png_color_16p
+     ping_background,
+     ping_trans_color;
+
   png_info
     *end_info,
     *ping_info;
@@ -1572,6 +1563,11 @@ static Image *ReadOnePNGImage(MngInfo *m
   png_struct
     *ping;
 
+  png_uint_32
+    ping_rowbytes,
+    ping_width,
+    ping_height;
+
   png_textp
     text;
 
@@ -1619,23 +1615,12 @@ static Image *ReadOnePNGImage(MngInfo *m
   LockSemaphoreInfo(png_semaphore);
 #endif
 
-#if (PNG_LIBPNG_VER < 10007)
+#if (PNG_LIBPNG_VER < 10012)
   if (image_info->verbose)
     printf("Your PNG library (libpng-%s) is rather old.\n",
            PNG_LIBPNG_VER_STRING);
 #endif
 
-#if (PNG_LIBPNG_VER >= 10400)
-#  ifndef  PNG_TRANSFORM_GRAY_TO_RGB    /* Added at libpng-1.4.0beta67 */
-  if (image_info->verbose)
-    {
-      printf("Your PNG library (libpng-%s) is an old beta version.\n",
-           PNG_LIBPNG_VER_STRING);
-      printf("Please update it.\n");
-    }
-#  endif
-#endif
-
   image=mng_info->image;
 
   /*
@@ -1665,7 +1650,7 @@ static Image *ReadOnePNGImage(MngInfo *m
       ThrowReaderException(ResourceLimitError,MemoryAllocationFailed,image);
     }
   png_pixels=(unsigned char *) NULL;
-  if (setjmp(ping->jmpbuf))
+  if (setjmp(png_jmpbuf(ping)))
     {
       /*
         PNG image is corrupt.
@@ -1740,18 +1725,32 @@ static Image *ReadOnePNGImage(MngInfo *m
 
   png_read_info(ping,ping_info);
 
+  (void) png_get_IHDR(ping,ping_info,
+                      &ping_width,
+                      &ping_height,
+                      &ping_bit_depth,
+                      &ping_colortype,
+                      &ping_interlace_method,
+                      &ping_compression_method,
+                      &ping_filter_method);
+
+  (void) png_get_tRNS(ping, ping_info, &ping_trans_alpha, &ping_num_trans,
+                      &ping_trans_color);
+
+  (void) png_get_bKGD(ping, ping_info, &ping_background);
+
 #if (QuantumDepth == 8)
   image->depth=8;
 #else
-  if (ping_info->bit_depth > 8)
+  if (ping_bit_depth > 8)
     image->depth=16;
   else
     image->depth=8;
 #endif
 
-  if (ping_info->bit_depth < 8)
+  if (ping_bit_depth < 8)
     {
-      if ((ping_info->color_type == PNG_COLOR_TYPE_PALETTE))
+      if (ping_colortype == PNG_COLOR_TYPE_PALETTE)
         {
           png_set_packing(ping);
           image->depth=8;
@@ -1761,21 +1760,22 @@ static Image *ReadOnePNGImage(MngInfo *m
     {
       (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                             "    PNG width: %lu, height: %lu",
-                            (unsigned long)ping_info->width,
-                            (unsigned long)ping_info->height);
+                            (unsigned long)ping_width,
+                            (unsigned long)ping_height);
       (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                             "    PNG color_type: %d, bit_depth: %d",
-                            ping_info->color_type, ping_info->bit_depth);
+                            ping_colortype, ping_bit_depth);
       (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                             "    PNG compression_method: %d",
-                            ping_info->compression_type);
+                            ping_compression_method);
       (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                             "    PNG interlace_method: %d, filter_method: %d",
-                            ping_info->interlace_type,ping_info->filter_type);
+                            ping_interlace_method,
+                            ping_filter_method);
     }
 
-#if (PNG_LIBPNG_VER > 10008) && defined(PNG_READ_iCCP_SUPPORTED)
-  if (ping_info->valid & PNG_INFO_iCCP)
+#if defined(PNG_READ_iCCP_SUPPORTED)
+    if (png_get_valid(ping, ping_info, PNG_INFO_iCCP))
     {
       int
         compression;
@@ -1803,15 +1803,19 @@ static Image *ReadOnePNGImage(MngInfo *m
             }
         }
     }
-#endif /* #if (PNG_LIBPNG_VER > 10008) && defined(PNG_READ_iCCP_SUPPORTED) */
+#endif /* #if defined(PNG_READ_iCCP_SUPPORTED) */
 #if defined(PNG_READ_sRGB_SUPPORTED)
   {
     int
       intent;
 
-    if (mng_info->have_global_srgb)
-      image->rendering_intent=(RenderingIntent)
-        (mng_info->global_srgb_intent+1);
+    if (!png_get_sRGB(ping,ping_info,&intent))
+      {
+        if (mng_info->have_global_srgb)
+          {
+            png_set_sRGB(ping,ping_info,(mng_info->global_srgb_intent+1));
+          }
+      }
     if (png_get_sRGB(ping,ping_info,&intent))
       {
         image->rendering_intent=(RenderingIntent) (intent+1);
@@ -1827,8 +1831,11 @@ static Image *ReadOnePNGImage(MngInfo *m
     double
       file_gamma;
 
-    if (mng_info->have_global_gama)
-      image->gamma=mng_info->global_gamma;
+    if (!png_get_gAMA(ping,ping_info,&file_gamma))
+      {
+        if (mng_info->have_global_gama)
+          png_set_gAMA(ping,ping_info,mng_info->global_gamma);
+      }
     if (png_get_gAMA(ping,ping_info,&file_gamma))
       {
         image->gamma=(float) file_gamma;
@@ -1838,9 +1845,20 @@ static Image *ReadOnePNGImage(MngInfo *m
                                 file_gamma);
       }
   }
-  if (mng_info->have_global_chrm)
-    image->chromaticity=mng_info->global_chrm;
-  if (ping_info->valid & PNG_INFO_cHRM)
+  if (!png_get_valid(ping, ping_info, PNG_INFO_cHRM))
+    {
+      if (mng_info->have_global_chrm)
+        (void) png_set_cHRM(ping,ping_info,
+                     mng_info->global_chrm.white_point.x,
+                     mng_info->global_chrm.white_point.y,
+                     mng_info->global_chrm.red_primary.x,
+                     mng_info->global_chrm.red_primary.y,
+                     mng_info->global_chrm.green_primary.x,
+                     mng_info->global_chrm.green_primary.y,
+                     mng_info->global_chrm.blue_primary.x,
+                     mng_info->global_chrm.blue_primary.y);
+    }
+  if (png_get_valid(ping, ping_info, PNG_INFO_cHRM))
     {
       (void) png_get_cHRM(ping,ping_info,
                           &image->chromaticity.white_point.x,
@@ -1867,12 +1885,9 @@ static Image *ReadOnePNGImage(MngInfo *m
       image->chromaticity.white_point.x=0.3127f;
       image->chromaticity.white_point.y=0.3290f;
     }
-  if (mng_info->have_global_gama || image->rendering_intent)
-    ping_info->valid|=PNG_INFO_gAMA;
-  if (mng_info->have_global_chrm || image->rendering_intent)
-    ping_info->valid|=PNG_INFO_cHRM;
 #if defined(PNG_oFFs_SUPPORTED)
-  if (mng_info->mng_type == 0 && (ping_info->valid & PNG_INFO_oFFs))
+  if (mng_info->mng_type == 0 && (png_get_valid(ping, ping_info,
+                                                PNG_INFO_oFFs)))
     {
       image->page.x=png_get_x_offset_pixels(ping, ping_info);
       image->page.y=png_get_y_offset_pixels(ping, ping_info);
@@ -1885,7 +1900,17 @@ static Image *ReadOnePNGImage(MngInfo *m
     }
 #endif
 #if defined(PNG_pHYs_SUPPORTED)
-  if (ping_info->valid & PNG_INFO_pHYs)
+  if (!png_get_valid(ping, ping_info, PNG_INFO_pHYs))
+    {
+      if (mng_info->have_global_phys)
+        {
+          png_set_pHYs(ping,ping_info,
+                       mng_info->global_x_pixels_per_unit,
+                       mng_info->global_y_pixels_per_unit,
+                       mng_info->global_phys_unit_type);
+        }
+    }
+  if (png_get_valid(ping, ping_info, PNG_INFO_pHYs))
     {
       int
         unit_type;
@@ -1915,25 +1940,8 @@ static Image *ReadOnePNGImage(MngInfo *m
                               (unsigned long)y_resolution,
                               unit_type);
     }
-  else
-    {
-      if (mng_info->have_global_phys)
-        {
-          image->x_resolution=(float) mng_info->global_x_pixels_per_unit;
-          image->y_resolution=(float) mng_info->global_y_pixels_per_unit;
-          if (mng_info->global_phys_unit_type == PNG_RESOLUTION_METER)
-            {
-              image->units=PixelsPerCentimeterResolution;
-              image->x_resolution=(double)
-                mng_info->global_x_pixels_per_unit/100.0;
-              image->y_resolution=(double)
-                mng_info->global_y_pixels_per_unit/100.0;
-            }
-          ping_info->valid|=PNG_INFO_pHYs;
-        }
-    }
 #endif
-  if (ping_info->valid & PNG_INFO_PLTE)
+  if (png_get_valid(ping, ping_info, PNG_INFO_PLTE))
     {
       int
         number_colors;
@@ -1942,14 +1950,14 @@ static Image *ReadOnePNGImage(MngInfo *m
         palette;
 
       (void) png_get_PLTE(ping,ping_info,&palette,&number_colors);
-      if (number_colors == 0 && ping_info->color_type ==
+      if (number_colors == 0 && ping_colortype ==
           PNG_COLOR_TYPE_PALETTE)
         {
           if (mng_info->global_plte_length)
             {
               png_set_PLTE(ping,ping_info,mng_info->global_plte,
                            (int) mng_info->global_plte_length);
-              if (!(ping_info->valid & PNG_INFO_tRNS))
+              if (!(png_get_valid(ping, ping_info, PNG_INFO_tRNS)))
                 if (mng_info->global_trns_length)
                   {
                     if (mng_info->global_trns_length >
@@ -1966,7 +1974,7 @@ static Image *ReadOnePNGImage(MngInfo *m
 #ifndef PNG_READ_EMPTY_PLTE_SUPPORTED
                   mng_info->have_saved_bkgd_index ||
 #endif
-                  ping_info->valid & PNG_INFO_bKGD)
+                  png_get_valid(ping, ping_info, PNG_INFO_bKGD))
                 {
                   png_color_16
                     background;
@@ -1974,9 +1982,9 @@ static Image *ReadOnePNGImage(MngInfo *m
 #ifndef PNG_READ_EMPTY_PLTE_SUPPORTED
                   if (mng_info->have_saved_bkgd_index)
                     background.index=mng_info->saved_bkgd_index;
-                  else
 #endif
-                    background.index=ping_info->background.index;
+                  if (png_get_valid(ping, ping_info, PNG_INFO_bKGD))
+                    background.index=ping_background->index;
                   background.red=(png_uint_16)
                     mng_info->global_plte[background.index].red;
                   background.green=(png_uint_16)
@@ -1995,34 +2003,76 @@ static Image *ReadOnePNGImage(MngInfo *m
     }
 
 #if defined(PNG_READ_bKGD_SUPPORTED)
-  if (mng_info->have_global_bkgd && !(ping_info->valid & PNG_INFO_bKGD))
+  if (mng_info->have_global_bkgd && 
+              !(png_get_valid(ping,ping_info, PNG_INFO_bKGD)))
     image->background_color=mng_info->mng_global_bkgd;
-  if (ping_info->valid & PNG_INFO_bKGD)
+  if (png_get_valid(ping, ping_info, PNG_INFO_bKGD))
     {
       /*
         Set image background color.
       */
+
       if (logging)
         (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                               "    Reading PNG bKGD chunk.");
-      if (ping_info->bit_depth <= QuantumDepth)
+
+      if (ping_bit_depth == QuantumDepth)
         {
-          image->background_color.red=ping_info->background.red;
-          image->background_color.green=ping_info->background.green;
-          image->background_color.blue=ping_info->background.blue;
+          image->background_color.red  = ping_background->red;
+          image->background_color.green= ping_background->green;
+          image->background_color.blue = ping_background->blue;
         }
-      else
+      else /* Scale background components to 16-bit */
         {
+          unsigned int
+            bkgd_scale;
+
+          if (logging != MagickFalse)
+            (void) LogMagickEvent(CoderEvent,GetMagickModule(),
+              "    raw ping_background=(%d,%d,%d).",ping_background->red,
+              ping_background->green,ping_background->blue);
+
+          bkgd_scale = 1;
+          if (ping_bit_depth == 1)
+             bkgd_scale = 255;
+          else if (ping_bit_depth == 2)
+             bkgd_scale = 85;
+          else if (ping_bit_depth == 4)
+             bkgd_scale = 17;
+          if (ping_bit_depth <= 8)
+             bkgd_scale *= 257;
+
+          ping_background->red *= bkgd_scale;
+          ping_background->green *= bkgd_scale;
+          ping_background->blue *= bkgd_scale;
+
+          if (logging != MagickFalse)
+            {
+            (void) LogMagickEvent(CoderEvent,GetMagickModule(),
+              "    bkgd_scale=%d.",bkgd_scale);
+            (void) LogMagickEvent(CoderEvent,GetMagickModule(),
+              "    ping_background=(%d,%d,%d).",ping_background->red,
+              ping_background->green,ping_background->blue);
+            }
+
           image->background_color.red=
-            ScaleShortToQuantum(ping_info->background.red);
+            ScaleShortToQuantum(ping_background->red);
           image->background_color.green=
-            ScaleShortToQuantum(ping_info->background.green);
+            ScaleShortToQuantum(ping_background->green);
           image->background_color.blue=
-            ScaleShortToQuantum(ping_info->background.blue);
+            ScaleShortToQuantum(ping_background->blue);
+          image->background_color.opacity=OpaqueOpacity;
+
+          if (logging != MagickFalse)
+            (void) LogMagickEvent(CoderEvent,GetMagickModule(),
+              "    image->background_color=(%d,%d,%d).",
+              image->background_color.red,
+              image->background_color.green,image->background_color.blue);
         }
     }
 #endif
-  if (ping_info->valid & PNG_INFO_tRNS)
+
+  if (png_get_valid(ping, ping_info, PNG_INFO_tRNS))
     {
       int
         bit_mask;
@@ -2031,49 +2081,70 @@ static Image *ReadOnePNGImage(MngInfo *m
         (void) LogMagickEvent(CoderEvent,GetMagickModule(),
           "    Reading PNG tRNS chunk.");
 
-      bit_mask = (1 << ping_info->bit_depth) - 1;
+      bit_mask = (1 << ping_bit_depth) - 1;
 
       /*
         Image has a transparent background.
       */
+
       transparent_color.red=
-        (Quantum)(ping_info->trans_color.red & bit_mask);
+        (unsigned short)(ping_trans_color->red & bit_mask);
       transparent_color.green=
-        (Quantum) (ping_info->trans_color.green & bit_mask);
+        (unsigned short) (ping_trans_color->green & bit_mask);
       transparent_color.blue=
-        (Quantum) (ping_info->trans_color.blue & bit_mask);
+        (unsigned short) (ping_trans_color->blue & bit_mask);
       transparent_color.opacity=
-        (Quantum) (ping_info->trans_color.gray & bit_mask);
-      if (ping_info->color_type == PNG_COLOR_TYPE_GRAY)
+        (unsigned short) (ping_trans_color->gray & bit_mask);
+
+      if (ping_colortype == PNG_COLOR_TYPE_GRAY)
         {
+#if (Quantum_depth == 8)
+          if (ping_bit_depth < Quantum_depth)
+#endif
+            transparent_color.opacity=(unsigned short) (
+                ping_trans_color->gray *
+                (65535L/((1UL << ping_bit_depth)-1)));
+
+#if (Quantum_depth == 8)
+          else
+            transparent_color.opacity=(unsigned short) (
+                (ping_trans_color->gray * 65535L)/
+                ((1UL << ping_bit_depth)-1));
+#endif
+          if (logging != MagickFalse)
+            {
+              (void) LogMagickEvent(CoderEvent,GetMagickModule(),
+                   "    Raw tRNS graylevel is %d.",ping_trans_color->gray);
+              (void) LogMagickEvent(CoderEvent,GetMagickModule(),
+                   "    scaled graylevel is %d.",transparent_color.opacity);
+            }
           transparent_color.red=transparent_color.opacity;
           transparent_color.green=transparent_color.opacity;
           transparent_color.blue=transparent_color.opacity;
         }
     }
 #if defined(PNG_READ_sBIT_SUPPORTED)
-  if (mng_info->have_global_sbit)
-    {
-      int
-        not_valid;
-      not_valid=!ping_info->valid;
-      if (not_valid & PNG_INFO_sBIT)
+  if (!png_get_valid(ping, ping_info, PNG_INFO_sBIT))
+    if (mng_info->have_global_sbit)
         png_set_sBIT(ping,ping_info,&mng_info->global_sbit);
-    }
 #endif
   num_passes=png_set_interlace_handling(ping);
+
   png_read_update_info(ping,ping_info);
+
+  ping_rowbytes=png_get_rowbytes(ping,ping_info);
+
   /*
     Initialize image structure.
   */
   mng_info->image_box.left=0;
-  mng_info->image_box.right=(long) ping_info->width;
+  mng_info->image_box.right=(long) ping_width;
   mng_info->image_box.top=0;
-  mng_info->image_box.bottom=(long) ping_info->height;
+  mng_info->image_box.bottom=(long) ping_height;
   if (mng_info->mng_type == 0)
     {
-      mng_info->mng_width=ping_info->width;
-      mng_info->mng_height=ping_info->height;
+      mng_info->mng_width=ping_width;
+      mng_info->mng_height=ping_height;
       mng_info->frame=mng_info->image_box;
       mng_info->clip=mng_info->image_box;
     }
@@ -2082,14 +2153,14 @@ static Image *ReadOnePNGImage(MngInfo *m
       image->page.y=mng_info->y_off[mng_info->object_id];
     }
   image->compression=ZipCompression;
-  image->columns=ping_info->width;
-  image->rows=ping_info->height;
-  if ((ping_info->color_type == PNG_COLOR_TYPE_PALETTE) ||
-      (ping_info->color_type == PNG_COLOR_TYPE_GRAY_ALPHA) ||
-      (ping_info->color_type == PNG_COLOR_TYPE_GRAY))
+  image->columns=ping_width;
+  image->rows=ping_height;
+  if ((ping_colortype == PNG_COLOR_TYPE_PALETTE) ||
+      (ping_colortype == PNG_COLOR_TYPE_GRAY_ALPHA) ||
+      (ping_colortype == PNG_COLOR_TYPE_GRAY))
     {
       image->storage_class=PseudoClass;
-      image->colors=1 << ping_info->bit_depth;
+      image->colors=1 << ping_bit_depth;
 #if (QuantumDepth == 8)
       if (image->colors > 256)
         image->colors=256;
@@ -2097,7 +2168,7 @@ static Image *ReadOnePNGImage(MngInfo *m
       if (image->colors > 65536L)
         image->colors=65536L;
 #endif
-      if (ping_info->color_type == PNG_COLOR_TYPE_PALETTE)
+      if (ping_colortype == PNG_COLOR_TYPE_PALETTE)
         {
           int
             number_colors;
@@ -2121,7 +2192,7 @@ static Image *ReadOnePNGImage(MngInfo *m
       */
       if (!AllocateImageColormap(image,image->colors))
         ThrowReaderException(ResourceLimitError,MemoryAllocationFailed,image);
-      if (ping_info->color_type == PNG_COLOR_TYPE_PALETTE)
+      if (ping_colortype == PNG_COLOR_TYPE_PALETTE)
         {
           int
             number_colors;
@@ -2142,7 +2213,7 @@ static Image *ReadOnePNGImage(MngInfo *m
           unsigned long
             scale;
 
-          scale=(MaxRGB/((1 << ping_info->bit_depth)-1));
+          scale=(MaxRGB/((1 << ping_bit_depth)-1));
           if (scale < 1)
             scale=1;
           for (i=0; i < (long) image->colors; i++)
@@ -2182,10 +2253,9 @@ static Image *ReadOnePNGImage(MngInfo *m
                           "    Reading PNG IDAT chunk(s)");
   if (num_passes > 1)
     png_pixels=MagickAllocateMemory(unsigned char *,
-                                    ping_info->rowbytes*image->rows);
+                                    ping_rowbytes*image->rows);
   else
-    png_pixels=MagickAllocateMemory(unsigned char *,
-                                    ping_info->rowbytes);
+    png_pixels=MagickAllocateMemory(unsigned char *, ping_rowbytes);
   if (png_pixels == (unsigned char *) NULL)
     ThrowReaderException(ResourceLimitError,MemoryAllocationFailed,image);
 
@@ -2205,20 +2275,20 @@ static Image *ReadOnePNGImage(MngInfo *m
         int
           depth;
 
-        depth=(long) ping_info->bit_depth;
+        depth=(long) ping_bit_depth;
 #endif
-        image->matte=((ping_info->color_type == PNG_COLOR_TYPE_RGB_ALPHA) ||
-                      (ping_info->color_type == PNG_COLOR_TYPE_GRAY_ALPHA) ||
-                      (ping_info->valid & PNG_INFO_tRNS));
+        image->matte=((ping_colortype == PNG_COLOR_TYPE_RGB_ALPHA) ||
+                      (ping_colortype == PNG_COLOR_TYPE_GRAY_ALPHA) ||
+                      (png_get_valid(ping, ping_info, PNG_INFO_tRNS)));
 
         for (y=0; y < (long) image->rows; y++)
           {
             if (num_passes > 1)
-              row_offset=ping_info->rowbytes*y;
+              row_offset=ping_rowbytes*y;
             else
               row_offset=0;
             png_read_row(ping,png_pixels+row_offset,NULL);
-	    if (!SetImagePixels(image,0,y,image->columns,1))  /* Was GetImagePixels() */
+	    if (!SetImagePixels(image,0,y,image->columns,1))
               break;
 #if (QuantumDepth == 8)
             if (depth == 16)
@@ -2229,13 +2299,13 @@ static Image *ReadOnePNGImage(MngInfo *m
 
                 r=png_pixels+row_offset;
                 p=r;
-                if (ping_info->color_type == PNG_COLOR_TYPE_GRAY)
+                if (ping_colortype == PNG_COLOR_TYPE_GRAY)
                   {
                     for (x=(long) image->columns; x > 0; x--)
                       {
                         *r++=*p++;
                         p++;
-                        if ((ping_info->valid & PNG_INFO_tRNS) &&
+                        if ((png_get_valid(ping, ping_info, PNG_INFO_tRNS)) &&
                             (((*(p-2) << 8)|*(p-1))
                             == transparent_color.opacity))
                           {
@@ -2246,9 +2316,9 @@ static Image *ReadOnePNGImage(MngInfo *m
                           *r++=OpaqueOpacity;
                       }
                   }
-                else if (ping_info->color_type == PNG_COLOR_TYPE_RGB)
+                else if (ping_colortype == PNG_COLOR_TYPE_RGB)
                   {
-                    if (ping_info->valid & PNG_INFO_tRNS)
+                    if (png_get_valid(ping, ping_info, PNG_INFO_tRNS))
                       for (x=(long) image->columns; x > 0; x--)
                         {
                           *r++=*p++;
@@ -2282,25 +2352,25 @@ static Image *ReadOnePNGImage(MngInfo *m
                           *r++=OpaqueOpacity;
                         }
                   }
-                else if (ping_info->color_type == PNG_COLOR_TYPE_RGB_ALPHA)
+                else if (ping_colortype == PNG_COLOR_TYPE_RGB_ALPHA)
                   for (x=(long) (4*image->columns); x > 0; x--)
                     {
                       *r++=*p++;
                       p++;
                     }
-                else if (ping_info->color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
+                else if (ping_colortype == PNG_COLOR_TYPE_GRAY_ALPHA)
                   for (x=(long) (2*image->columns); x > 0; x--)
                     {
                       *r++=*p++;
                       p++;
                     }
               }
-            if (depth == 8 && ping_info->color_type == PNG_COLOR_TYPE_GRAY)
+            if (depth == 8 && ping_colortype == PNG_COLOR_TYPE_GRAY)
               (void) ImportImagePixelArea(image,(QuantumType) GrayQuantum,
                                           image->depth,png_pixels+
                                           row_offset,0,0);
-            if (ping_info->color_type == PNG_COLOR_TYPE_GRAY ||
-                ping_info->color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
+            if (ping_colortype == PNG_COLOR_TYPE_GRAY ||
+                ping_colortype == PNG_COLOR_TYPE_GRAY_ALPHA)
               {
                 image->depth=8;
                 (void) ImportImagePixelArea(image,
@@ -2309,12 +2379,12 @@ static Image *ReadOnePNGImage(MngInfo *m
                                             row_offset,0,0);
                 image->depth=depth;
               }
-            else if (depth == 8 && ping_info->color_type == PNG_COLOR_TYPE_RGB)
+            else if (depth == 8 && ping_colortype == PNG_COLOR_TYPE_RGB)
               (void) ImportImagePixelArea(image,(QuantumType) RGBQuantum,
                                           image->depth,png_pixels+
                                           row_offset,0,0);
-            else if (ping_info->color_type == PNG_COLOR_TYPE_RGB ||
-                     ping_info->color_type == PNG_COLOR_TYPE_RGB_ALPHA)
+            else if (ping_colortype == PNG_COLOR_TYPE_RGB ||
+                     ping_colortype == PNG_COLOR_TYPE_RGB_ALPHA)
               {
                 image->depth=8;
                 (void) ImportImagePixelArea(image,(QuantumType) RGBAQuantum,
@@ -2322,28 +2392,28 @@ static Image *ReadOnePNGImage(MngInfo *m
                                             row_offset,0,0);
                 image->depth=depth;
               }
-            else if (ping_info->color_type == PNG_COLOR_TYPE_PALETTE)
+            else if (ping_colortype == PNG_COLOR_TYPE_PALETTE)
               (void) ImportImagePixelArea(image,(QuantumType) IndexQuantum,
-                                          ping_info->bit_depth,png_pixels+
+                                          ping_bit_depth,png_pixels+
                                           row_offset,0,0);
                                           /* FIXME, sample size ??? */
 #else /* (QuantumDepth != 8) */
 
-            if (ping_info->color_type == PNG_COLOR_TYPE_GRAY)
+            if (ping_colortype == PNG_COLOR_TYPE_GRAY)
               (void) ImportImagePixelArea(image,(QuantumType) GrayQuantum,
                                           image->depth,png_pixels+
                                           row_offset,0,0);
-            else if (ping_info->color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
+            else if (ping_colortype == PNG_COLOR_TYPE_GRAY_ALPHA)
               (void) ImportImagePixelArea(image,(QuantumType) GrayAlphaQuantum,
                                           image->depth,png_pixels+
                                           row_offset,0,0);
-            else if (ping_info->color_type == PNG_COLOR_TYPE_RGB_ALPHA)
+            else if (ping_colortype == PNG_COLOR_TYPE_RGB_ALPHA)
               (void) ImportImagePixelArea(image,(QuantumType) RGBAQuantum,
                                           image->depth,png_pixels+
                                           row_offset,0,0);
-            else if (ping_info->color_type == PNG_COLOR_TYPE_PALETTE)
+            else if (ping_colortype == PNG_COLOR_TYPE_PALETTE)
               (void) ImportImagePixelArea(image,(QuantumType) IndexQuantum,
-                                          ping_info->bit_depth,png_pixels+
+                                          ping_bit_depth,png_pixels+
                                           row_offset,0,0);
                                           /* FIXME, sample size ??? */
             else
@@ -2372,7 +2442,7 @@ static Image *ReadOnePNGImage(MngInfo *m
         /*
           Convert grayscale image to PseudoClass pixel packets.
         */
-        image->matte=ping_info->color_type == PNG_COLOR_TYPE_GRAY_ALPHA;
+        image->matte=ping_colortype == PNG_COLOR_TYPE_GRAY_ALPHA;
         quantum_scanline=MagickAllocateMemory(Quantum *,
                                               (image->matte ?  2 : 1) *
                                               image->columns*sizeof(Quantum));
@@ -2385,7 +2455,7 @@ static Image *ReadOnePNGImage(MngInfo *m
               *p;
 
             if (num_passes > 1)
-              row_offset=ping_info->rowbytes*y;
+              row_offset=ping_rowbytes*y;
             else
               row_offset=0;
             png_read_row(ping,png_pixels+row_offset,NULL);
@@ -2395,7 +2465,7 @@ static Image *ReadOnePNGImage(MngInfo *m
             indexes=AccessMutableIndexes(image);
             p=png_pixels+row_offset;
             r=quantum_scanline;
-            switch (ping_info->bit_depth)
+            switch (ping_bit_depth)
               {
               case 1:
                 {
@@ -2445,7 +2515,7 @@ static Image *ReadOnePNGImage(MngInfo *m
                 }
               case 8:
                 {
-                  if (ping_info->color_type == 4)
+                  if (ping_colortype == 4)
                     for (x=(long) image->columns; x > 0; x--)
                       {
                         *r++=*p++;
@@ -2473,7 +2543,7 @@ static Image *ReadOnePNGImage(MngInfo *m
                         *r=0;
                       *r|=(*p++);
                       r++;
-                      if (ping_info->color_type == 4)
+                      if (ping_colortype == 4)
                         {
                           q->opacity=((*p++) << 8);
                           q->opacity|=(*p++);
@@ -2488,7 +2558,7 @@ static Image *ReadOnePNGImage(MngInfo *m
                         *r=0;
                       *r|=(*p++);
                       r++;
-                      if (ping_info->color_type == 4)
+                      if (ping_colortype == 4)
                         {
                           q->opacity=((*p++) << 8);
                           q->opacity|=(*p++);
@@ -2499,7 +2569,7 @@ static Image *ReadOnePNGImage(MngInfo *m
 #else /* QuantumDepth == 8 */
                       *r++=(*p++);
                       p++; /* strip low byte */
-                      if (ping_info->color_type == 4)
+                      if (ping_colortype == 4)
                         {
                           q->opacity=(Quantum) (MaxRGB-(*p++));
                           p++;
@@ -2549,7 +2619,7 @@ static Image *ReadOnePNGImage(MngInfo *m
                               "  exit ReadOnePNGImage().");
       return (image);
     }
-  if (ping_info->valid & PNG_INFO_tRNS)
+  if (png_get_valid(ping, ping_info, PNG_INFO_tRNS))
     {
       ClassType
         storage_class;
@@ -2572,25 +2642,26 @@ static Image *ReadOnePNGImage(MngInfo *m
               IndexPacket
                 index;
 
-              if (ping_info->color_type == PNG_COLOR_TYPE_PALETTE)
+              if (ping_colortype == PNG_COLOR_TYPE_PALETTE)
                 for (x=0; x < (long) image->columns; x++)
                   {
                     index=indexes[x];
-                    if (index < ping_info->num_trans)
+                    if (index < ping_num_trans)
                       q->opacity=
-                        ScaleCharToQuantum(255-ping_info->trans_alpha[index]);
+                        ScaleCharToQuantum(255-ping_trans_alpha[index]);
 		    else
 		      q->opacity=OpaqueOpacity;
                     q++;
                   }
-              else if (ping_info->color_type == PNG_COLOR_TYPE_GRAY)
+              else if (ping_colortype == PNG_COLOR_TYPE_GRAY)
                 for (x=0; x < (long) image->columns; x++)
                   {
                     index=indexes[x];
                     q->red=image->colormap[index].red;
                     q->green=image->colormap[index].green;
                     q->blue=image->colormap[index].blue;
-                    if (q->red == transparent_color.opacity)
+                    if (ScaleQuantumToShort(q->red) ==
+                        transparent_color.opacity)
                       q->opacity=TransparentOpacity;
 		    else
 		      q->opacity=OpaqueOpacity;
@@ -2600,9 +2671,9 @@ static Image *ReadOnePNGImage(MngInfo *m
           else
             for (x=(long) image->columns; x > 0; x--)
               {
-                if (q->red == transparent_color.red &&
-                    q->green == transparent_color.green &&
-                    q->blue == transparent_color.blue)
+                if (ScaleQuantumToShort(q->red) == transparent_color.red &&
+                    ScaleQuantumToShort(q->green) == transparent_color.green &&
+                    ScaleQuantumToShort(q->blue) == transparent_color.blue)
                   q->opacity=TransparentOpacity;
 		else
 		  q->opacity=OpaqueOpacity;
@@ -2714,7 +2785,7 @@ static Image *ReadOnePNGImage(MngInfo *m
           mng_info->ob[object_id]->interlace_method=interlace_method;
           mng_info->ob[object_id]->compression_method=compression_method;
           mng_info->ob[object_id]->filter_method=filter_method;
-          if (ping_info->valid & PNG_INFO_PLTE)
+          if (png_get_valid(ping, ping_info, PNG_INFO_PLTE))
             {
               int
                 number_colors;
@@ -5734,7 +5805,7 @@ static Image *ReadMNGImage(const ImageIn
     (void) LogMagickEvent(CoderEvent,GetMagickModule(),"exit ReadMNGImage()");
   return(image);
 }
-#else /* PNG_LIBPNG_VER > 95 */
+#else /* PNG_LIBPNG_VER > 10011 */
 static Image *ReadPNGImage(const ImageInfo *image_info,
                            ExceptionInfo *exception)
 {
@@ -5749,7 +5820,7 @@ static Image *ReadMNGImage(const ImageIn
 {
   return (ReadPNGImage(image_info,exception));
 }
-#endif /* PNG_LIBPNG_VER > 95 */
+#endif /* PNG_LIBPNG_VER > 10011 */
 #endif
 
 /*
@@ -5960,7 +6031,7 @@ ModuleExport void UnregisterPNGImage(voi
 }
 
 #if defined(HasPNG)
-#if PNG_LIBPNG_VER > 95
+#if PNG_LIBPNG_VER > 10011
 /*
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
@@ -6043,20 +6114,6 @@ ModuleExport void UnregisterPNGImage(voi
 */
 
 
-#if (PNG_LIBPNG_VER > 99 && PNG_LIBPNG_VER < 10007)
-/* This function became available in libpng version 1.0.6g. */
-static void
-png_set_compression_buffer_size(png_structp png_ptr, png_uint_32 size)
-{
-  if (png_ptr->zbuf)
-    png_free(png_ptr, png_ptr->zbuf); png_ptr->zbuf=NULL;
-  png_ptr->zbuf_size=(png_size_t) size;
-  png_ptr->zbuf=(png_bytep) png_malloc(png_ptr, size);
-  if (!png_ptr->zbuf)
-    png_error(png_ptr,"Unable to allocate zbuf");
-}
-#endif
-
 static void
 png_write_raw_profile(const ImageInfo *image_info,png_struct *ping,
                       png_info *ping_info, const char *profile_type,
@@ -6064,7 +6121,6 @@ png_write_raw_profile(const ImageInfo *i
                       const unsigned char *profile_data,
                       png_uint_32 length)
 {
-#if (PNG_LIBPNG_VER > 10005)
   png_textp
     text;
 
@@ -6083,25 +6139,12 @@ png_write_raw_profile(const ImageInfo *i
 
   unsigned char
     hex[16]={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
-#endif
 
-#if (PNG_LIBPNG_VER <= 10005)
-  if (image_info->verbose)
-    (void) printf("Not ");
-  (void) image_info;
-  (void) ping;
-  (void) ping_info;
-  (void) profile_type;
-  (void) profile_description;
-  (void) profile_data;
-  (void) length;
-#endif
   if (image_info->verbose)
     {
       (void) printf("writing raw profile: type=%.1024s, length=%lu\n",
                     profile_type, (unsigned long)length);
     }
-#if (PNG_LIBPNG_VER > 10005)
   text=(png_textp) png_malloc(ping,(png_uint_32) sizeof(png_text));
   description_length=strlen((const char *) profile_description);
   allocated_length=(png_uint_32) (length*2 + (length >> 5) + 20
@@ -6137,7 +6180,6 @@ png_write_raw_profile(const ImageInfo *i
   png_free(ping,text[0].text);
   png_free(ping,text[0].key);
   png_free(ping,text);
-#endif
 }
 
 static MagickPassFail WriteOnePNGImage(MngInfo *mng_info,
@@ -6152,17 +6194,34 @@ static MagickPassFail WriteOnePNGImage(M
 
   int
     num_passes,
-    pass;
+    pass,
+    ping_bit_depth = 0,
+    ping_colortype = 0,
+    ping_interlace_method = 0,
+    ping_compression_method = 0,
+    ping_filter_method = 0,
+    ping_num_trans = 0;
+
+  png_bytep
+     ping_trans_alpha = NULL;
 
   png_colorp
     palette;
 
+  png_color_16
+    ping_background,
+    ping_trans_color;
+
   png_info
     *ping_info;
 
   png_struct
     *ping;
 
+  png_uint_32
+    ping_width,
+    ping_height;
+
   long
     y;
 
@@ -6181,8 +6240,7 @@ static MagickPassFail WriteOnePNGImage(M
     image_depth,
     image_matte,
     logging,
-    matte,
-    not_valid;
+    matte;
 
   unsigned long
     quantum_size,  /* depth for ExportImage */
@@ -6211,6 +6269,18 @@ static MagickPassFail WriteOnePNGImage(M
       return MagickFail;
     }
 
+  /* Initialize some stuff */
+  ping_background.red = 0;
+  ping_background.green = 0;
+  ping_background.blue = 0;
+  ping_background.gray = 0;
+  ping_background.index = 0;
+
+  ping_trans_color.red=0;
+  ping_trans_color.green=0;
+  ping_trans_color.blue=0;
+  ping_trans_color.gray=0;
+
   image_colors=image->colors;
   image_depth=image->depth;
   image_matte=image->matte;
@@ -6259,7 +6329,7 @@ static MagickPassFail WriteOnePNGImage(M
   LockSemaphoreInfo(png_semaphore);
 #endif
 
-  if (setjmp(ping->jmpbuf))
+  if (setjmp(png_jmpbuf(ping)))
     {
       /*
         PNG write failed.
@@ -6288,16 +6358,16 @@ static MagickPassFail WriteOnePNGImage(M
 # endif
 #endif
   x=0;
-  ping_info->width=image->columns;
-  ping_info->height=image->rows;
+  ping_width=image->columns;
+  ping_height=image->rows;
   if (logging)
     {
       (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                             "    width=%lu",
-                            (unsigned long)ping_info->width);
+                            (unsigned long)ping_width);
       (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                             "    height=%lu",
-                            (unsigned long)ping_info->height);
+                            (unsigned long)ping_height);
       (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                             "    image->depth=%u",image_depth);
     }
@@ -6306,12 +6376,12 @@ static MagickPassFail WriteOnePNGImage(M
   quantum_size=(image_depth > 8) ? 16:8;
 
   save_image_depth=image_depth;
-  ping_info->bit_depth=(png_byte) save_image_depth;
+  ping_bit_depth=(png_byte) save_image_depth;
   if (logging)
     {
       (void) LogMagickEvent(CoderEvent,GetMagickModule(),
-                            "    ping_info->bit_depth=%u",
-                            ping_info->bit_depth);
+                            "    ping_bit_depth=%u",
+                            ping_bit_depth);
     }
 #if defined(PNG_pHYs_SUPPORTED)
   if ((image->x_resolution != 0) && (image->y_resolution != 0) &&
@@ -6398,8 +6468,8 @@ static MagickPassFail WriteOnePNGImage(M
   matte=image_matte;
   if (mng_info->write_png8)
     {
-      ping_info->color_type=PNG_COLOR_TYPE_PALETTE;
-      ping_info->bit_depth=8;
+      ping_colortype=PNG_COLOR_TYPE_PALETTE;
+      ping_bit_depth=8;
       {
         /* TO DO: make this a function cause it's used twice, except
            for reducing the sample depth from 8. */
@@ -6424,13 +6494,13 @@ static MagickPassFail WriteOnePNGImage(M
                                     "    Colors quantized to %ld",
                                     number_colors);
           }
-        if (matte)
-          ping_info->valid|=PNG_INFO_tRNS;
+
         /*
           Set image palette.
         */
-        ping_info->color_type=PNG_COLOR_TYPE_PALETTE;
-        ping_info->valid|=PNG_INFO_PLTE;
+
+        ping_colortype=PNG_COLOR_TYPE_PALETTE;
+
 #if defined(PNG_SORT_PALETTE)
         save_number_colors=image_colors;
         if (CompressColormapTransFirst(image) == MagickFail)
@@ -6465,20 +6535,17 @@ static MagickPassFail WriteOnePNGImage(M
 
           }
         png_set_PLTE(ping,ping_info,palette,(int) number_colors);
-#if (PNG_LIBPNG_VER > 10008)
         MagickFreeMemory(palette);
-#endif
         /*
           Identify which colormap entry is transparent.
         */
-        ping_info->trans_alpha=MagickAllocateMemory(unsigned char *,
-           number_colors);
-        if (ping_info->trans_alpha == (unsigned char *) NULL)
+        ping_trans_alpha=MagickAllocateMemory(unsigned char *, number_colors);
+        if (ping_trans_alpha == (unsigned char *) NULL)
           ThrowWriterException(ResourceLimitError,MemoryAllocationFailed,
                                image);
         assert(number_colors <= 256);
         for (i=0; i < (long) number_colors; i++)
-          ping_info->trans_alpha[i]=255;
+          ping_trans_alpha[i]=255;
         for (y=0; y < (long) image->rows; y++)
           {
             register const PixelPacket
@@ -6498,29 +6565,29 @@ static MagickPassFail WriteOnePNGImage(M
 
                     index=indexes[x];
                     assert((unsigned long) index < number_colors);
-                    ping_info->trans_alpha[index]=(png_byte) (255-
+                    ping_trans_alpha[index]=(png_byte) (255-
                                             ScaleQuantumToChar(p->opacity));
                   }
                 p++;
               }
           }
-        ping_info->num_trans=0;
+        ping_num_trans=0;
         for (i=0; i < (long) number_colors; i++)
-          if (ping_info->trans_alpha[i] != 255)
-            ping_info->num_trans=(unsigned short) (i+1);
-        if (ping_info->num_trans == 0)
-          ping_info->valid&=(~PNG_INFO_tRNS);
-        if (!(ping_info->valid & PNG_INFO_tRNS))
-          ping_info->num_trans=0;
-        if (ping_info->num_trans == 0)
-          MagickFreeMemory(ping_info->trans_alpha);
+          if (ping_trans_alpha[i] != 255)
+            ping_num_trans=(unsigned short) (i+1);
+        if (ping_num_trans == 0)
+          png_set_invalid(ping,ping_info,PNG_INFO_tRNS);
+        if (!(png_get_valid(ping,ping_info,PNG_INFO_tRNS)))
+          ping_num_trans=0;
+        if (ping_num_trans == 0)
+          MagickFreeMemory(ping_trans_alpha);
         /*
           Identify which colormap entry is the background color.
         */
         for (i=0; i < (long) Max(number_colors-1,1); i++)
-          if (RGBColorMatchExact(ping_info->background,image->colormap[i]))
+          if (RGBColorMatchExact(ping_background,image->colormap[i]))
             break;
-        ping_info->background.index=(png_uint_16) i;
+        ping_background.index=(png_uint_16) i;
       }
       if (image_matte)
         {
@@ -6530,79 +6597,79 @@ static MagickPassFail WriteOnePNGImage(M
   else if (mng_info->write_png24)
     {
       image_matte=MagickFalse;
-      ping_info->color_type=PNG_COLOR_TYPE_RGB;
+      ping_colortype=PNG_COLOR_TYPE_RGB;
     }
   else if (mng_info->write_png32)
     {
       image_matte=MagickTrue;
-      ping_info->color_type=PNG_COLOR_TYPE_RGB_ALPHA;
+      ping_colortype=PNG_COLOR_TYPE_RGB_ALPHA;
     }
   else
     {
-      if (ping_info->bit_depth < 8)
-        ping_info->bit_depth=8;
+      if (ping_bit_depth < 8)
+        ping_bit_depth=8;
 
-      ping_info->color_type=PNG_COLOR_TYPE_RGB;
+      ping_colortype=PNG_COLOR_TYPE_RGB;
       if (characteristics.monochrome)
         {
           if (characteristics.opaque)
             {
-              ping_info->color_type=PNG_COLOR_TYPE_GRAY;
-              ping_info->bit_depth=1;
+              ping_colortype=PNG_COLOR_TYPE_GRAY;
+              ping_bit_depth=1;
             }
           else
             {
-              ping_info->color_type=PNG_COLOR_TYPE_GRAY_ALPHA;
+              ping_colortype=PNG_COLOR_TYPE_GRAY_ALPHA;
             }
         }
       else if (characteristics.grayscale)
         {
           if (characteristics.opaque)
-            ping_info->color_type=PNG_COLOR_TYPE_GRAY;
+            ping_colortype=PNG_COLOR_TYPE_GRAY;
           else
-            ping_info->color_type=PNG_COLOR_TYPE_GRAY_ALPHA;
+            ping_colortype=PNG_COLOR_TYPE_GRAY_ALPHA;
         }
       else if (characteristics.palette && image_colors <= 256)
         {
-          ping_info->color_type=PNG_COLOR_TYPE_PALETTE;
-          ping_info->bit_depth=8;
+          ping_colortype=PNG_COLOR_TYPE_PALETTE;
+          ping_bit_depth=8;
           mng_info->IsPalette=MagickTrue;
         }
       else
         {
           if (characteristics.opaque)
-            ping_info->color_type=PNG_COLOR_TYPE_RGB;
+            ping_colortype=PNG_COLOR_TYPE_RGB;
           else
-            ping_info->color_type=PNG_COLOR_TYPE_RGB_ALPHA;
+            ping_colortype=PNG_COLOR_TYPE_RGB_ALPHA;
         }
       if (image_info->type == BilevelType)
         {
           if (characteristics.monochrome)
             {
               if (!image_matte)
-                ping_info->bit_depth=1;
+                ping_bit_depth=1;
             }
         }
       if (image_info->type == GrayscaleType)
-        ping_info->color_type=PNG_COLOR_TYPE_GRAY;
+        ping_colortype=PNG_COLOR_TYPE_GRAY;
       if (image_info->type == GrayscaleMatteType)
-        ping_info->color_type=PNG_COLOR_TYPE_GRAY_ALPHA;
+        ping_colortype=PNG_COLOR_TYPE_GRAY_ALPHA;
       /*       if (!mng_info->optimize && matte) */
-      /*         ping_info->color_type=PNG_COLOR_TYPE_RGB_ALPHA; */
+      /*         ping_colortype=PNG_COLOR_TYPE_RGB_ALPHA; */
 
       if (logging)
         {
           (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                                 "    Tentative PNG color type: %s (%d)",
-                                PngColorTypeToString(ping_info->color_type),
-                                ping_info->color_type);
+                                PngColorTypeToString(ping_colortype),
+                                ping_colortype);
           (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                                 "    image_info->type: %d",image_info->type);
           (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                                 "    image->depth: %u",image_depth);
           (void) LogMagickEvent(CoderEvent,GetMagickModule(),
-                                "    ping_info->bit_depth: %d",
-                                ping_info->bit_depth);
+                                "    ping_bit_depth: %d",
+                                ping_bit_depth);
         }
 
       if (matte && (mng_info->optimize || mng_info->IsPalette))
@@ -6614,10 +6681,10 @@ static MagickPassFail WriteOnePNGImage(M
             {
               /*
                 No transparent pixels are present.  Change 4 or 6 to 0 or 2,
-                and do not set the PNG_INFO_tRNS flag in ping_info->valid.
+                and do not set the PNG_INFO_tRNS flag.
               */
               image_matte=MagickFalse;
-              ping_info->color_type&=0x03;
+              ping_colortype&=0x03;
             }
           else
             {
@@ -6625,13 +6692,13 @@ static MagickPassFail WriteOnePNGImage(M
                 mask;
 
               mask=0xffff;
-              if (ping_info->bit_depth == 8)
+              if (ping_bit_depth == 8)
                 mask=0x00ff;
-              if (ping_info->bit_depth == 4)
+              if (ping_bit_depth == 4)
                 mask=0x000f;
-              if (ping_info->bit_depth == 2)
+              if (ping_bit_depth == 2)
                 mask=0x0003;
-              if (ping_info->bit_depth == 1)
+              if (ping_bit_depth == 1)
                 mask=0x0001;
 
               /*
@@ -6655,19 +6722,20 @@ static MagickPassFail WriteOnePNGImage(M
               if ((p != (const PixelPacket *) NULL) &&
                   (p->opacity != OpaqueOpacity))
                 {
-                  ping_info->valid|=PNG_INFO_tRNS;
-                  ping_info->trans_color.red=ScaleQuantumToShort(p->red)&mask;
-                  ping_info->trans_color.green=ScaleQuantumToShort(p->green)
+                  ping_trans_color.red=ScaleQuantumToShort(p->red)&mask;
+                  ping_trans_color.green=ScaleQuantumToShort(p->green)
                                                 &mask;
-                  ping_info->trans_color.blue=ScaleQuantumToShort(p->blue)
+                  ping_trans_color.blue=ScaleQuantumToShort(p->blue)
                                                &mask;
-                  ping_info->trans_color.gray=
+                  ping_trans_color.gray=
                     (png_uint_16) ScaleQuantumToShort(PixelIntensity(p))&mask;
-                  ping_info->trans_color.index=(unsigned char)
+                  ping_trans_color.index=(unsigned char)
                     (ScaleQuantumToChar(MaxRGB-p->opacity));
+                  (void) png_set_tRNS(ping, ping_info, NULL, 0,
+                                      &ping_trans_color);
                 }
             }
-          if (ping_info->valid & PNG_INFO_tRNS)
+          if (png_get_valid(ping, ping_info, PNG_INFO_tRNS))
             {
               /*
                 Determine if there is one and only one transparent color
@@ -6684,7 +6752,7 @@ static MagickPassFail WriteOnePNGImage(M
                     {
                       if (p->opacity != OpaqueOpacity)
                         {
-                          if (!RGBColorMatchExact(ping_info->trans_color,*p))
+                          if (!RGBColorMatchExact(ping_trans_color,*p))
                             {
                               break;  /* Can't use RGB + tRNS for multiple
                                          transparent colors.  */
@@ -6697,7 +6765,7 @@ static MagickPassFail WriteOnePNGImage(M
                         }
                       else
                         {
-                          if (RGBColorMatchExact(ping_info->trans_color,*p))
+                          if (RGBColorMatchExact(ping_trans_color,*p))
                             break; /* Can't use RGB + tRNS when another pixel
                                       having the same RGB samples is
                                       transparent. */
@@ -6708,50 +6776,50 @@ static MagickPassFail WriteOnePNGImage(M
                     break;
                 }
               if (x != 0)
-                ping_info->valid&=(~PNG_INFO_tRNS);
+                png_set_invalid(ping, ping_info, PNG_INFO_tRNS);
             }
-          if (ping_info->valid & PNG_INFO_tRNS)
+          if (png_get_valid(ping, ping_info, PNG_INFO_tRNS))
             {
-              ping_info->color_type &= 0x03;  /* changes 4 or 6 to 0 or 2 */
+              ping_colortype &= 0x03;  /* changes 4 or 6 to 0 or 2 */
               if (image_depth == 8)
                 {
-                  ping_info->trans_color.red&=0xff;
-                  ping_info->trans_color.green&=0xff;
-                  ping_info->trans_color.blue&=0xff;
-                  ping_info->trans_color.gray&=0xff;
+                  ping_trans_color.red&=0xff;
+                  ping_trans_color.green&=0xff;
+                  ping_trans_color.blue&=0xff;
+                  ping_trans_color.gray&=0xff;
                 }
             }
         }
       matte=image_matte;
-      if (ping_info->valid & PNG_INFO_tRNS)
+      if (png_get_valid(ping, ping_info, PNG_INFO_tRNS))
         image_matte=MagickFalse;
       if ((mng_info->optimize || mng_info->IsPalette) &&
           characteristics.grayscale && (!image_matte || image_depth >= 8))
         {
           if (image_matte)
-            ping_info->color_type=PNG_COLOR_TYPE_GRAY_ALPHA;
+            ping_colortype=PNG_COLOR_TYPE_GRAY_ALPHA;
           else
             {
-              ping_info->color_type=PNG_COLOR_TYPE_GRAY;
+              ping_colortype=PNG_COLOR_TYPE_GRAY;
               if (save_image_depth == 16 && image_depth == 8)
-                ping_info->trans_color.gray*=0x0101;
+                ping_trans_color.gray*=0x0101;
             }
           if (image_depth > QuantumDepth)
             image_depth=QuantumDepth;
           if (image_colors == 0 || image_colors-1 > MaxRGB)
             image_colors=1 << image_depth;
           if (image_depth > 8)
-            ping_info->bit_depth=16;
+            ping_bit_depth=16;
           else
             {
-              if (ping_info->color_type == PNG_COLOR_TYPE_PALETTE)
+              if (ping_colortype == PNG_COLOR_TYPE_PALETTE)
                 {
-                  ping_info->bit_depth=1;
-                  while ((int) (1 << ping_info->bit_depth) <
+                  ping_bit_depth=1;
+                  while ((int) (1 << ping_bit_depth) <
                                 (long) image_colors)
-                    ping_info->bit_depth <<= 1;
+                    ping_bit_depth <<= 1;
                 }
-              else if (mng_info->optimize && ping_info->color_type ==
+              else if (mng_info->optimize && ping_colortype ==
                        PNG_COLOR_TYPE_GRAY && image_colors < 17 &&
                        mng_info->IsPalette)
                 {
@@ -6779,11 +6847,11 @@ static MagickPassFail WriteOnePNGImage(M
                         depth_1_ok=MagickFalse;
                     }
                   if (depth_1_ok)
-                    ping_info->bit_depth=1;
+                    ping_bit_depth=1;
                   else if (depth_2_ok)
-                    ping_info->bit_depth=2;
+                    ping_bit_depth=2;
                   else if (depth_4_ok)
-                    ping_info->bit_depth=4;
+                    ping_bit_depth=4;
                 }
             }
         }
@@ -6796,13 +6864,10 @@ static MagickPassFail WriteOnePNGImage(M
                   number_colors;
 
                 number_colors=image_colors;
-                if (matte)
-                  ping_info->valid|=PNG_INFO_tRNS;
                 /*
                   Set image palette.
                 */
-                ping_info->color_type=PNG_COLOR_TYPE_PALETTE;
-                ping_info->valid|=PNG_INFO_PLTE;
+                ping_colortype=PNG_COLOR_TYPE_PALETTE;
                 if (mng_info->have_write_global_plte && !matte)
                   {
                     png_set_PLTE(ping,ping_info,NULL,0);
@@ -6847,14 +6912,12 @@ static MagickPassFail WriteOnePNGImage(M
                            "  Setting up PLTE chunk with %d colors",
                            (int) number_colors);
                     png_set_PLTE(ping,ping_info,palette,(int) number_colors);
-#if (PNG_LIBPNG_VER > 10008)
                     MagickFreeMemory(palette);
-#endif
                   }
-                ping_info->bit_depth=1;
-                while ((1UL << ping_info->bit_depth) < number_colors)
-                  ping_info->bit_depth <<= 1;
-                ping_info->num_trans=0;
+                ping_bit_depth=1;
+                while ((1UL << ping_bit_depth) < number_colors)
+                  ping_bit_depth <<= 1;
+                ping_num_trans=0;
                 if (matte)
                   {
                     int
@@ -6890,7 +6953,7 @@ static MagickPassFail WriteOnePNGImage(M
                                     if (trans_alpha[index] != (png_byte) (255-
                                         ScaleQuantumToChar(p->opacity)))
                                       {
-                                        ping_info->color_type=
+                                        ping_colortype=
                                           PNG_COLOR_TYPE_RGB_ALPHA;
                                         break;
                                       }
@@ -6900,11 +6963,11 @@ static MagickPassFail WriteOnePNGImage(M
                               }
                             p++;
                           }
-                        if (ping_info->color_type==PNG_COLOR_TYPE_RGB_ALPHA)
+                        if (ping_colortype==PNG_COLOR_TYPE_RGB_ALPHA)
                           {
-                            ping_info->num_trans=0;
-                            ping_info->valid&=(~PNG_INFO_tRNS);
-                            ping_info->valid&=(~PNG_INFO_PLTE);
+                            ping_num_trans=0;
+                            png_set_invalid(ping, ping_info, PNG_INFO_tRNS);
+                            png_set_invalid(ping, ping_info, PNG_INFO_PLTE);
                             mng_info->IsPalette=MagickFalse;
                             (void) SyncImage(image);
                             if (logging)
@@ -6916,40 +6979,41 @@ static MagickPassFail WriteOnePNGImage(M
                             break;
                           }
                       }
-                    if ((ping_info->valid & PNG_INFO_tRNS))
+                    if (png_get_valid(ping, ping_info, PNG_INFO_tRNS))
                       {
                         for (i=0; i < (long) number_colors; i++)
                           {
                             if (trans_alpha[i] == 256)
                               trans_alpha[i]=255;
                             if (trans_alpha[i] != 255)
-                              ping_info->num_trans=(unsigned short) (i+1);
+                              ping_num_trans=(unsigned short) (i+1);
                           }
                       }
-                    if (ping_info->num_trans == 0)
-                      ping_info->valid&=(~PNG_INFO_tRNS);
-                    if (!(ping_info->valid & PNG_INFO_tRNS))
-                      ping_info->num_trans=0;
-                    if (ping_info->num_trans != 0)
+                    if (ping_num_trans == 0)
+                       png_set_invalid(ping, ping_info, PNG_INFO_tRNS);
+                    if (!png_get_valid(ping, ping_info, PNG_INFO_tRNS))
+                       ping_num_trans=0;
+
+                    if (ping_num_trans != 0)
                       {
-                        ping_info->trans_alpha=MagickAllocateMemory(
-                                              unsigned char *, number_colors);
-                        if (ping_info->trans_alpha == (unsigned char *) NULL)
-                          ThrowWriterException(ResourceLimitError,
-                                               MemoryAllocationFailed,image);
-                        for (i=0; i < (long) number_colors; i++)
-                          ping_info->trans_alpha[i]=(png_byte) trans_alpha[i];
+                        for (i=0; i<256; i++)
+                           ping_trans_alpha[i]=(png_byte) trans_alpha[i];
                       }
+
+                    (void) png_set_tRNS(ping, ping_info,
+                                        ping_trans_alpha,
+                                        ping_num_trans,
+                                        &ping_trans_color);
                   }
 
                 /*
                   Identify which colormap entry is the background color.
                 */
                 for (i=0; i < (long) Max(number_colors-1,1); i++)
-                  if (RGBColorMatchExact(ping_info->background,
+                  if (RGBColorMatchExact(ping_background,
                                          image->colormap[i]))
                     break;
-                ping_info->background.index=(png_uint_16) i;
+                ping_background.index=(png_uint_16) i;
               }
           }
         else
@@ -6958,10 +7022,10 @@ static MagickPassFail WriteOnePNGImage(M
               image_depth=8;
             if ((save_image_depth == 16) && (image_depth == 8))
               {
-                ping_info->trans_color.red*=0x0101;
-                ping_info->trans_color.green*=0x0101;
-                ping_info->trans_color.blue*=0x0101;
-                ping_info->trans_color.gray*=0x0101;
+                ping_trans_color.red*=0x0101;
+                ping_trans_color.green*=0x0101;
+                ping_trans_color.blue*=0x0101;
+                ping_trans_color.gray*=0x0101;
               }
           }
 
@@ -6969,7 +7033,7 @@ static MagickPassFail WriteOnePNGImage(M
         Adjust background and transparency samples in sub-8-bit
         grayscale files.
       */
-      if (ping_info->bit_depth < 8 && ping_info->color_type ==
+      if (ping_bit_depth < 8 && ping_colortype ==
           PNG_COLOR_TYPE_GRAY)
         {
           png_uint_16
@@ -6978,7 +7042,7 @@ static MagickPassFail WriteOnePNGImage(M
           png_color_16
             background;
 
-          maxval=(1 << ping_info->bit_depth)-1;
+          maxval=(1 << ping_bit_depth)-1;
 
 
           background.gray=(png_uint_16)
@@ -6989,28 +7053,26 @@ static MagickPassFail WriteOnePNGImage(M
                                   "  Setting up bKGD chunk");
           png_set_bKGD(ping,ping_info,&background);
 
-          ping_info->trans_color.gray=(png_uint_16)(maxval*
-                                        ping_info->trans_color.gray/
-                                        MaxRGB);
+          ping_trans_color.gray=(png_uint_16)(maxval*
+                                ping_trans_color.gray/
+                                MaxRGB);
         }
     }
   if (logging)
     (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                           "    PNG color type: %s (%d)",
-                          PngColorTypeToString(ping_info->color_type),
-                          ping_info->color_type);
+                          PngColorTypeToString(ping_colortype),
+                          ping_colortype);
   /*
     Initialize compression level and filtering.
   */
   if (logging)
     (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                           "  Setting up deflate compression");
-#if (PNG_LIBPNG_VER > 99)
   if (logging)
     (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                           "    Compression buffer size: 32768");
   png_set_compression_buffer_size(ping,32768L);
-#endif
   if (logging)
     (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                           "    Compression mem level: 9");
@@ -7044,7 +7106,7 @@ static MagickPassFail WriteOnePNGImage(M
       if (logging)
         (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                               "    Filter_type: PNG_INTRAPIXEL_DIFFERENCING");
-      ping_info->filter_type=PNG_INTRAPIXEL_DIFFERENCING;
+      ping_filter_method=PNG_INTRAPIXEL_DIFFERENCING;
     }
   else
     if (logging)
@@ -7061,8 +7123,8 @@ static MagickPassFail WriteOnePNGImage(M
       if ((image_info->quality % 10) != 5)
         base_filter=(int) image_info->quality % 10;
       else
-        if ((ping_info->color_type == PNG_COLOR_TYPE_GRAY) ||
-            (ping_info->color_type == PNG_COLOR_TYPE_PALETTE) ||
+        if ((ping_colortype == PNG_COLOR_TYPE_GRAY) ||
+            (ping_colortype == PNG_COLOR_TYPE_PALETTE) ||
             (image_info->quality < 50))
           base_filter=PNG_NO_FILTERS;
         else
@@ -7099,7 +7161,7 @@ static MagickPassFail WriteOnePNGImage(M
           {
             if (LocaleCompare(profile_name,"ICM") == 0)
               {
-#if (PNG_LIBPNG_VER > 10008) && defined(PNG_WRITE_iCCP_SUPPORTED)
+#if defined(PNG_WRITE_iCCP_SUPPORTED)
                 {
                   if (logging)
                     (void) LogMagickEvent(CoderEvent,GetMagickModule(),
@@ -7170,8 +7232,8 @@ static MagickPassFail WriteOnePNGImage(M
         (void) png_set_sRGB(ping,ping_info,PerceptualIntent);
       png_set_gAMA(ping,ping_info,0.45455);
     }
-  not_valid=(!ping_info->valid);
-  if ((!mng_info->write_mng) || not_valid & PNG_INFO_sRGB)
+  if ((!mng_info->write_mng) || 
+       !png_get_valid(ping, ping_info, PNG_INFO_sRGB))
 #endif
     {
       if (!mng_info->have_write_global_gama && (image->gamma != 0.0))
@@ -7210,7 +7272,7 @@ static MagickPassFail WriteOnePNGImage(M
                        bp.x,bp.y);
         }
     }
-  ping_info->interlace_type=(image_info->interlace == LineInterlace);
+  ping_interlace_method=(image_info->interlace == LineInterlace);
 
   if (mng_info->write_mng)
     png_set_sig_bytes(ping,8);
@@ -7219,6 +7281,15 @@ static MagickPassFail WriteOnePNGImage(M
     (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                           "  Writing PNG header chunks");
 
+  png_set_IHDR(ping,ping_info,
+               ping_width,
+               ping_height,
+               ping_bit_depth,
+               ping_colortype,
+               ping_interlace_method,
+               ping_compression_method,
+               ping_filter_method);
+
   png_write_info(ping,ping_info);
 
 #if (PNG_LIBPNG_VER == 10206)
@@ -7313,7 +7384,7 @@ static MagickPassFail WriteOnePNGImage(M
       {
         if ((!mng_info->write_png8 && !mng_info->write_png24 &&
              !mng_info->write_png32) &&
-            (!image_matte || (ping_info->bit_depth >= QuantumDepth)) &&
+            (!image_matte || (ping_bit_depth >= QuantumDepth)) &&
             (mng_info->optimize || mng_info->IsPalette) &&
             IsGrayImage(image,&image->exception))
           {
@@ -7325,7 +7396,7 @@ static MagickPassFail WriteOnePNGImage(M
                 if (!AcquireImagePixels(image,0,y,image->columns,1,
                                         &image->exception))
                   break;
-                if (ping_info->color_type == PNG_COLOR_TYPE_GRAY)
+                if (ping_colortype == PNG_COLOR_TYPE_GRAY)
                   {
                     if (mng_info->IsPalette)
                       (void) ExportImagePixelArea(image,
@@ -7368,14 +7439,14 @@ static MagickPassFail WriteOnePNGImage(M
                                           "  pass %d, Image Is RGB,"
                                           " PNG colortype is %s (%d)",pass,
                                           PngColorTypeToString(
-                                             ping_info->color_type),
-                                          ping_info->color_type);
+                                             ping_colortype),
+                                          ping_colortype);
                   for (y=0; y < (long) image->rows; y++)
                     {
                       if (!AcquireImagePixels(image,0,y,image->columns,1,
                                               &image->exception))
                         break;
-                      if (ping_info->color_type == PNG_COLOR_TYPE_GRAY)
+                      if (ping_colortype == PNG_COLOR_TYPE_GRAY)
                         {
                           if (image->storage_class == DirectClass)
                             (void) ExportImagePixelArea(image,(QuantumType)
@@ -7388,7 +7459,7 @@ static MagickPassFail WriteOnePNGImage(M
                                                         quantum_size,
                                                         png_pixels,0,0);
                         }
-                      else if (ping_info->color_type ==
+                      else if (ping_colortype ==
                                PNG_COLOR_TYPE_GRAY_ALPHA)
                         (void) ExportImagePixelArea(image,(QuantumType)
                                                     GrayAlphaQuantum,
@@ -7433,12 +7504,12 @@ static MagickPassFail WriteOnePNGImage(M
                       if (!AcquireImagePixels(image,0,y,image->columns,1,
                                               &image->exception))
                         break;
-                      if (ping_info->color_type == PNG_COLOR_TYPE_GRAY)
+                      if (ping_colortype == PNG_COLOR_TYPE_GRAY)
                         (void) ExportImagePixelArea(image,(QuantumType)
                                                     GrayQuantum,
                                                     quantum_size,
                                                     png_pixels,0,0);
-                      else if (ping_info->color_type ==
+                      else if (ping_colortype ==
                                PNG_COLOR_TYPE_GRAY_ALPHA)
                         (void) ExportImagePixelArea(image,(QuantumType)
                                                     GrayAlphaQuantum,
@@ -7471,38 +7542,32 @@ static MagickPassFail WriteOnePNGImage(M
                             "  Writing PNG image data");
       (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                             "    Width: %lu",
-                            (unsigned long)ping_info->width);
+                            (unsigned long)ping_width);
       (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                             "    Height: %lu",
-                            (unsigned long)ping_info->height);
+                            (unsigned long)ping_height);
       (void) LogMagickEvent(CoderEvent,GetMagickModule(),
-                            "    PNG sample depth: %d",ping_info->bit_depth);
+                            "    PNG sample depth: %d",ping_bit_depth);
       (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                             "    PNG color type: %s (%d)",
-                            PngColorTypeToString(ping_info->color_type),
-                            ping_info->color_type);
+                            PngColorTypeToString(ping_colortype),
+                            ping_colortype);
       (void) LogMagickEvent(CoderEvent,GetMagickModule(),
                             "    PNG Interlace method: %d",
-                            ping_info->interlace_type);
+                            ping_interlace_method);
     }
   /*
     Generate text chunks.
   */
-#if (PNG_LIBPNG_VER <= 10005)
-  ping_info->num_text=0;
-#endif
   attribute=GetImageAttribute(image,(char *) NULL);
   for ( ; attribute != (const ImageAttribute *) NULL;
         attribute=attribute->next)
     {
-#if (PNG_LIBPNG_VER > 10005)
       png_textp
         text;
-#endif
 
       if (*attribute->key == '[')
         continue;
-#if (PNG_LIBPNG_VER > 10005)
       text=(png_textp) png_malloc(ping,(png_uint_32) sizeof(png_text));
       text[0].key=attribute->key;
       text[0].text=attribute->value;
@@ -7519,40 +7584,6 @@ static MagickPassFail WriteOnePNGImage(M
         }
       png_set_text(ping,ping_info,text,1);
       png_free(ping,text);
-#else
-      /* Work directly with ping_info struct;
-       * png_set_text before libpng version
-       * 1.0.5a is leaky */
-      if (ping_info->num_text == 0)
-        {
-          ping_info->text=MagickAllocateMemory(png_text *,
-                                               256*sizeof(png_text));
-          if (ping_info->text == (png_text *) NULL)
-            (void) ThrowException(&image->exception,(ExceptionType)
-                                  ResourceLimitError,MemoryAllocationFailed,
-                                  image->filename);
-        }
-      i=ping_info->num_text++;
-      if (i > 255)
-        (void) ThrowException(&image->exception,(ExceptionType)
-                              ResourceLimitError,
-                              "Cannot write more than 256 PNG text chunks",
-                              image->filename);
-      ping_info->text[i].key=attribute->key;
-      ping_info->text[i].text=attribute->value;
-      ping_info->text[i].text_length=strlen(attribute->value);
-      ping_info->text[i].compression=
-        image_info->compression == NoCompression ||
-        (image_info->compression == UndefinedCompression &&
-         ping_info->text[i].text_length < 128) ? -1 : 0;
-      if (logging)
-        {
-          (void) LogMagickEvent(CoderEvent,GetMagickModule(),
-                                "  Setting up text chunk");
-          (void) LogMagickEvent(CoderEvent,GetMagickModule(),
-                                "    keyword: %s",ping_info->text[i].key);
-        }
-#endif
     }
   if (logging)
     (void) LogMagickEvent(CoderEvent,GetMagickModule(),
@@ -7560,9 +7591,9 @@ static MagickPassFail WriteOnePNGImage(M
   png_write_end(ping,ping_info);
   if (mng_info->need_fram && (int) image->dispose == BackgroundDispose)
     {
-      if (mng_info->page.x || mng_info->page.y || (ping_info->width !=
+      if (mng_info->page.x || mng_info->page.y || (ping_width !=
                                                    mng_info->page.width) ||
-          (ping_info->height != mng_info->page.height))
+          (ping_height != mng_info->page.height))
         {
           unsigned char
             chunk[32];
@@ -7583,10 +7614,10 @@ static MagickPassFail WriteOnePNGImage(M
           chunk[14]=0; /* clipping boundaries delta type */
           PNGLong(chunk+15,(png_uint_32) (mng_info->page.x)); /* left cb */
           PNGLong(chunk+19,(png_uint_32) (mng_info->page.x +
-                                          ping_info->width));
+                                          ping_width));
           PNGLong(chunk+23,(png_uint_32) (mng_info->page.y)); /* top cb */
           PNGLong(chunk+27,(png_uint_32) (mng_info->page.y +
-                                          ping_info->height));
+                                          ping_height));
           (void) WriteBlob(image,31,(char *) chunk);
           (void) WriteBlobMSBULong(image,crc32(0,chunk,31));
           mng_info->old_framing_mode=4;
@@ -7605,7 +7636,7 @@ static MagickPassFail WriteOnePNGImage(M
 
   /* Save depth actually written */
 
-  s[0]=(char) ping_info->bit_depth;
+  s[0]=(char) ping_bit_depth;
   s[1]='\0';
 
   (void) SetImageAttribute(image,"[png:bit-depth-written]",s);
@@ -7613,18 +7644,6 @@ static MagickPassFail WriteOnePNGImage(M
   /*
     Free PNG resources.
   */
-#if (PNG_LIBPNG_VER < 10007)
-  if (ping_info->valid & PNG_INFO_PLTE)
-    {
-      MagickFreeMemory(ping_info->palette);
-      ping_info->valid&=(~PNG_INFO_PLTE);
-    }
-#endif
-  if (ping_info->valid & PNG_INFO_tRNS)
-    {
-      MagickFreeMemory(ping_info->trans_alpha);
-      ping_info->valid&=(~PNG_INFO_tRNS);
-    }
   png_destroy_write_struct(&ping,&ping_info);
 
   MagickFreeMemory(png_pixels);
@@ -8365,23 +8384,12 @@ static unsigned int WriteMNGImage(const 
     final_delay=0,
     initial_delay;
 
-#if (PNG_LIBPNG_VER < 10007)
+#if (PNG_LIBPNG_VER < 10200)
   if (image_info->verbose)
     printf("Your PNG library (libpng-%s) is rather old.\n",
            PNG_LIBPNG_VER_STRING);
 #endif
 
-#if (PNG_LIBPNG_VER >= 10400)
-#  ifndef  PNG_TRANSFORM_GRAY_TO_RGB    /* Added at libpng-1.4.0beta67 */
-  if (image_info->verbose)
-    {
-      printf("Your PNG library (libpng-%s) is an old beta version.\n",
-           PNG_LIBPNG_VER_STRING);
-      printf("Please update it.\n");
-    }
-#  endif
-#endif
-
   /*
     Open image file.
   */
@@ -9196,7 +9204,7 @@ static unsigned int WriteMNGImage(const 
     (void) LogMagickEvent(CoderEvent,GetMagickModule(),"exit WriteMNGImage()");
   return(MagickPass);
 }
-#else /* PNG_LIBPNG_VER > 95 */
+#else /* PNG_LIBPNG_VER > 10011 */
 static unsigned int WritePNGImage(const ImageInfo *image_info,Image *image)
 {
   image=image;
@@ -9208,5 +9216,5 @@ static unsigned int WriteMNGImage(const 
 {
   return (WritePNGImage(image_info,image));
 }
-#endif /* PNG_LIBPNG_VER > 95 */
+#endif /* PNG_LIBPNG_VER > 10011 */
 #endif
