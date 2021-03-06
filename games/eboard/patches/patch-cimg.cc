$NetBSD: patch-cimg.cc,v 1.1 2011/04/03 10:35:58 wiz Exp $

Fix build with png-1.5.

--- cimg.cc.orig	2007-05-23 18:57:45.000000000 +0000
+++ cimg.cc
@@ -95,16 +95,16 @@ CImg::CImg(const char *filename) {
       ct == PNG_COLOR_TYPE_GRAY_ALPHA)
     png_set_gray_to_rgb(pngp);
 
-  alloc(pngp->width,pngp->height);
+  alloc(png_get_image_width(pngp, infp),png_get_image_height(pngp, infp));
   if (!ok) { fclose(f); return; }
   ok = 0;
 
-  rp = (png_bytep *) malloc(sizeof(png_bytep) * (pngp->height));
+  rp = (png_bytep *) malloc(sizeof(png_bytep) * (png_get_image_height(pngp, infp)));
   if (rp==NULL) {
     fclose(f); return;
   }
 
-  for(i=0;i<pngp->height;i++) {
+  for(i=0;i<png_get_image_height(pngp, infp);i++) {
     png_read_row(pngp, (png_bytep) (&data[i*rowlen]), NULL);
   }
 
