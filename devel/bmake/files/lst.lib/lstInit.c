/*	$NetBSD: lstInit.c,v 1.1 2005/10/31 21:52:26 reed Exp $	*/

/*
 * Copyright (c) 1988, 1989, 1990, 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * Adam de Boor.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#ifndef MAKE_NATIVE
static char rcsid[] = "$NetBSD: lstInit.c,v 1.1 2005/10/31 21:52:26 reed Exp $";
#else
#include <sys/cdefs.h>
#ifndef lint
#if 0
static char sccsid[] = "@(#)lstInit.c	8.1 (Berkeley) 6/6/93";
#else
__RCSID("$NetBSD: lstInit.c,v 1.1 2005/10/31 21:52:26 reed Exp $");
#endif
#endif /* not lint */
#endif

/*-
 * init.c --
 *	Initialize a new linked list.
 */

#include	"lstInt.h"

/*-
 *-----------------------------------------------------------------------
 * Lst_Init --
 *	Create and initialize a new list.
 *
 * Input:
 *	circ		TRUE if the list should be made circular
 *
 * Results:
 *	The created list.
 *
 * Side Effects:
 *	A list is created, what else?
 *
 *-----------------------------------------------------------------------
 */
Lst
Lst_Init(Boolean circ)
{
    List	nList;

    PAlloc (nList, List);

    nList->firstPtr = NilListNode;
    nList->lastPtr = NilListNode;
    nList->isOpen = FALSE;
    nList->isCirc = circ;
    nList->atEnd = Unknown;

    return ((Lst)nList);
}
