# $NetBSD: buildlink2.mk,v 1.1 2002/10/25 09:20:42 wiz Exp $
#

.if !defined(BLT_BUILDLINK2_MK)
BLT_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		blt
BUILDLINK_DEPENDS.blt?=		blt>=2.4o
BUILDLINK_PKGSRCDIR.blt?=	../../x11/blt

EVAL_PREFIX+=	BUILDLINK_PREFIX.blt=blt
BUILDLINK_PREFIX.blt_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.blt+=	include/blt.h
BUILDLINK_FILES.blt+=	lib/libBLT.*
BUILDLINK_FILES.blt+=	lib/libBLT24.*
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/bltCanvEps.pro
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/bltDnd.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/bltDragdrop.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/bltGraph.pro
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/bltGraph.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/bltHierbox.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/bltHiertable.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/bltTabset.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/dd_protocols/dd-color.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/dd_protocols/dd-file.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/dd_protocols/dd-number.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/dd_protocols/dd-text.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/dd_protocols/tclIndex
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/barchart1.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/barchart2.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/barchart3.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/barchart4.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/barchart5.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bgexec1.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bgexec2.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bgexec3.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bgexec4.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmap.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/face.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/fish/left.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/fish/left1.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/fish/left1m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/fish/leftm.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/fish/mid.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/fish/midm.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/fish/right.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/fish/right1.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/fish/right1m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/fish/rightm.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/greenback.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand01.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand01m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand02.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand02m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand03.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand03m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand04.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand04m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand05.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand05m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand06.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand06m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand07.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand07m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand08.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand08m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand09.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand09m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand10.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand10m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand11.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand11m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand12.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand12m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand13.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand13m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand14.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hand/hand14m.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hobbes.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/hobbes_mask.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/sharky.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/bitmaps/xbob.xbm
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/busy1.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/dragdrop1.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/dragdrop2.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/eps.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/graph1.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/graph2.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/graph3.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/graph4.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/graph5.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/graph6.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/graph7.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/hierbox1.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/hierbox2.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/hierbox3.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/hierbox4.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/hiertable1.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/htext.txt
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/htext1.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/blt98.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/buckskin.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/chalk.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/close.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/close2.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/clouds.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/corrugated_metal.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/folder.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/mini-book1.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/mini-book2.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/mini-display.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/mini-doc.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/mini-filemgr.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/mini-ofolder.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/mini-windows.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/ofolder.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/open.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/open2.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/out.ps
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/qv100.t.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/rain.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/sample.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/smblue_rock.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/stopsign.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/tan_paper.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/tan_paper2.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/images/txtrflag.gif
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/barchart2.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/bgtest.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/clone.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/demo.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/globe.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/graph1.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/graph2.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/graph3.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/graph5.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/graph8.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/page.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/patterns.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/ps.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/send.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/stipples.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/scripts/xcolors.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/spline.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/stripchart1.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/tabset1.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/tabset2.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/tabset3.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/tabset4.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/demos/winop1.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/pkgIndex.tcl
BUILDLINK_FILES.blt+=	lib/tcl/blt2.4/tclIndex

.include "../../lang/tcl/buildlink2.mk"
.include "../../x11/tk/buildlink2.mk"

BUILDLINK_TARGETS+=	blt-buildlink

blt-buildlink: _BUILDLINK_USE

.endif	# BLT_BUILDLINK2_MK
