$NetBSD: patch-png2-xv.h,v 1.1 1999/06/13 16:23:54 hubertf Exp $

This patch is based on
http://www.mit.edu/afs/athena/contrib/graphics/src/xv/patches/png/xvpng.diff
It was edited to fit into the NetBSD Packages Collection! - HF

---------------------------------------------------------------------------


--- xv.h.orig	Sun Jun 13 03:41:34 1999
+++ xv.h	Sun Jun 13 03:53:34 1999
@@ -8,8 +8,8 @@
 #include "config.h"
 
 
-#define REVDATE   "Version 3.10a  Rev: 12/29/94"
-#define VERSTR    "3.10a"
+#define REVDATE   "Version 3.10a  Rev: 12/29/94 (PNG patch 1.2)"
+#define VERSTR    "3.10a(PNG)"
 
 /*
  * uncomment the following, and modify for your site, but only if you've
@@ -343,6 +343,10 @@
 #define HAVE_TIFF
 #endif
 
+#ifdef DOPNG
+#define HAVE_PNG
+#endif
+
 #ifdef DOPDS
 #define HAVE_PDS
 #endif
@@ -478,31 +482,38 @@
 #define MACBSIZE 128
 #endif
 
+#ifdef HAVE_PNG
+#define F_PNGINC  1
+#else
+#define F_PNGINC  0
+#endif
+
 #define F_GIF         0
 #define F_JPEG      ( 0 + F_JPGINC)
 #define F_TIFF      ( 0 + F_JPGINC + F_TIFINC)
-#define F_PS        ( 1 + F_JPGINC + F_TIFINC)
-#define F_PBMRAW    ( 2 + F_JPGINC + F_TIFINC)
-#define F_PBMASCII  ( 3 + F_JPGINC + F_TIFINC)
-#define F_XBM       ( 4 + F_JPGINC + F_TIFINC)
-#define F_XPM       ( 5 + F_JPGINC + F_TIFINC)
-#define F_BMP       ( 6 + F_JPGINC + F_TIFINC)
-#define F_SUNRAS    ( 7 + F_JPGINC + F_TIFINC)
-#define F_IRIS      ( 8 + F_JPGINC + F_TIFINC)
-#define F_TARGA     ( 9 + F_JPGINC + F_TIFINC)
-#define F_FITS      (10 + F_JPGINC + F_TIFINC)
-#define F_PM        (11 + F_JPGINC + F_TIFINC)
-#define F_MAG       (12 + F_JPGINC + F_TIFINC)
-#define F_PIC       (13 + F_JPGINC + F_TIFINC)
-#define F_MAKI      (14 + F_JPGINC + F_TIFINC)
-#define F_PI        (15 + F_JPGINC + F_TIFINC)
-#define F_PIC2_SS   (16 + F_JPGINC + F_TIFINC)
-#define F_PIC2_SF   (17 + F_JPGINC + F_TIFINC)
-#define F_PIC2_BM   (18 + F_JPGINC + F_TIFINC)
-#define F_PIC2_BI   (19 + F_JPGINC + F_TIFINC)     /* ----- */
-#define F_DELIM1    (20 + F_JPGINC + F_TIFINC)
-#define F_FILELIST  (21 + F_JPGINC + F_TIFINC)
-#define F_MAXFMTS   (22 + F_JPGINC + F_TIFINC)     /* 16, normally */
+#define F_PNG       ( 0 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_PS        ( 1 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_PBMRAW    ( 2 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_PBMASCII  ( 3 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_XBM       ( 4 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_XPM       ( 5 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_BMP       ( 6 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_SUNRAS    ( 7 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_IRIS      ( 8 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_TARGA     ( 9 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_FITS      (10 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_PM        (11 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_MAG       (12 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_PIC       (13 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_MAKI      (14 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_PI        (15 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_PIC2_SS   (16 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_PIC2_SF   (17 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_PIC2_BM   (18 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_PIC2_BI   (19 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_DELIM1    (20 + F_JPGINC + F_TIFINC + F_PNGINC)   /* ----- */
+#define F_FILELIST  (21 + F_JPGINC + F_TIFINC + F_PNGINC)
+#define F_MAXFMTS   (22 + F_JPGINC + F_TIFINC + F_PNGINC)   /* 25, normally */
 
 
 
@@ -538,6 +549,7 @@
 #define RFT_PI       23
 #define RFT_PIC2     24
 #define RFT_PCD      25
+#define RFT_PNG      26 /* HF: was 20 */
 
 /* definitions for page up/down, arrow up/down list control */
 #define LS_PAGEUP   0
@@ -798,9 +810,10 @@
 typedef struct { Window win;            /* window ID */
 		 int x,y,w,h;           /* window coords in parent */
 		 int active;            /* true if can do anything*/
-		 int min,max;           /* min/max values 'pos' can take */
-		 int val;               /* 'value' of dial */
-		 int page;              /* amt val change on pageup/pagedown */
+		 double min,max;        /* min/max values 'pos' can take */
+		 double val;            /* 'value' of dial */
+                 double inc;            /* amt val change on up/down */
+		 double page;           /* amt val change on pageup/pagedown */
 		 char *title;           /* title for this guage */
 		 char *units;           /* string appended to value */
 		 u_long fg,bg,hi,lo;    /* colors */
@@ -1192,6 +1205,13 @@
 WHERE Window        pcdW;
 WHERE int           pcdUp;       /* is pcdW mapped, or what? */
 
+#ifdef HAVE_PNG
+/* stuff used for 'png' box */
+WHERE Window        pngW;
+WHERE int           pngUp;        /* is pngW mapped, or what? */
+#endif
+
+
 #undef WHERE
 
 
@@ -1506,12 +1526,12 @@
 
 
 /*************************** XVDIAL.C ***************************/
-void DCreate               PARM((DIAL *, Window, int, int, int, int, int, 
-				 int, int, int, u_long, u_long, u_long, 
-				 u_long, char *, char *));
+void DCreate               PARM((DIAL *, Window, int, int, int, int, double, 
+				 double, double, double, double, u_long,
+                                 u_long, u_long, u_long, char *, char *));
 
-void DSetRange             PARM((DIAL *, int, int, int, int));
-void DSetVal               PARM((DIAL *, int));
+void DSetRange             PARM((DIAL *, double,double,double,double,double));
+void DSetVal               PARM((DIAL *, double));
 void DSetActive            PARM((DIAL *, int));
 void DRedraw               PARM((DIAL *));
 int  DTrack                PARM((DIAL *, int, int));
@@ -1653,6 +1673,13 @@
 void  TIFFDialog           PARM((int));
 int   TIFFCheckEvent       PARM((XEvent *));
 void  TIFFSaveParams       PARM((char *, int));
+
+/**************************** XVPNG.C ***************************/
+int  LoadPNG               PARM((char *, PICINFO *));
+void CreatePNGW            PARM((void));
+void PNGDialog             PARM((int));
+int  PNGCheckEvent         PARM((XEvent *));
+void PNGSaveParams         PARM((char *, int));
 
 /**************************** XVPDS.C ***************************/
 int LoadPDS                PARM((char *, PICINFO *));
