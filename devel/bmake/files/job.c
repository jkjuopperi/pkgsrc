/*	$NetBSD: job.c,v 1.1.1.1 2005/12/02 00:03:00 sjg Exp $	*/

/*
 * Copyright (c) 1988, 1989, 1990 The Regents of the University of California.
 * All rights reserved.
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

/*
 * Copyright (c) 1988, 1989 by Adam de Boor
 * Copyright (c) 1989 by Berkeley Softworks
 * All rights reserved.
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
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
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
static char rcsid[] = "$NetBSD: job.c,v 1.1.1.1 2005/12/02 00:03:00 sjg Exp $";
#else
#include <sys/cdefs.h>
#ifndef lint
#if 0
static char sccsid[] = "@(#)job.c	8.2 (Berkeley) 3/19/94";
#else
__RCSID("$NetBSD: job.c,v 1.1.1.1 2005/12/02 00:03:00 sjg Exp $");
#endif
#endif /* not lint */
#endif

/*-
 * job.c --
 *	handle the creation etc. of our child processes.
 *
 * Interface:
 *	Job_Make  	    	Start the creation of the given target.
 *
 *	Job_CatchChildren   	Check for and handle the termination of any
 *	    	  	    	children. This must be called reasonably
 *	    	  	    	frequently to keep the whole make going at
 *	    	  	    	a decent clip, since job table entries aren't
 *	    	  	    	removed until their process is caught this way.
 *	    	  	    	Its single argument is TRUE if the function
 *	    	  	    	should block waiting for a child to terminate.
 *
 *	Job_CatchOutput	    	Print any output our children have produced.
 *	    	  	    	Should also be called fairly frequently to
 *	    	  	    	keep the user informed of what's going on.
 *	    	  	    	If no output is waiting, it will block for
 *	    	  	    	a time given by the SEL_* constants, below,
 *	    	  	    	or until output is ready.
 *
 *	Job_Init  	    	Called to intialize this module. in addition,
 *	    	  	    	any commands attached to the .BEGIN target
 *	    	  	    	are executed before this function returns.
 *	    	  	    	Hence, the makefile must have been parsed
 *	    	  	    	before this function is called.
 *
 *	Job_End  	    	Cleanup any memory used.
 *
 *	Job_Empty 	    	Return TRUE if the job table is completely
 *	    	  	    	empty.
 *
 *	Job_ParseShell	    	Given the line following a .SHELL target, parse
 *	    	  	    	the line as a shell specification. Returns
 *	    	  	    	FAILURE if the spec was incorrect.
 *
 *	Job_Finish	    	Perform any final processing which needs doing.
 *	    	  	    	This includes the execution of any commands
 *	    	  	    	which have been/were attached to the .END
 *	    	  	    	target. It should only be called when the
 *	    	  	    	job table is empty.
 *
 *	Job_AbortAll	    	Abort all currently running jobs. It doesn't
 *	    	  	    	handle output or do anything for the jobs,
 *	    	  	    	just kills them. It should only be called in
 *	    	  	    	an emergency, as it were.
 *
 *	Job_CheckCommands   	Verify that the commands for a target are
 *	    	  	    	ok. Provide them if necessary and possible.
 *
 *	Job_Touch 	    	Update a target without really updating it.
 *
 *	Job_Wait  	    	Wait for all currently-running jobs to finish.
 */

#ifdef HAVE_CONFIG_H
# include "config.h"
#endif
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/file.h>
#include <sys/time.h>
#include "wait.h"

#include <errno.h>
#include <fcntl.h>
#ifndef RMT_WILL_WATCH
#if !defined(USE_SELECT) && defined(HAVE_POLL_H)
#include <poll.h>
#else
#ifndef USE_SELECT			/* no poll.h */
# define USE_SELECT
#endif
#if defined(HAVE_SYS_SELECT_H)
# include <sys/select.h>
#endif
#endif
#endif
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <utime.h>
#if defined(HAVE_SYS_SOCKET_H)
# include <sys/socket.h>
#endif

#include "make.h"
#include "hash.h"
#include "dir.h"
#include "job.h"
#include "pathnames.h"
#include "trace.h"
#ifdef REMOTE
#include "rmt.h"
# define STATIC
#else
# define STATIC static
#endif

/*
 * error handling variables
 */
static int     	errors = 0;	    /* number of errors reported */
static int    	aborting = 0;	    /* why is the make aborting? */
#define ABORT_ERROR	1   	    /* Because of an error */
#define ABORT_INTERRUPT	2   	    /* Because it was interrupted */
#define ABORT_WAIT	3   	    /* Waiting for jobs to finish */

/*
 * XXX: Avoid SunOS bug... FILENO() is fp->_file, and file
 * is a char! So when we go above 127 we turn negative!
 */
#define FILENO(a) ((unsigned) fileno(a))

/*
 * post-make command processing. The node postCommands is really just the
 * .END target but we keep it around to avoid having to search for it
 * all the time.
 */
static GNode   	  *postCommands = NILGNODE;
				    /* node containing commands to execute when
				     * everything else is done */
static int     	  numCommands; 	    /* The number of commands actually printed
				     * for a target. Should this number be
				     * 0, no shell will be executed. */

/*
 * Return values from JobStart.
 */
#define JOB_RUNNING	0   	/* Job is running */
#define JOB_ERROR 	1   	/* Error in starting the job */
#define JOB_FINISHED	2   	/* The job is already finished */
#define JOB_STOPPED	3   	/* The job is stopped */



/*
 * Descriptions for various shells.
 */
static Shell    shells[] = {
    /*
     * CSH description. The csh can do echo control by playing
     * with the setting of the 'echo' shell variable. Sadly,
     * however, it is unable to do error control nicely.
     */
{
    "csh",
    TRUE, "unset verbose", "set verbose", "unset verbose", 10,
    FALSE, "echo \"%s\"\n", "csh -c \"%s || exit 0\"\n", "", '#',
    "v", "e",
},
    /*
     * SH description. Echo control is also possible and, under
     * sun UNIX anyway, one can even control error checking.
     */
{
    "sh",
    FALSE, "", "", "", 0,
    FALSE, "echo \"%s\"\n", "%s\n", "{ %s \n} || exit $?\n", '#',
#ifdef __NetBSD__
    "q",
#else
    "",
#endif
    "",
},
    /*
     * KSH description. 
     */
{
    "ksh",
    TRUE, "set +v", "set -v", "set +v", 6,
    FALSE, "echo \"%s\"\n", "%s\n", "{ %s \n} || exit $?\n", '#',
    "v",
    "",
},
    /*
     * UNKNOWN.
     */
{
    NULL,
    FALSE, NULL, NULL, NULL, 0,
    FALSE, NULL, NULL, NULL, 0,
    NULL, NULL,
}
};
static Shell 	*commandShell = &shells[DEFSHELL];/* this is the shell to
						   * which we pass all
						   * commands in the Makefile.
						   * It is set by the
						   * Job_ParseShell function */
const char *shellPath = NULL,		  	  /* full pathname of
						   * executable image */
           *shellName = NULL;		      	  /* last component of shell */
static const char *shellArgv = NULL;		  /* Custom shell args */


static int  	maxJobs;    	/* The most children we can run at once */
static int  	maxLocal;    	/* The most local ones we can have */
STATIC int     	nJobs;	    	/* The number of children currently running */
STATIC int	nLocal;    	/* The number of local children */
STATIC Lst     	jobs;		/* The structures that describe them */
static Boolean	wantToken;	/* we want a token */

/*
 * Set of descriptors of pipes connected to
 * the output channels of children
 */
#ifndef RMT_WILL_WATCH
static struct pollfd *fds = NULL;
static Job **jobfds = NULL;
static int nfds = 0;
static int maxfds = 0;
static void watchfd(Job *);
static void clearfd(Job *);
static int readyfd(Job *);
#define JBSTART 256
#define JBFACTOR 2
#endif

STATIC GNode   	*lastNode;	/* The node for which output was most recently
				 * produced. */
STATIC const char *targFmt;   	/* Format string to use to head output from a
				 * job when it's not the most-recent job heard
				 * from */
static Job tokenWaitJob;	/* token wait pseudo-job */
int	job_pipe[2] = { -1, -1 }; /* job server pipes. */

static Job childExitJob;	/* child exit pseudo-job */
int	exit_pipe[2] = { -1, -1 }; /* child exit signal pipe. */

#ifdef REMOTE
# define TARG_FMT  "--- %s at %s ---\n" /* Default format */
# define MESSAGE(fp, gn) \
	(void)fprintf(fp, targFmt, gn->name, gn->rem.hname)
#else
# define TARG_FMT  "--- %s ---\n" /* Default format */
# define MESSAGE(fp, gn) \
	(void)fprintf(fp, targFmt, gn->name)
#endif

/*
 * When JobStart attempts to run a job remotely but can't, and isn't allowed
 * to run the job locally, or when Job_CatchChildren detects a job that has
 * been migrated home, the job is placed on the stoppedJobs queue to be run
 * when the next job finishes.
 */
STATIC Lst	stoppedJobs;	/* Lst of Job structures describing
				 * jobs that were stopped due to concurrency
				 * limits or migration home */


sigset_t	caught_signals;	/* Set of signals we handle */

#if defined(USE_PGRP)
# if defined(HAVE_KILLPG)
#  define KILL(pid, sig)	killpg((pid), (sig))
# else
#  define KILL(pid, sig)	kill(-(pid), (sig))
# endif
#else
# define KILL(pid, sig)		kill((pid), (sig))
#endif

/*
 * Grmpf... There is no way to set bits of the wait structure
 * anymore with the stupid W*() macros. I liked the union wait
 * stuff much more. So, we devise our own macros... This is
 * really ugly, use dramamine sparingly. You have been warned.
 */
#ifndef W_STOPCODE
#define W_STOPCODE(sig) (((sig) << 8) | 0177)
#endif
#ifndef W_EXITCODE
#define W_EXITCODE(ret, sig) ((ret << 8) | (sig))
#endif 

static int JobCondPassSig(ClientData, ClientData);
static void JobPassSig(int);
static void JobChildSig(int);
#ifdef USE_PGRP
static void JobContinueSig(int);
#endif
static int JobCmpPid(ClientData, ClientData);
static int JobPrintCommand(ClientData, ClientData);
static int JobSaveCommand(ClientData, ClientData);
static void JobClose(Job *);
#ifdef REMOTE
static int JobCmpRmtID(ClientData, ClientData);
# ifdef RMT_WILL_WATCH
static void JobLocalInput(int, Job *);
# endif
#else
static void JobFinish(Job *, WAIT_T);
static void JobExec(Job *, char **);
#endif
static void JobMakeArgv(Job *, char **);
static int JobRestart(Job *);
static int JobStart(GNode *, int, Job *);
static char *JobOutput(Job *, char *, char *, int);
static void JobDoOutput(Job *, Boolean);
static Shell *JobMatchShell(const char *);
static void JobInterrupt(int, int);
static void JobRestartJobs(void);
static void JobTokenAdd(void);
static void JobSigLock(sigset_t *);
static void JobSigUnlock(sigset_t *);
static void JobSigReset(void);



/*
 * JobSigLock/JobSigUnlock
 *
 * Signal lock routines to get exclusive access. Currently used to
 * protect `jobs' and `stoppedJobs' list manipulations.
 */
static void JobSigLock(sigset_t *omaskp)
{
	if (sigprocmask(SIG_BLOCK, &caught_signals, omaskp) != 0) {
		Punt("JobSigLock: sigprocmask: %s", strerror(errno));
	sigemptyset(omaskp);
	}
}

static void JobSigUnlock(sigset_t *omaskp)
{
	(void)sigprocmask(SIG_SETMASK, omaskp, NULL);
}

/*-
 *-----------------------------------------------------------------------
 * JobCondPassSig --
 *	Pass a signal to a job if the job is remote or if USE_PGRP
 *	is defined.
 *
 * Input:
 *	jobp		Job to biff
 *	signop		Signal to send it
 *
 * Results:
 *	=== 0
 *
 * Side Effects:
 *	None, except the job may bite it.
 *
 *-----------------------------------------------------------------------
 */
static int
JobCondPassSig(ClientData jobp, ClientData signop)
{
    Job	*job = (Job *)jobp;
    int	signo = *(int *)signop;
#ifdef RMT_WANTS_SIGNALS
    if (job->flags & JOB_REMOTE) {
	(void)Rmt_Signal(job, signo);
    } else {
	KILL(job->pid, signo);
    }
#else
    /*
     * Assume that sending the signal to job->pid will signal any remote
     * job as well.
     */
    if (DEBUG(JOB)) {
	(void)fprintf(stdout,
		       "JobCondPassSig passing signal %d to child %d.\n",
		       signo, job->pid);
	(void)fflush(stdout);
    }
    KILL(job->pid, signo);
#endif
    return 0;
}

/*-
 *-----------------------------------------------------------------------
 * JobChldSig --
 *	SIGCHLD handler.
 *
 * Input:
 *	signo		The signal number we've received
 *
 * Results:
 *	None.
 *
 * Side Effects:
 *	Sends a token on the child exit pipe to wake us up from
 *	select()/poll().
 *
 *-----------------------------------------------------------------------
 */
static void
JobChildSig(int signo __unused)
{
    write(exit_pipe[1], ".", 1);
}


#ifdef USE_PGRP
/*-
 *-----------------------------------------------------------------------
 * JobContinueSig --
 *	Resume all stopped jobs.
 *
 * Input:
 *	signo		The signal number we've received
 *
 * Results:
 *	None.
 *
 * Side Effects:
 *	Jobs start running again.
 *
 *-----------------------------------------------------------------------
 */
static void
JobContinueSig(int signo __unused)
{
    JobRestartJobs();
}
#endif

/*-
 *-----------------------------------------------------------------------
 * JobPassSig --
 *	Pass a signal on to all remote jobs and to all local jobs if
 *	USE_PGRP is defined, then die ourselves.
 *
 * Input:
 *	signo		The signal number we've received
 *
 * Results:
 *	None.
 *
 * Side Effects:
 *	We die by the same signal.
 *
 *-----------------------------------------------------------------------
 */
static void
JobPassSig(int signo)
{
    sigset_t nmask, omask;
    struct sigaction act;
    int sigcont;

    if (DEBUG(JOB)) {
	(void)fprintf(stdout, "JobPassSig(%d) called.\n", signo);
	(void)fflush(stdout);
    }
    Lst_ForEach(jobs, JobCondPassSig, (ClientData) &signo);

    /*
     * Deal with proper cleanup based on the signal received. We only run
     * the .INTERRUPT target if the signal was in fact an interrupt. The other
     * three termination signals are more of a "get out *now*" command.
     */
    if (signo == SIGINT) {
	JobInterrupt(TRUE, signo);
    } else if ((signo == SIGHUP) || (signo == SIGTERM) || (signo == SIGQUIT)) {
	JobInterrupt(FALSE, signo);
    }

    /*
     * Leave gracefully if SIGQUIT, rather than core dumping.
     */
    if (signo == SIGQUIT) {
	Finish(0);
    }

    if (signo == SIGTSTP) {
	Job_CatchChildren(FALSE);
    }
    /*
     * Send ourselves the signal now we've given the message to everyone else.
     * Note we block everything else possible while we're getting the signal.
     * This ensures that all our jobs get continued when we wake up before
     * we take any other signal.
     */
    sigfillset(&nmask);
    sigdelset(&nmask, signo);
    (void)sigprocmask(SIG_SETMASK, &nmask, &omask);

    act.sa_handler = SIG_DFL;
    sigemptyset(&act.sa_mask);
    act.sa_flags = 0;
    (void)sigaction(signo, &act, NULL);

    if (DEBUG(JOB)) {
	(void)fprintf(stdout,
		       "JobPassSig passing signal %d to self.\n", signo);
	(void)fflush(stdout);
    }

    (void)kill(getpid(), signo);
    if (signo != SIGTSTP) {
	sigcont = SIGCONT;
	Lst_ForEach(jobs, JobCondPassSig, (ClientData) &sigcont);
    }

    /* Restore handler and signal mask */
    act.sa_handler = JobPassSig;
    (void)sigaction(signo, &act, NULL);
    (void)sigprocmask(SIG_SETMASK, &omask, NULL);
}

/*-
 *-----------------------------------------------------------------------
 * JobCmpPid  --
 *	Compare the pid of the job with the given pid and return 0 if they
 *	are equal. This function is called from Job_CatchChildren via
 *	Lst_Find to find the job descriptor of the finished job.
 *
 * Input:
 *	job		job to examine
 *	pid		process id desired
 *
 * Results:
 *	0 if the pid's match
 *
 * Side Effects:
 *	None
 *-----------------------------------------------------------------------
 */
static int
JobCmpPid(ClientData job, ClientData pid)
{
    return *(int *)pid - ((Job *)job)->pid;
}

#ifdef REMOTE
/*-
 *-----------------------------------------------------------------------
 * JobCmpRmtID  --
 *	Compare the rmtID of the job with the given rmtID and return 0 if they
 *	are equal.
 *
 * Input:
 *	job		job to examine
 *	rmtID		remote id desired
 *
 * Results:
 *	0 if the rmtID's match
 *
 * Side Effects:
 *	None.
 *-----------------------------------------------------------------------
 */
static int
JobCmpRmtID(ClientData job, ClientData rmtID)
{
    return(*(int *)rmtID - ((Job *)job)->rmtID);
}
#endif

/*-
 *-----------------------------------------------------------------------
 * JobPrintCommand  --
 *	Put out another command for the given job. If the command starts
 *	with an @ or a - we process it specially. In the former case,
 *	so long as the -s and -n flags weren't given to make, we stick
 *	a shell-specific echoOff command in the script. In the latter,
 *	we ignore errors for the entire job, unless the shell has error
 *	control.
 *	If the command is just "..." we take all future commands for this
 *	job to be commands to be executed once the entire graph has been
 *	made and return non-zero to signal that the end of the commands
 *	was reached. These commands are later attached to the postCommands
 *	node and executed by Job_End when all things are done.
 *	This function is called from JobStart via Lst_ForEach.
 *
 * Input:
 *	cmdp		command string to print
 *	jobp		job for which to print it
 *
 * Results:
 *	Always 0, unless the command was "..."
 *
 * Side Effects:
 *	If the command begins with a '-' and the shell has no error control,
 *	the JOB_IGNERR flag is set in the job descriptor.
 *	If the command is "..." and we're not ignoring such things,
 *	tailCmds is set to the successor node of the cmd.
 *	numCommands is incremented if the command is actually printed.
 *-----------------------------------------------------------------------
 */
static int
JobPrintCommand(ClientData cmdp, ClientData jobp)
{
    Boolean	  noSpecials;	    /* true if we shouldn't worry about
				     * inserting special commands into
				     * the input stream. */
    Boolean       shutUp = FALSE;   /* true if we put a no echo command
				     * into the command file */
    Boolean	  errOff = FALSE;   /* true if we turned error checking
				     * off before printing the command
				     * and need to turn it back on */
    const char    *cmdTemplate;	    /* Template to use when printing the
				     * command */
    char    	  *cmdStart;	    /* Start of expanded command */
    char	  *escCmd = NULL;    /* Command with quotes/backticks escaped */
    char     	  *cmd = (char *)cmdp;
    Job           *job = (Job *)jobp;
    char	  *cp, *tmp;
    int           i, j;

    noSpecials = NoExecute(job->node);

    if (strcmp(cmd, "...") == 0) {
	job->node->type |= OP_SAVE_CMDS;
	if ((job->flags & JOB_IGNDOTS) == 0) {
	    job->tailCmds = Lst_Succ(Lst_Member(job->node->commands,
						(ClientData)cmd));
	    return 1;
	}
	return 0;
    }

#define DBPRINTF(fmt, arg) if (DEBUG(JOB)) {	\
	(void)fprintf(stdout, fmt, arg); 	\
	(void)fflush(stdout); 			\
    }						\
   (void)fprintf(job->cmdFILE, fmt, arg);	\
   (void)fflush(job->cmdFILE);

    numCommands += 1;

    cmdStart = cmd = Var_Subst(NULL, cmd, job->node, FALSE);

    cmdTemplate = "%s\n";

    /*
     * Check for leading @' and -'s to control echoing and error checking.
     */
    while (*cmd == '@' || *cmd == '-' || (*cmd == '+')) {
	switch (*cmd) {
	case '@':
	    shutUp = TRUE;
	    break;
	case '-':
	    errOff = TRUE;
	    break;
	case '+':
	    if (noSpecials) {
		/*
		 * We're not actually executing anything...
		 * but this one needs to be - use compat mode just for it.
		 */
		CompatRunCommand(cmdp, (ClientData)job->node);
		return 0;
	    }
	    break;
	}
	cmd++;
    }

    while (isspace((unsigned char) *cmd))
	cmd++;

    /*
     * If the shell doesn't have error control the alternate echo'ing will
     * be done (to avoid showing additional error checking code) 
     * and this will need the characters '$ ` \ "' escaped
     */

    if (!commandShell->hasErrCtl) {
	/* Worst that could happen is every char needs escaping. */
	escCmd = emalloc((strlen(cmd) * 2) + 1);
	for (i = 0, j= 0; cmd[i] != '\0'; i++, j++) {
		if (cmd[i] == '$' || cmd[i] == '`' || cmd[i] == '\\' || 
			cmd[i] == '"')
			escCmd[j++] = '\\';
		escCmd[j] = cmd[i];	
	}
	escCmd[j] = 0;
    }

    if (shutUp) {
	if (!(job->flags & JOB_SILENT) && !noSpecials &&
	    commandShell->hasEchoCtl) {
		DBPRINTF("%s\n", commandShell->echoOff);
	} else {
	    if (commandShell->hasErrCtl)
		shutUp = FALSE;
	}
    }

    if (errOff) {
	if ( !(job->flags & JOB_IGNERR) && !noSpecials) {
	    if (commandShell->hasErrCtl) {
		/*
		 * we don't want the error-control commands showing
		 * up either, so we turn off echoing while executing
		 * them. We could put another field in the shell
		 * structure to tell JobDoOutput to look for this
		 * string too, but why make it any more complex than
		 * it already is?
		 */
		if (!(job->flags & JOB_SILENT) && !shutUp &&
		    commandShell->hasEchoCtl) {
			DBPRINTF("%s\n", commandShell->echoOff);
			DBPRINTF("%s\n", commandShell->ignErr);
			DBPRINTF("%s\n", commandShell->echoOn);
		} else {
			DBPRINTF("%s\n", commandShell->ignErr);
		}
	    } else if (commandShell->ignErr &&
		      (*commandShell->ignErr != '\0'))
	    {
		/*
		 * The shell has no error control, so we need to be
		 * weird to get it to ignore any errors from the command.
		 * If echoing is turned on, we turn it off and use the
		 * errCheck template to echo the command. Leave echoing
		 * off so the user doesn't see the weirdness we go through
		 * to ignore errors. Set cmdTemplate to use the weirdness
		 * instead of the simple "%s\n" template.
		 */
		if (!(job->flags & JOB_SILENT) && !shutUp) {
			if (commandShell->hasEchoCtl) {
				DBPRINTF("%s\n", commandShell->echoOff);
			}
			DBPRINTF(commandShell->errCheck, escCmd);
			shutUp = TRUE;
		} else {
			if (!shutUp) {
				DBPRINTF(commandShell->errCheck, escCmd);
			}
		}
		cmdTemplate = commandShell->ignErr;
		/*
		 * The error ignoration (hee hee) is already taken care
		 * of by the ignErr template, so pretend error checking
		 * is still on.
		 */
		errOff = FALSE;
	    } else {
		errOff = FALSE;
	    }
	} else {
	    errOff = FALSE;
	}
    } else {

	/* 
	 * If errors are being checked and the shell doesn't have error control
	 * but does supply an errOut template, then setup commands to run
	 * through it.
	 */

	if (!commandShell->hasErrCtl && commandShell->errOut && 
	    (*commandShell->errOut != '\0')) {
		if (!(job->flags & JOB_SILENT) && !shutUp) {
			if (commandShell->hasEchoCtl) {
				DBPRINTF("%s\n", commandShell->echoOff);
			}
			DBPRINTF(commandShell->errCheck, escCmd);
			shutUp = TRUE;
		}
		/* If it's a comment line or blank, treat as an ignored error */
		if ((escCmd[0] == commandShell->commentChar) ||
		    (escCmd[0] == 0))
			cmdTemplate = commandShell->ignErr;
		else
			cmdTemplate = commandShell->errOut;
		errOff = FALSE;
	}
    }

    if (DEBUG(SHELL) && strcmp(shellName, "sh") == 0 &&
	(job->flags & JOB_TRACED) == 0) {
	    DBPRINTF("set -%s\n", "x");
	    job->flags |= JOB_TRACED;
    }
    
    if ((cp = Check_Cwd_Cmd(cmd)) != NULL) {
	    DBPRINTF("test -d %s && ", cp);
	    DBPRINTF("cd %s\n", cp);
    }

    DBPRINTF(cmdTemplate, cmd);
    free(cmdStart);
    if (escCmd)
        free(escCmd);
    if (errOff) {
	/*
	 * If echoing is already off, there's no point in issuing the
	 * echoOff command. Otherwise we issue it and pretend it was on
	 * for the whole command...
	 */
	if (!shutUp && !(job->flags & JOB_SILENT) && commandShell->hasEchoCtl){
	    DBPRINTF("%s\n", commandShell->echoOff);
	    shutUp = TRUE;
	}
	DBPRINTF("%s\n", commandShell->errCheck);
    }
    if (shutUp && commandShell->hasEchoCtl) {
	DBPRINTF("%s\n", commandShell->echoOn);
    }
    if (cp != NULL) {
	    DBPRINTF("test -d %s && ", cp);
	    DBPRINTF("cd %s\n", Var_Value(".OBJDIR", VAR_GLOBAL, &tmp));
    }
    return 0;
}

/*-
 *-----------------------------------------------------------------------
 * JobSaveCommand --
 *	Save a command to be executed when everything else is done.
 *	Callback function for JobFinish...
 *
 * Results:
 *	Always returns 0
 *
 * Side Effects:
 *	The command is tacked onto the end of postCommands's commands list.
 *
 *-----------------------------------------------------------------------
 */
static int
JobSaveCommand(ClientData cmd, ClientData gn)
{
    cmd = (ClientData)Var_Subst(NULL, (char *)cmd, (GNode *)gn, FALSE);
    (void)Lst_AtEnd(postCommands->commands, cmd);
    return(0);
}


/*-
 *-----------------------------------------------------------------------
 * JobClose --
 *	Called to close both input and output pipes when a job is finished.
 *
 * Results:
 *	Nada
 *
 * Side Effects:
 *	The file descriptors associated with the job are closed.
 *
 *-----------------------------------------------------------------------
 */
static void
JobClose(Job *job)
{
    if (usePipes && (job->flags & JOB_FIRST)) {
#ifdef RMT_WILL_WATCH
	Rmt_Ignore(job->inPipe);
#else
	clearfd(job);
#endif
	if (job->outPipe != job->inPipe) {
	   (void)close(job->outPipe);
	}
	JobDoOutput(job, TRUE);
	(void)close(job->inPipe);
    } else {
	(void)close(job->outFd);
	JobDoOutput(job, TRUE);
    }
}

/*-
 *-----------------------------------------------------------------------
 * JobFinish  --
 *	Do final processing for the given job including updating
 *	parents and starting new jobs as available/necessary. Note
 *	that we pay no attention to the JOB_IGNERR flag here.
 *	This is because when we're called because of a noexecute flag
 *	or something, jstat.w_status is 0 and when called from
 *	Job_CatchChildren, the status is zeroed if it s/b ignored.
 *
 * Input:
 *	job		job to finish
 *	status		sub-why job went away
 *
 * Results:
 *	None
 *
 * Side Effects:
 *	Final commands for the job are placed on postCommands.
 *
 *	If we got an error and are aborting (aborting == ABORT_ERROR) and
 *	the job list is now empty, we are done for the day.
 *	If we recognized an error (errors !=0), we set the aborting flag
 *	to ABORT_ERROR so no more jobs will be started.
 *-----------------------------------------------------------------------
 */
/*ARGSUSED*/
static void
JobFinish (Job *job, WAIT_T status)
{
    Boolean 	  done;

    if ((WIFEXITED(status) &&
	  (((WEXITSTATUS(status) != 0) && !(job->flags & JOB_IGNERR)))) ||
	WIFSIGNALED(status))
    {
	/*
	 * If it exited non-zero and either we're doing things our
	 * way or we're not ignoring errors, the job is finished.
	 * Similarly, if the shell died because of a signal
	 * the job is also finished. In these
	 * cases, finish out the job's output before printing the exit
	 * status...
	 */
#ifdef REMOTE
	KILL(job->pid, SIGCONT);
#endif
	JobClose(job);
	if (job->cmdFILE != NULL && job->cmdFILE != stdout) {
	   (void)fclose(job->cmdFILE);
	   job->cmdFILE = NULL;
	}
	done = TRUE;
#ifdef REMOTE
	if (job->flags & JOB_REMOTE)
	    Rmt_Done(job->rmtID, job->node);
#endif
    } else if (WIFEXITED(status)) {
	/*
	 * Deal with ignored errors in -B mode. We need to print a message
	 * telling of the ignored error as well as setting status.w_status
	 * to 0 so the next command gets run. To do this, we set done to be
	 * TRUE if in -B mode and the job exited non-zero.
	 */
	done = WEXITSTATUS(status) != 0;
	/*
	 * Old comment said: "Note we don't
	 * want to close down any of the streams until we know we're at the
	 * end."
	 * But we do. Otherwise when are we going to print the rest of the
	 * stuff?
	 */
	JobClose(job);
#ifdef REMOTE
	if (job->flags & JOB_REMOTE)
	    Rmt_Done(job->rmtID, job->node);
#endif /* REMOTE */
    } else {
	/*
	 * No need to close things down or anything.
	 */
	done = FALSE;
    }

    if (done ||
	WIFSTOPPED(status) ||
	(WIFSIGNALED(status) && (WTERMSIG(status) == SIGCONT)))
    {
	FILE	  *out;

	if (compatMake && !usePipes && (job->flags & JOB_IGNERR)) {
	    /*
	     * If output is going to a file and this job is ignoring
	     * errors, arrange to have the exit status sent to the
	     * output file as well.
	     */
	    out = fdopen(job->outFd, "w");
	    if (out == NULL)
		Punt("Cannot fdopen");
	} else {
	    out = stdout;
	}

	if (WIFEXITED(status)) {
	    if (DEBUG(JOB)) {
		(void)fprintf(stdout, "Process %d [%s] exited.\n",
				job->pid, job->node->name);
		(void)fflush(stdout);
	    }
	    if (WEXITSTATUS(status) != 0) {
		if (usePipes && job->node != lastNode) {
		    MESSAGE(out, job->node);
		    lastNode = job->node;
		}
		(void)fprintf(out, "*** [%s] Error code %d%s\n",
				job->node->name,
			       WEXITSTATUS(status),
			       (job->flags & JOB_IGNERR) ? "(ignored)" : "");

		if (job->flags & JOB_IGNERR) {
		    WAIT_STATUS(status) = 0;
		}
	    } else if (DEBUG(JOB)) {
		if (usePipes && job->node != lastNode) {
		    MESSAGE(out, job->node);
		    lastNode = job->node;
		}
		(void)fprintf(out, "*** [%s] Completed successfully\n",
				job->node->name);
	    }
	} else if (WIFSTOPPED(status) && WSTOPSIG(status) != SIGCONT) {
	    if (DEBUG(JOB)) {
		(void)fprintf(stdout, "Process %d (%s) stopped.\n",
				job->pid, job->node->name);
		(void)fflush(stdout);
	    }
	    if (usePipes && job->node != lastNode) {
		MESSAGE(out, job->node);
		lastNode = job->node;
	    }
	    if (!(job->flags & JOB_REMIGRATE)) {
		switch (WSTOPSIG(status)) {
		case SIGTSTP:
		    (void)fprintf(out, "*** [%s] Suspended\n",
				job->node->name);
		    break;
		case SIGSTOP:
		    (void)fprintf(out, "*** [%s] Stopped\n",
				job->node->name);
		    break;
		default:
		    (void)fprintf(out, "*** [%s] Stopped -- signal %d\n",
			job->node->name, WSTOPSIG(status));
		}
	    }
	    job->flags |= JOB_RESUME;
	    (void)Lst_AtEnd(stoppedJobs, (ClientData)job);
#ifdef REMOTE
	    if (job->flags & JOB_REMIGRATE)
		JobRestart(job);
#endif
	    (void)fflush(out);
	    return;
	} else if (WIFSTOPPED(status) &&  WSTOPSIG(status) == SIGCONT) {
	    /*
	     * If the beastie has continued, shift the Job from the stopped
	     * list to the running one (or re-stop it if concurrency is
	     * exceeded) and go and get another child.
	     */
	    if (job->flags & (JOB_RESUME|JOB_REMIGRATE|JOB_RESTART)) {
		if (usePipes && job->node != lastNode) {
		    MESSAGE(out, job->node);
		    lastNode = job->node;
		}
		(void)fprintf(out, "*** [%s] Continued\n", job->node->name);
	    }
	    if (!(job->flags & JOB_CONTINUING)) {
		if (DEBUG(JOB)) {
		    (void)fprintf(stdout,
			   "Warning: process %d [%s] was not continuing.\n",
			   job->pid, job->node->name);
		    (void)fflush(stdout);
		}
#ifdef notdef
		/*
		 * We don't really want to restart a job from scratch just
		 * because it continued, especially not without killing the
		 * continuing process!  That's why this is ifdef'ed out.
		 * FD - 9/17/90
		 */
		JobRestart(job);
#endif
	    }
	    job->flags &= ~JOB_CONTINUING;
 	    Lst_AtEnd(jobs, (ClientData)job);
	    nJobs += 1;
	    if (!(job->flags & JOB_REMOTE)) {
		if (DEBUG(JOB)) {
		    (void)fprintf(stdout,
				   "Process %d is continuing locally.\n",
				   job->pid);
		    (void)fflush(stdout);
  		}
		nLocal += 1;
	    }
	    (void)fflush(out);
  	    return;
	} else {
	    if (usePipes && job->node != lastNode) {
		MESSAGE(out, job->node);
		lastNode = job->node;
	    }
	    (void)fprintf(out, "*** [%s] Signal %d\n",
			job->node->name, WTERMSIG(status));
	}

	(void)fflush(out);
    }

    /*
     * Now handle the -B-mode stuff. If the beast still isn't finished,
     * try and restart the job on the next command. If JobStart says it's
     * ok, it's ok. If there's an error, this puppy is done.
     */
    if (compatMake && (WIFEXITED(status) &&
	!Lst_IsAtEnd(job->node->commands))) {
	switch (JobStart(job->node, job->flags & JOB_IGNDOTS, job)) {
	case JOB_RUNNING:
	    done = FALSE;
	    break;
	case JOB_ERROR:
	    done = TRUE;
	    WSET_EXITCODE(status, 1, 0);
	    break;
	case JOB_FINISHED:
	    /*
	     * If we got back a JOB_FINISHED code, JobStart has already
	     * called Make_Update and freed the job descriptor. We set
	     * done to false here to avoid fake cycles and double frees.
	     * JobStart needs to do the update so we can proceed up the
	     * graph when given the -n flag..
	     */
	    done = FALSE;
	    break;
	}
    } else {
	done = TRUE;
    }

    if (done) {
	Trace_Log(JOBEND, job);
	if (!compatMake && !(job->flags & JOB_SPECIAL)) {
	    if ((WAIT_STATUS(status) != 0) ||
	        (aborting == ABORT_ERROR) ||
	        (aborting == ABORT_INTERRUPT))
		Job_TokenReturn();
	}
	
    }

    if (done &&
	(aborting != ABORT_ERROR) &&
	(aborting != ABORT_INTERRUPT) &&
	(WAIT_STATUS(status) == 0))
    {
	/*
	 * As long as we aren't aborting and the job didn't return a non-zero
	 * status that we shouldn't ignore, we call Make_Update to update
	 * the parents. In addition, any saved commands for the node are placed
	 * on the .END target.
	 */
	if (job->tailCmds != NILLNODE) {
	    Lst_ForEachFrom(job->node->commands, job->tailCmds,
			     JobSaveCommand,
			    (ClientData)job->node);
	}
	job->node->made = MADE;
	if (!(job->flags & JOB_SPECIAL))
	    Job_TokenReturn();
	Make_Update(job->node);
	free(job);
    } else if (WAIT_STATUS(status)) {
	errors += 1;
	free(job);
    }
    JobRestartJobs();

    /*
     * Set aborting if any error.
     */
    if (errors && !keepgoing && (aborting != ABORT_INTERRUPT)) {
	/*
	 * If we found any errors in this batch of children and the -k flag
	 * wasn't given, we set the aborting flag so no more jobs get
	 * started.
	 */
	aborting = ABORT_ERROR;
    }

    if ((aborting == ABORT_ERROR) && Job_Empty()) {
	/*
	 * If we are aborting and the job table is now empty, we finish.
	 */
	Finish(errors);
    }
}

/*-
 *-----------------------------------------------------------------------
 * Job_Touch --
 *	Touch the given target. Called by JobStart when the -t flag was
 *	given
 *
 * Input:
 *	gn		the node of the file to touch
 *	silent		TRUE if should not print message
 *
 * Results:
 *	None
 *
 * Side Effects:
 *	The data modification of the file is changed. In addition, if the
 *	file did not exist, it is created.
 *-----------------------------------------------------------------------
 */
void
Job_Touch(GNode *gn, Boolean silent)
{
    int		  streamID;   	/* ID of stream opened to do the touch */
    struct utimbuf times;	/* Times for utime() call */

    if (gn->type & (OP_JOIN|OP_USE|OP_USEBEFORE|OP_EXEC|OP_OPTIONAL|OP_PHONY)) {
	/*
	 * .JOIN, .USE, .ZEROTIME and .OPTIONAL targets are "virtual" targets
	 * and, as such, shouldn't really be created.
	 */
	return;
    }

    if (!silent || NoExecute(gn)) {
	(void)fprintf(stdout, "touch %s\n", gn->name);
	(void)fflush(stdout);
    }

    if (NoExecute(gn)) {
	return;
    }

    if (gn->type & OP_ARCHV) {
	Arch_Touch(gn);
    } else if (gn->type & OP_LIB) {
	Arch_TouchLib(gn);
    } else {
	char	*file = gn->path ? gn->path : gn->name;

	times.actime = times.modtime = now;
	if (utime(file, &times) < 0){
	    streamID = open(file, O_RDWR | O_CREAT, 0666);

	    if (streamID >= 0) {
		char	c;

		/*
		 * Read and write a byte to the file to change the
		 * modification time, then close the file.
		 */
		if (read(streamID, &c, 1) == 1) {
		    (void)lseek(streamID, (off_t)0, SEEK_SET);
		    (void)write(streamID, &c, 1);
		}

		(void)close(streamID);
	    } else {
		(void)fprintf(stdout, "*** couldn't touch %s: %s",
			       file, strerror(errno));
		(void)fflush(stdout);
	    }
	}
    }
}

/*-
 *-----------------------------------------------------------------------
 * Job_CheckCommands --
 *	Make sure the given node has all the commands it needs.
 *
 * Input:
 *	gn		The target whose commands need verifying
 *	abortProc	Function to abort with message
 *
 * Results:
 *	TRUE if the commands list is/was ok.
 *
 * Side Effects:
 *	The node will have commands from the .DEFAULT rule added to it
 *	if it needs them.
 *-----------------------------------------------------------------------
 */
Boolean
Job_CheckCommands(GNode *gn, void (*abortProc)(const char *, ...))
{
    if (OP_NOP(gn->type) && Lst_IsEmpty(gn->commands) &&
	((gn->type & OP_LIB) == 0 || Lst_IsEmpty(gn->children))) {
	/*
	 * No commands. Look for .DEFAULT rule from which we might infer
	 * commands
	 */
	if ((DEFAULT != NILGNODE) && !Lst_IsEmpty(DEFAULT->commands) &&
	    (gn->type & OP_SPECIAL) == 0) {
	    char *p1;
	    /*
	     * Make only looks for a .DEFAULT if the node was never the
	     * target of an operator, so that's what we do too. If
	     * a .DEFAULT was given, we substitute its commands for gn's
	     * commands and set the IMPSRC variable to be the target's name
	     * The DEFAULT node acts like a transformation rule, in that
	     * gn also inherits any attributes or sources attached to
	     * .DEFAULT itself.
	     */
	    Make_HandleUse(DEFAULT, gn);
	    Var_Set(IMPSRC, Var_Value(TARGET, gn, &p1), gn, 0);
	    if (p1)
		free(p1);
	} else if (Dir_MTime(gn) == 0 && (gn->type & OP_SPECIAL) == 0) {
	    /*
	     * The node wasn't the target of an operator we have no .DEFAULT
	     * rule to go on and the target doesn't already exist. There's
	     * nothing more we can do for this branch. If the -k flag wasn't
	     * given, we stop in our tracks, otherwise we just don't update
	     * this node's parents so they never get examined.
	     */
	    static const char msg[] = ": don't know how to make";

	    if (gn->type & OP_OPTIONAL) {
		(void)fprintf(stdout, "%s%s %s(ignored)\n", progname,
		    msg, gn->name);
		(void)fflush(stdout);
	    } else if (keepgoing) {
		(void)fprintf(stdout, "%s%s %s(continuing)\n", progname,
		    msg, gn->name);
		(void)fflush(stdout);
  		return FALSE;
	    } else {
		(*abortProc)("%s%s %s. Stop", progname, msg, gn->name);
		return FALSE;
	    }
	}
    }
    return TRUE;
}
#ifdef RMT_WILL_WATCH
/*-
 *-----------------------------------------------------------------------
 * JobLocalInput --
 *	Handle a pipe becoming readable. Callback function for Rmt_Watch
 *
 * Input:
 *	stream		Stream that's ready (ignored)
 *	job		Job to which the stream belongs
 *
 * Results:
 *	None
 *
 * Side Effects:
 *	JobDoOutput is called.
 *
 *-----------------------------------------------------------------------
 */
/*ARGSUSED*/
static void
JobLocalInput(int stream, Job *job)
{
    JobDoOutput(job, FALSE);
}
#endif /* RMT_WILL_WATCH */

/*-
 *-----------------------------------------------------------------------
 * JobExec --
 *	Execute the shell for the given job. Called from JobStart and
 *	JobRestart.
 *
 * Input:
 *	job		Job to execute
 *
 * Results:
 *	None.
 *
 * Side Effects:
 *	A shell is executed, outputs is altered and the Job structure added
 *	to the job table.
 *
 *-----------------------------------------------------------------------
 */
static void
JobExec(Job *job, char **argv)
{
    int	    	  cpid;	    	/* ID of new child */
    sigset_t	  mask;

    job->flags &= ~JOB_TRACED;

    if (DEBUG(JOB)) {
	int 	  i;

	(void)fprintf(stdout, "Running %s %sly\n", job->node->name,
		       job->flags&JOB_REMOTE?"remote":"local");
	(void)fprintf(stdout, "\tCommand: ");
	for (i = 0; argv[i] != NULL; i++) {
	    (void)fprintf(stdout, "%s ", argv[i]);
	}
 	(void)fprintf(stdout, "\n");
 	(void)fflush(stdout);
    }

    /*
     * Some jobs produce no output and it's disconcerting to have
     * no feedback of their running (since they produce no output, the
     * banner with their name in it never appears). This is an attempt to
     * provide that feedback, even if nothing follows it.
     */
    if ((lastNode != job->node) && (job->flags & JOB_FIRST) &&
	!(job->flags & JOB_SILENT)) {
	MESSAGE(stdout, job->node);
	lastNode = job->node;
    }

#ifdef RMT_NO_EXEC
    if (job->flags & JOB_REMOTE) {
	goto jobExecFinish;
    }
#endif /* RMT_NO_EXEC */

    /* No interruptions until this job is on the `jobs' list */
    JobSigLock(&mask);

    if ((cpid = vfork()) == -1) {
	Punt("Cannot vfork: %s", strerror(errno));
    } else if (cpid == 0) {

	/*
	 * Reset all signal handlers; this is necessary because we also
	 * need to unblock signals before we exec(2).
	 */
	JobSigReset();

	/* Now unblock signals */
	sigemptyset(&mask);
	JobSigUnlock(&mask);

	/*
	 * Must duplicate the input stream down to the child's input and
	 * reset it to the beginning (again). Since the stream was marked
	 * close-on-exec, we must clear that bit in the new input.
	 */
	if (dup2(FILENO(job->cmdFILE), 0) == -1) {
	    execError("dup2", "job->cmdFILE");
	    _exit(1);
	}
	(void)fcntl(0, F_SETFD, 0);
	(void)lseek(0, (off_t)0, SEEK_SET);

	if (job->node->type & OP_MAKE) {
		/*
		 * Pass job token pipe to submakes.
		 */
		fcntl(job_pipe[0], F_SETFD, 0);
		fcntl(job_pipe[1], F_SETFD, 0);		
	}
	
	if (usePipes) {
	    /*
	     * Set up the child's output to be routed through the pipe
	     * we've created for it.
	     */
	    if (dup2(job->outPipe, 1) == -1) {
		execError("dup2", "job->outPipe");
		_exit(1);
	    }
	} else {
	    /*
	     * We're capturing output in a file, so we duplicate the
	     * descriptor to the temporary file into the standard
	     * output.
	     */
	    if (dup2(job->outFd, 1) == -1) {
		execError("dup2", "job->outFd");
		_exit(1);
	    }
	}
	/*
	 * The output channels are marked close on exec. This bit was
	 * duplicated by the dup2(on some systems), so we have to clear
	 * it before routing the shell's error output to the same place as
	 * its standard output.
	 */
	(void)fcntl(1, F_SETFD, 0);
	if (dup2(1, 2) == -1) {
	    execError("dup2", "1, 2");
	    _exit(1);
	}

#ifdef USE_PGRP
	/*
	 * We want to switch the child into a different process family so
	 * we can kill it and all its descendants in one fell swoop,
	 * by killing its process family, but not commit suicide.
	 */
# if defined(SYSV)
	(void)setsid();
# else
	(void)setpgid(0, getpid());
# endif
#endif /* USE_PGRP */

#ifdef REMOTE
	if (job->flags & JOB_REMOTE) {
	    Rmt_Exec(shellPath, argv, FALSE);
	} else
#endif /* REMOTE */
	{
	   (void)execv(shellPath, argv);
	   execError("exec", shellPath);
	}
	_exit(1);
    } else {
	job->pid = cpid;

	Trace_Log(JOBSTART, job);

	if (usePipes && (job->flags & JOB_FIRST)) {
	    /*
	     * The first time a job is run for a node, we set the current
	     * position in the buffer to the beginning and mark another
	     * stream to watch in the outputs mask
	     */
	    job->curPos = 0;

#ifdef RMT_WILL_WATCH
	    Rmt_Watch(job->inPipe, JobLocalInput, job);
#else
	    watchfd(job);
#endif /* RMT_WILL_WATCH */
	}

	if (job->flags & JOB_REMOTE) {
#ifndef REMOTE
	    job->rmtID = 0;
#else
	    job->rmtID = Rmt_LastID(job->pid);
#endif /* REMOTE */
	} else {
	    nLocal += 1;
	    /*
	     * XXX: Used to not happen if REMOTE. Why?
	     */
	    if (job->cmdFILE != NULL && job->cmdFILE != stdout) {
		(void)fclose(job->cmdFILE);
		job->cmdFILE = NULL;
	    }
	}
    }

#ifdef RMT_NO_EXEC
jobExecFinish:
#endif
    /*
     * Now the job is actually running, add it to the table.
     */
    if (DEBUG(JOB)) {
	printf("JobExec(%s): pid %d added to jobs table\n",
		job->node->name, job->pid);
    }
    nJobs += 1;
    (void)Lst_AtEnd(jobs, (ClientData)job);
    JobSigUnlock(&mask);
}

/*-
 *-----------------------------------------------------------------------
 * JobMakeArgv --
 *	Create the argv needed to execute the shell for a given job.
 *
 *
 * Results:
 *
 * Side Effects:
 *
 *-----------------------------------------------------------------------
 */
static void
JobMakeArgv(Job *job, char **argv)
{
    int	    	  argc;
    static char args[10]; 	/* For merged arguments */

    argv[0] = UNCONST(shellName);
    argc = 1;

    if ((commandShell->exit && (*commandShell->exit != '-')) ||
	(commandShell->echo && (*commandShell->echo != '-')))
    {
	/*
	 * At least one of the flags doesn't have a minus before it, so
	 * merge them together. Have to do this because the *(&(@*#*&#$#
	 * Bourne shell thinks its second argument is a file to source.
	 * Grrrr. Note the ten-character limitation on the combined arguments.
	 */
	(void)snprintf(args, sizeof(args), "-%s%s",
		      ((job->flags & JOB_IGNERR) ? "" :
		       (commandShell->exit ? commandShell->exit : "")),
		      ((job->flags & JOB_SILENT) ? "" :
		       (commandShell->echo ? commandShell->echo : "")));

	if (args[1]) {
	    argv[argc] = args;
	    argc++;
	}
    } else {
	if (!(job->flags & JOB_IGNERR) && commandShell->exit) {
	    argv[argc] = UNCONST(commandShell->exit);
	    argc++;
	}
	if (!(job->flags & JOB_SILENT) && commandShell->echo) {
	    argv[argc] = UNCONST(commandShell->echo);
	    argc++;
	}
    }
    argv[argc] = NULL;
}

/*-
 *-----------------------------------------------------------------------
 * JobRestart --
 *	Restart a job that stopped for some reason.
 *
 * Input:
 *	job		Job to restart
 *
 * Results:
 *	1 if max number of running jobs has been reached, 0 otherwise.
 *
 *-----------------------------------------------------------------------
 */
static int
JobRestart(Job *job)
{
#ifdef REMOTE
    int host;
#endif

    if (job->flags & JOB_REMIGRATE) {
	if (
#ifdef REMOTE
	    verboseRemigrates ||
#endif
	    DEBUG(JOB)) {
	   (void)fprintf(stdout, "*** remigrating %x(%s)\n",
			   job->pid, job->node->name);
	   (void)fflush(stdout);
	}

#ifdef REMOTE
	if (!Rmt_ReExport(job->pid, job->node, &host)) {
	    if (verboseRemigrates || DEBUG(JOB)) {
		(void)fprintf(stdout, "*** couldn't migrate...\n");
		(void)fflush(stdout);
	    }
#endif
	    if (nLocal != maxLocal) {
		/*
		 * Job cannot be remigrated, but there's room on the local
		 * machine, so resume the job and note that another
		 * local job has started.
		 */
		if (
#ifdef REMOTE
		    verboseRemigrates ||
#endif
		    DEBUG(JOB)) {
		    (void)fprintf(stdout, "*** resuming on local machine\n");
		    (void)fflush(stdout);
		}
		KILL(job->pid, SIGCONT);
		nLocal +=1;
#ifdef REMOTE
		job->flags &= ~(JOB_REMIGRATE|JOB_RESUME|JOB_REMOTE);
		job->flags |= JOB_CONTINUING;
#else
		job->flags &= ~(JOB_REMIGRATE|JOB_RESUME);
#endif
	    } else {
		/*
		 * Job cannot be restarted. Mark the table as full and
		 * place the job back on the list of stopped jobs.
		 */
		if (
#ifdef REMOTE
		    verboseRemigrates ||
#endif
		    DEBUG(JOB)) {
		   (void)fprintf(stdout, "*** holding\n");
		   (void)fflush(stdout);
  		}
		(void)Lst_AtFront(stoppedJobs, (ClientData)job);
		return 1;
	    }
#ifdef REMOTE
	} else {
	    /*
	     * Clear out the remigrate and resume flags. Set the continuing
	     * flag so we know later on that the process isn't exiting just
	     * because of a signal.
	     */
	    job->flags &= ~(JOB_REMIGRATE|JOB_RESUME);
	    job->flags |= JOB_CONTINUING;
	    job->rmtID = host;
	}
#endif

	(void)Lst_AtEnd(jobs, (ClientData)job);
	nJobs += 1;
    } else if (job->flags & JOB_RESTART) {
	/*
	 * Set up the control arguments to the shell. This is based on the
	 * flags set earlier for this job. If the JOB_IGNERR flag is clear,
	 * the 'exit' flag of the commandShell is used to cause it to exit
	 * upon receiving an error. If the JOB_SILENT flag is clear, the
	 * 'echo' flag of the commandShell is used to get it to start echoing
	 * as soon as it starts processing commands.
	 */
	char	  *argv[10];

	JobMakeArgv(job, argv);

	if (DEBUG(JOB)) {
	    (void)fprintf(stdout, "Restarting %s...", job->node->name);
	    (void)fflush(stdout);
	}
#ifdef REMOTE
	if ((job->node->type & OP_NOEXPORT) ||
 	    (nLocal < maxLocal && runLocalFirst)
# ifdef RMT_NO_EXEC
	    || !Rmt_Export(shellPath, argv, job)
# else
	    || !Rmt_Begin(shellPath, argv, job->node)
# endif
	   )
#endif
	{
	    if (((nLocal >= maxLocal) && !(job->flags & JOB_SPECIAL))) {
		/*
		 * Can't be exported and not allowed to run locally -- put it
		 * back on the hold queue and mark the table full
		 */
		if (DEBUG(JOB)) {
		    (void)fprintf(stdout, "holding\n");
		    (void)fflush(stdout);
		}
		(void)Lst_AtFront(stoppedJobs, (ClientData)job);
		return 1;
	    } else {
		/*
		 * Job may be run locally.
		 */
		if (DEBUG(JOB)) {
		    (void)fprintf(stdout, "running locally\n");
		    (void)fflush(stdout);
		}
		job->flags &= ~JOB_REMOTE;
	    }
	}
#ifdef REMOTE
	else {
	    /*
	     * Can be exported. Hooray!
	     */
	    if (DEBUG(JOB)) {
		(void)fprintf(stdout, "exporting\n");
		(void)fflush(stdout);
	    }
	    job->flags |= JOB_REMOTE;
	}
#endif
	JobExec(job, argv);
    } else {
	/*
	 * The job has stopped and needs to be restarted. Why it stopped,
	 * we don't know...
	 */
	if (DEBUG(JOB)) {
	   (void)fprintf(stdout, "Resuming %s...", job->node->name);
	   (void)fflush(stdout);
	}
	if ((nJobs != maxJobs) &&
	    ((job->flags & JOB_REMOTE) ||
	     (nLocal < maxLocal) ||
	     ((maxLocal == 0) &&
		((job->flags & JOB_SPECIAL)
#ifdef REMOTE
			&& (job->node->type & OP_NOEXPORT)
#endif
	    ))))
	{
	    /*
	     * If the job is remote, it's ok to resume it as long as the
	     * maximum concurrency won't be exceeded. If it's local and
	     * we haven't reached the local concurrency limit already (or the
	     * job must be run locally and maxLocal is 0), it's also ok to
	     * resume it.
	     */
	    Boolean error;
	    WAIT_T status;

#ifdef RMT_WANTS_SIGNALS
	    if (job->flags & JOB_REMOTE) {
		error = !Rmt_Signal(job, SIGCONT);
	    } else
#endif	/* RMT_WANTS_SIGNALS */
		error = (KILL(job->pid, SIGCONT) != 0);

	    if (!error) {
		/*
		 * Make sure the user knows we've continued the beast and
		 * actually put the thing in the job table.
		 */
		job->flags |= JOB_CONTINUING;
		WSET_STOPCODE(status, SIGCONT);
		JobFinish(job, status);

		job->flags &= ~(JOB_RESUME|JOB_CONTINUING);
		if (DEBUG(JOB)) {
		   (void)fprintf(stdout, "done\n");
		   (void)fflush(stdout);
		}
	    } else {
		Error("couldn't resume %s: %s",
		    job->node->name, strerror(errno));
		WSET_EXITCODE(status, 1, 0);
		JobFinish(job, status);
	    }
	} else {
	    /*
	     * Job cannot be restarted. Mark the table as full and
	     * place the job back on the list of stopped jobs.
	     */
	    if (DEBUG(JOB)) {
		(void)fprintf(stdout, "table full\n");
		(void)fflush(stdout);
	    }
	    (void)Lst_AtFront(stoppedJobs, (ClientData)job);
	    return 1;
	}
    }
    return 0;
}

/*-
 *-----------------------------------------------------------------------
 * JobStart  --
 *	Start a target-creation process going for the target described
 *	by the graph node gn.
 *
 * Input:
 *	gn		target to create
 *	flags		flags for the job to override normal ones.
 *			e.g. JOB_SPECIAL or JOB_IGNDOTS
 *	previous	The previous Job structure for this node, if any.
 *
 * Results:
 *	JOB_ERROR if there was an error in the commands, JOB_FINISHED
 *	if there isn't actually anything left to do for the job and
 *	JOB_RUNNING if the job has been started.
 *
 * Side Effects:
 *	A new Job node is created and added to the list of running
 *	jobs. PMake is forked and a child shell created.
 *-----------------------------------------------------------------------
 */
static int
JobStart(GNode *gn, int flags, Job *previous)
{
    Job		  *job;       /* new job descriptor */
    char	  *argv[10];  /* Argument vector to shell */
    Boolean	  cmdsOK;     /* true if the nodes commands were all right */
    Boolean 	  local;      /* Set true if the job was run locally */
    Boolean 	  noExec;     /* Set true if we decide not to run the job */
    int		  tfd;	      /* File descriptor to the temp file */

    if (previous != NULL) {
	previous->flags &= ~(JOB_FIRST|JOB_IGNERR|JOB_SILENT|JOB_REMOTE);
	job = previous;
    } else {
	job = emalloc(sizeof(Job));
	if (job == NULL) {
	    Punt("JobStart out of memory");
	}
	flags |= JOB_FIRST;
    }
    if (gn->type & OP_SPECIAL)
	flags |= JOB_SPECIAL;

    job->node = gn;
    job->tailCmds = NILLNODE;

    /*
     * Set the initial value of the flags for this job based on the global
     * ones and the node's attributes... Any flags supplied by the caller
     * are also added to the field.
     */
    job->flags = 0;
    if (Targ_Ignore(gn)) {
	job->flags |= JOB_IGNERR;
    }
    if (Targ_Silent(gn)) {
	job->flags |= JOB_SILENT;
    }
    job->flags |= flags;

    /*
     * Check the commands now so any attributes from .DEFAULT have a chance
     * to migrate to the node
     */
    if (!compatMake && job->flags & JOB_FIRST) {
	cmdsOK = Job_CheckCommands(gn, Error);
    } else {
	cmdsOK = TRUE;
    }

#ifndef RMT_WILL_WATCH
    job->inPollfd = NULL;
#endif
    /*
     * If the -n flag wasn't given, we open up OUR (not the child's)
     * temporary file to stuff commands in it. The thing is rd/wr so we don't
     * need to reopen it to feed it to the shell. If the -n flag *was* given,
     * we just set the file to be stdout. Cute, huh?
     */
    if (((gn->type & OP_MAKE) && !(noRecursiveExecute)) ||
	(!noExecute && !touchFlag)) {
	/*
	 * tfile is the name of a file into which all shell commands are
	 * put. It is used over by removing it before the child shell is
	 * executed. The XXXXXX in the string are replaced by the pid of
	 * the make process in a 6-character field with leading zeroes.
	 */
	char     tfile[sizeof(TMPPAT)];
	sigset_t mask;
	/*
	 * We're serious here, but if the commands were bogus, we're
	 * also dead...
	 */
	if (!cmdsOK) {
	    DieHorribly();
	}

	JobSigLock(&mask);
	(void)strcpy(tfile, TMPPAT);
	if ((tfd = mkstemp(tfile)) == -1)
	    Punt("Could not create temporary file %s", strerror(errno));
	if (!DEBUG(SCRIPT))
		(void)eunlink(tfile);
	JobSigUnlock(&mask);

	job->cmdFILE = fdopen(tfd, "w+");
	if (job->cmdFILE == NULL) {
	    Punt("Could not fdopen %s", tfile);
	}
	(void)fcntl(FILENO(job->cmdFILE), F_SETFD, 1);
	/*
	 * Send the commands to the command file, flush all its buffers then
	 * rewind and remove the thing.
	 */
	noExec = FALSE;

	/*
	 * used to be backwards; replace when start doing multiple commands
	 * per shell.
	 */
	if (compatMake) {
	    /*
	     * Be compatible: If this is the first time for this node,
	     * verify its commands are ok and open the commands list for
	     * sequential access by later invocations of JobStart.
	     * Once that is done, we take the next command off the list
	     * and print it to the command file. If the command was an
	     * ellipsis, note that there's nothing more to execute.
	     */
	    if ((job->flags&JOB_FIRST) && (Lst_Open(gn->commands) != SUCCESS)){
		cmdsOK = FALSE;
	    } else {
		LstNode	ln = Lst_Next(gn->commands);

		if ((ln == NILLNODE) ||
		    JobPrintCommand((ClientData)Lst_Datum(ln),
				    (ClientData) job))
		{
		    noExec = TRUE;
		    Lst_Close(gn->commands);
		}
		if (noExec && !(job->flags & JOB_FIRST)) {
		    /*
		     * If we're not going to execute anything, the job
		     * is done and we need to close down the various
		     * file descriptors we've opened for output, then
		     * call JobDoOutput to catch the final characters or
		     * send the file to the screen... Note that the i/o streams
		     * are only open if this isn't the first job.
		     * Note also that this could not be done in
		     * Job_CatchChildren b/c it wasn't clear if there were
		     * more commands to execute or not...
		     */
		    JobClose(job);
		}
	    }
	} else {
	    /*
	     * We can do all the commands at once. hooray for sanity
	     */
	    numCommands = 0;
	    Lst_ForEach(gn->commands, JobPrintCommand, (ClientData)job);

	    /*
	     * If we didn't print out any commands to the shell script,
	     * there's not much point in executing the shell, is there?
	     */
	    if (numCommands == 0) {
		noExec = TRUE;
	    }
	}
    } else if (NoExecute(gn)) {
	/*
	 * Not executing anything -- just print all the commands to stdout
	 * in one fell swoop. This will still set up job->tailCmds correctly.
	 */
	if (lastNode != gn) {
	    MESSAGE(stdout, gn);
	    lastNode = gn;
	}
	job->cmdFILE = stdout;
	/*
	 * Only print the commands if they're ok, but don't die if they're
	 * not -- just let the user know they're bad and keep going. It
	 * doesn't do any harm in this case and may do some good.
	 */
	if (cmdsOK) {
	    Lst_ForEach(gn->commands, JobPrintCommand, (ClientData)job);
	}
	/*
	 * Don't execute the shell, thank you.
	 */
	noExec = TRUE;
    } else {
	/*
	 * Just touch the target and note that no shell should be executed.
	 * Set cmdFILE to stdout to make life easier. Check the commands, too,
	 * but don't die if they're no good -- it does no harm to keep working
	 * up the graph.
	 */
	job->cmdFILE = stdout;
    	Job_Touch(gn, job->flags&JOB_SILENT);
	noExec = TRUE;
    }

    /*
     * If we're not supposed to execute a shell, don't.
     */
    if (noExec) {
	/*
	 * Unlink and close the command file if we opened one
	 */
	if (job->cmdFILE != stdout) {
	    if (job->cmdFILE != NULL) {
		(void)fclose(job->cmdFILE);
		job->cmdFILE = NULL;
	    }
	} else {
	     (void)fflush(stdout);
	}

	/*
	 * We only want to work our way up the graph if we aren't here because
	 * the commands for the job were no good.
	 */
	if (cmdsOK) {
	    if (aborting == 0) {
		if (job->tailCmds != NILLNODE) {
		    Lst_ForEachFrom(job->node->commands, job->tailCmds,
				    JobSaveCommand,
				   (ClientData)job->node);
		}
		if (!(job->flags & JOB_SPECIAL))
		    Job_TokenReturn();
		job->node->made = MADE;
		Make_Update(job->node);
	    }
	    free(job);
	    return(JOB_FINISHED);
	} else {
	    free(job);
	    return(JOB_ERROR);
	}
    } else {
	(void)fflush(job->cmdFILE);
    }

    /*
     * Set up the control arguments to the shell. This is based on the flags
     * set earlier for this job.
     */
    JobMakeArgv(job, argv);

    /*
     * If we're using pipes to catch output, create the pipe by which we'll
     * get the shell's output. If we're using files, print out that we're
     * starting a job and then set up its temporary-file name.
     */
    if (!compatMake || (job->flags & JOB_FIRST)) {
	if (usePipes) {
	    int fd[2];
	    if (pipe(fd) == -1)
		Punt("Cannot create pipe: %s", strerror(errno));
	    job->inPipe = fd[0];
	    job->outPipe = fd[1];
	    (void)fcntl(job->inPipe, F_SETFD, 1);
	    (void)fcntl(job->outPipe, F_SETFD, 1);
	} else {
	    (void)fprintf(stdout, "Remaking `%s'\n", gn->name);
  	    (void)fflush(stdout);
	    (void)strcpy(job->outFile, TMPPAT);
	    job->outFd = mkstemp(job->outFile);
	    (void)fcntl(job->outFd, F_SETFD, 1);
	}
    }

#ifdef REMOTE
    if (!(gn->type & OP_NOEXPORT) && !(runLocalFirst && nLocal < maxLocal)) {
#ifdef RMT_NO_EXEC
	local = !Rmt_Export(shellPath, argv, job);
#else
	local = !Rmt_Begin(shellPath, argv, job->node);
#endif /* RMT_NO_EXEC */
	if (!local) {
	    job->flags |= JOB_REMOTE;
	}
    } else
#endif
	local = TRUE;

    if (local && (((nLocal >= maxLocal) &&
	!(job->flags & JOB_SPECIAL) &&
#ifdef REMOTE
	(!(gn->type & OP_NOEXPORT) || (maxLocal != 0))
#else
	(maxLocal != 0)
#endif
	)))
    {
	/*
	 * The job can only be run locally, but we've hit the limit of
	 * local concurrency, so put the job on hold until some other job
	 * finishes. Note that the special jobs (.BEGIN, .INTERRUPT and .END)
	 * may be run locally even when the local limit has been reached
	 * (e.g. when maxLocal == 0), though they will be exported if at
	 * all possible. In addition, any target marked with .NOEXPORT will
	 * be run locally if maxLocal is 0.
	 */
	job->flags |= JOB_RESTART;
	(void)Lst_AtEnd(stoppedJobs, (ClientData)job);
    } else {
	JobExec(job, argv);
    }
    return(JOB_RUNNING);
}

static char *
JobOutput(Job *job, char *cp, char *endp, int msg)
{
    char *ecp;

    if (commandShell->noPrint) {
	ecp = Str_FindSubstring(cp, commandShell->noPrint);
	while (ecp != NULL) {
	    if (cp != ecp) {
		*ecp = '\0';
		if (msg && job->node != lastNode) {
		    MESSAGE(stdout, job->node);
		    lastNode = job->node;
		}
		/*
		 * The only way there wouldn't be a newline after
		 * this line is if it were the last in the buffer.
		 * however, since the non-printable comes after it,
		 * there must be a newline, so we don't print one.
		 */
		(void)fprintf(stdout, "%s", cp);
		(void)fflush(stdout);
	    }
	    cp = ecp + commandShell->noPLen;
	    if (cp != endp) {
		/*
		 * Still more to print, look again after skipping
		 * the whitespace following the non-printable
		 * command....
		 */
		cp++;
		while (*cp == ' ' || *cp == '\t' || *cp == '\n') {
		    cp++;
		}
		ecp = Str_FindSubstring(cp, commandShell->noPrint);
	    } else {
		return cp;
	    }
	}
    }
    return cp;
}

/*-
 *-----------------------------------------------------------------------
 * JobDoOutput  --
 *	This function is called at different times depending on
 *	whether the user has specified that output is to be collected
 *	via pipes or temporary files. In the former case, we are called
 *	whenever there is something to read on the pipe. We collect more
 *	output from the given job and store it in the job's outBuf. If
 *	this makes up a line, we print it tagged by the job's identifier,
 *	as necessary.
 *	If output has been collected in a temporary file, we open the
 *	file and read it line by line, transfering it to our own
 *	output channel until the file is empty. At which point we
 *	remove the temporary file.
 *	In both cases, however, we keep our figurative eye out for the
 *	'noPrint' line for the shell from which the output came. If
 *	we recognize a line, we don't print it. If the command is not
 *	alone on the line (the character after it is not \0 or \n), we
 *	do print whatever follows it.
 *
 * Input:
 *	job		the job whose output needs printing
 *	finish		TRUE if this is the last time we'll be called
 *			for this job
 *
 * Results:
 *	None
 *
 * Side Effects:
 *	curPos may be shifted as may the contents of outBuf.
 *-----------------------------------------------------------------------
 */
STATIC void
JobDoOutput(Job *job, Boolean finish)
{
    Boolean       gotNL = FALSE;  /* true if got a newline */
    Boolean       fbuf;  	  /* true if our buffer filled up */
    int		  nr;	      	  /* number of bytes read */
    int		  i;	      	  /* auxiliary index into outBuf */
    int		  max;	      	  /* limit for i (end of current data) */
    int		  nRead;      	  /* (Temporary) number of bytes read */

    FILE      	  *oFILE;	  /* Stream pointer to shell's output file */
    char          inLine[132];


    if (usePipes) {
	/*
	 * Read as many bytes as will fit in the buffer.
	 */
end_loop:
	gotNL = FALSE;
	fbuf = FALSE;

	nRead = read(job->inPipe, &job->outBuf[job->curPos],
			 JOB_BUFSIZE - job->curPos);
	if (nRead < 0) {
	    if (DEBUG(JOB)) {
		perror("JobDoOutput(piperead)");
	    }
	    nr = 0;
	} else {
	    nr = nRead;
	}

	/*
	 * If we hit the end-of-file (the job is dead), we must flush its
	 * remaining output, so pretend we read a newline if there's any
	 * output remaining in the buffer.
	 * Also clear the 'finish' flag so we stop looping.
	 */
	if ((nr == 0) && (job->curPos != 0)) {
	    job->outBuf[job->curPos] = '\n';
	    nr = 1;
	    finish = FALSE;
	} else if (nr == 0) {
	    finish = FALSE;
	}

	/*
	 * Look for the last newline in the bytes we just got. If there is
	 * one, break out of the loop with 'i' as its index and gotNL set
	 * TRUE.
	 */
	max = job->curPos + nr;
	for (i = job->curPos + nr - 1; i >= job->curPos; i--) {
	    if (job->outBuf[i] == '\n') {
		gotNL = TRUE;
		break;
	    } else if (job->outBuf[i] == '\0') {
		/*
		 * Why?
		 */
		job->outBuf[i] = ' ';
	    }
	}

	if (!gotNL) {
	    job->curPos += nr;
	    if (job->curPos == JOB_BUFSIZE) {
		/*
		 * If we've run out of buffer space, we have no choice
		 * but to print the stuff. sigh.
		 */
		fbuf = TRUE;
		i = job->curPos;
	    }
	}
	if (gotNL || fbuf) {
	    /*
	     * Need to send the output to the screen. Null terminate it
	     * first, overwriting the newline character if there was one.
	     * So long as the line isn't one we should filter (according
	     * to the shell description), we print the line, preceded
	     * by a target banner if this target isn't the same as the
	     * one for which we last printed something.
	     * The rest of the data in the buffer are then shifted down
	     * to the start of the buffer and curPos is set accordingly.
	     */
	    job->outBuf[i] = '\0';
	    if (i >= job->curPos) {
		char *cp;

		cp = JobOutput(job, job->outBuf, &job->outBuf[i], FALSE);

		/*
		 * There's still more in that thar buffer. This time, though,
		 * we know there's no newline at the end, so we add one of
		 * our own free will.
		 */
		if (*cp != '\0') {
		    if (job->node != lastNode) {
			MESSAGE(stdout, job->node);
			lastNode = job->node;
		    }
		    (void)fprintf(stdout, "%s%s", cp, gotNL ? "\n" : "");
		    (void)fflush(stdout);
		}
	    }
	    if (i < max - 1) {
		/* shift the remaining characters down */
		(void)memcpy(job->outBuf, &job->outBuf[i + 1], max - (i + 1));
		job->curPos = max - (i + 1);

	    } else {
		/*
		 * We have written everything out, so we just start over
		 * from the start of the buffer. No copying. No nothing.
		 */
		job->curPos = 0;
	    }
	}
	if (finish) {
	    /*
	     * If the finish flag is true, we must loop until we hit
	     * end-of-file on the pipe. This is guaranteed to happen
	     * eventually since the other end of the pipe is now closed
	     * (we closed it explicitly and the child has exited). When
	     * we do get an EOF, finish will be set FALSE and we'll fall
	     * through and out.
	     */
	    goto end_loop;
	}
    } else {
	/*
	 * We've been called to retrieve the output of the job from the
	 * temporary file where it's been squirreled away. This consists of
	 * opening the file, reading the output line by line, being sure not
	 * to print the noPrint line for the shell we used, then close and
	 * remove the temporary file. Very simple.
	 *
	 * Change to read in blocks and do FindSubString type things as for
	 * pipes? That would allow for "@echo -n..."
	 */
	oFILE = fopen(job->outFile, "r");
	if (oFILE != NULL) {
	    (void)fprintf(stdout, "Results of making %s:\n", job->node->name);
	    (void)fflush(stdout);
	    while (fgets(inLine, sizeof(inLine), oFILE) != NULL) {
		char	*cp, *endp, *oendp;

		cp = inLine;
		oendp = endp = inLine + strlen(inLine);
		if (endp[-1] == '\n') {
		    *--endp = '\0';
		}
		cp = JobOutput(job, inLine, endp, FALSE);

		/*
		 * There's still more in that thar buffer. This time, though,
		 * we know there's no newline at the end, so we add one of
		 * our own free will.
		 */
		(void)fprintf(stdout, "%s", cp);
		(void)fflush(stdout);
		if (endp != oendp) {
		    (void)fprintf(stdout, "\n");
		    (void)fflush(stdout);
		}
	    }
	    (void)fclose(oFILE);
	    (void)eunlink(job->outFile);
	} else {
	    Punt("Cannot open `%s'", job->outFile);
	}
    }
}

static void
JobRun(GNode *targ)
{
#ifdef notyet
    /*
     * Unfortunately it is too complicated to run .BEGIN, .END,
     * and .INTERRUPT job in the parallel job module. This has
     * the nice side effect that it avoids a lot of other problems.
     */
    Lst lst = Lst_Init(FALSE);
    Lst_AtEnd(lst, targ);
    (void)Make_Run(lst);
    Lst_Destroy(lst, NOFREE);
    JobStart(targ, JOB_SPECIAL, NULL);
    while (nJobs) {
	Job_CatchOutput();
#ifndef RMT_WILL_WATCH
	Job_CatchChildren(!usePipes);
#endif /* RMT_WILL_WATCH */
    }
#else
    Compat_Make(targ, targ);
    if (targ->made == ERROR) {
	PrintOnError("\n\nStop.");
	exit(1);
    }
#endif
}

/*-
 *-----------------------------------------------------------------------
 * Job_CatchChildren --
 *	Handle the exit of a child. Called from Make_Make.
 *
 * Input:
 *	block		TRUE if should block on the wait
 *
 * Results:
 *	none.
 *
 * Side Effects:
 *	The job descriptor is removed from the list of children.
 *
 * Notes:
 *	We do waits, blocking or not, according to the wisdom of our
 *	caller, until there are no more children to report. For each
 *	job, call JobFinish to finish things off. This will take care of
 *	putting jobs on the stoppedJobs queue.
 *
 *-----------------------------------------------------------------------
 */
void
Job_CatchChildren(Boolean block)
{
    int    	  pid;	    	/* pid of dead child */
    Job		  *job;	    	/* job descriptor for dead child */
    LstNode       jnode;    	/* list element for finding job */
    WAIT_T	  status;   	/* Exit/termination status */

    /*
     * Don't even bother if we know there's no one around.
     */
    if (nLocal == 0) {
	return;
    }

    while ((pid = waitpid((pid_t) -1, &status,
			  (block?0:WNOHANG)|WUNTRACED)) > 0)
    {
	if (DEBUG(JOB)) {
	    (void)fprintf(stdout, "Process %d exited or stopped %x.\n", pid,
	      WAIT_STATUS(status));
	    (void)fflush(stdout);
	}

	jnode = Lst_Find(jobs, (ClientData)&pid, JobCmpPid);
	if (jnode == NILLNODE) {
	    if (WIFSTOPPED(status) && (WSTOPSIG(status) == SIGCONT)) {
		jnode = Lst_Find(stoppedJobs, (ClientData) &pid, JobCmpPid);
		if (jnode == NILLNODE) {
		    Error("Resumed child (%d) not in table", pid);
		    continue;
		}
		job = (Job *)Lst_Datum(jnode);
		(void)Lst_Remove(stoppedJobs, jnode);
	    } else {
		Error("Child (%d) not in table?", pid);
		continue;
	    }
	} else {
	    job = (Job *)Lst_Datum(jnode);
	    (void)Lst_Remove(jobs, jnode);
	    nJobs -= 1;
#ifdef REMOTE
	    if (!(job->flags & JOB_REMOTE)) {
		if (DEBUG(JOB)) {
		    (void)fprintf(stdout,
			   "Job queue has one fewer local process.\n");
		    (void)fflush(stdout);
		}
		nLocal -= 1;
	    }
#else
	    nLocal -= 1;
#endif
	}

	JobFinish(job, status);
    }
}

/*-
 *-----------------------------------------------------------------------
 * Job_CatchOutput --
 *	Catch the output from our children, if we're using
 *	pipes do so. Otherwise just block time until we get a
 *	signal(most likely a SIGCHLD) since there's no point in
 *	just spinning when there's nothing to do and the reaping
 *	of a child can wait for a while.
 *
 * Results:
 *	None
 *
 * Side Effects:
 *	Output is read from pipes if we're piping.
 * -----------------------------------------------------------------------
 */
void
Job_CatchOutput(void)
{
    int           	  nready;
    LstNode		  ln;
    Job  	 	  *job;
#ifdef RMT_WILL_WATCH
    int	    	  	  pnJobs;   	/* Previous nJobs */
#endif

    (void)fflush(stdout);
    Job_TokenFlush();
#ifdef RMT_WILL_WATCH
    pnJobs = nJobs;

    /*
     * It is possible for us to be called with nJobs equal to 0. This happens
     * if all the jobs finish and a job that is stopped cannot be run
     * locally (eg if maxLocal is 0) and cannot be exported. The job will
     * be placed back on the stoppedJobs queue, Job_Empty() will return false,
     * Make_Run will call us again when there's nothing for which to wait.
     * nJobs never changes, so we loop forever. Hence the check. It could
     * be argued that we should sleep for a bit so as not to swamp the
     * exportation system with requests. Perhaps we should.
     *
     * NOTE: IT IS THE RESPONSIBILITY OF Rmt_Wait TO CALL Job_CatchChildren
     * IN A TIMELY FASHION TO CATCH ANY LOCALLY RUNNING JOBS THAT EXIT.
     * It may use the variable nLocal to determine if it needs to call
     * Job_CatchChildren(if nLocal is 0, there's nothing for which to
     * wait...)
     */
    while (nJobs != 0 && pnJobs == nJobs) {
	Rmt_Wait();
    }
#else
    if (usePipes) {
	if ((nready = poll((wantToken ? fds : (fds + 1)),
	  		   (wantToken ? nfds : (nfds - 1)), POLL_MSEC)) <= 0) {
	    return;
	} else {
	    sigset_t	mask;
	    JobSigLock(&mask);
	    if (Lst_Open(jobs) == FAILURE) {
		Punt("Cannot open job table");
	    }

	    if (readyfd(&childExitJob)) {
		char token;
		(void)read(childExitJob.inPipe, &token, 1);
		nready -= 1;
	    }

	    while (nready && (ln = Lst_Next(jobs)) != NILLNODE) {
		job = (Job *)Lst_Datum(ln);
		if (readyfd(job)) {
		    JobDoOutput(job, FALSE);
		    nready -= 1;
		}
	    }
	    Lst_Close(jobs);
	    JobSigUnlock(&mask);
	}
    }
#endif /* RMT_WILL_WATCH */
}

/*-
 *-----------------------------------------------------------------------
 * Job_Make --
 *	Start the creation of a target. Basically a front-end for
 *	JobStart used by the Make module.
 *
 * Results:
 *	None.
 *
 * Side Effects:
 *	Another job is started.
 *
 *-----------------------------------------------------------------------
 */
void
Job_Make(GNode *gn)
{
    (void)JobStart(gn, 0, NULL);
}

void
Shell_Init()
{
    if (shellPath == NULL) {
	/*
	 * The user didn't specify a shell to use, so we are using the
	 * default one... Both the absolute path and the last component
	 * must be set. The last component is taken from the 'name' field
	 * of the default shell description pointed-to by commandShell.
	 * All default shells are located in _PATH_DEFSHELLDIR.
	 */
	shellName = commandShell->name;
	shellPath = str_concat(_PATH_DEFSHELLDIR, shellName, STR_ADDSLASH);
    }
    if (commandShell->exit == NULL) {
	commandShell->exit = "";
    }
    if (commandShell->echo == NULL) {
	commandShell->echo = "";
    }
}

/*-
 *-----------------------------------------------------------------------
 * Job_Init --
 *	Initialize the process module
 *
 * Input:
 *	maxproc		the greatest number of jobs which may be running
 *			at one time
 *	maxlocal	the greatest number of jobs which may be running
 *			at once
 *
 * Results:
 *	none
 *
 * Side Effects:
 *	lists and counters are initialized
 *-----------------------------------------------------------------------
 */
void
Job_Init(int maxproc, int maxlocal)
{
    GNode         *begin;     /* node for commands to do at the very start */

    jobs =  	  Lst_Init(FALSE);
    stoppedJobs = Lst_Init(FALSE);
    maxJobs = 	  maxproc;
    maxLocal = 	  maxlocal;
    nJobs = 	  0;
    nLocal = 	  0;
    wantToken =	  FALSE;

    aborting = 	  0;
    errors = 	  0;

    lastNode =	  NILGNODE;

    if (maxJobs == 1
#ifdef REMOTE
	|| noMessages
#endif
		     ) {
	/*
	 * If only one job can run at a time, there's no need for a banner,
	 * is there?
	 */
	targFmt = "";
    } else {
	targFmt = TARG_FMT;
    }

    Shell_Init();

    if (pipe(exit_pipe) < 0)
	Fatal("error in pipe: %s", strerror(errno));
    fcntl(exit_pipe[0], F_SETFD, 1);
    fcntl(exit_pipe[1], F_SETFD, 1);

    childExitJob.inPipe = exit_pipe[0];

    sigemptyset(&caught_signals);
    /*
     * Install a SIGCHLD handler.
     */
    (void)signal(SIGCHLD, JobChildSig);
    sigaddset(&caught_signals, SIGCHLD);

#define ADDSIG(s,h)				\
    if (signal(s, SIG_IGN) != SIG_IGN) {	\
	sigaddset(&caught_signals, s);		\
	(void)signal(s, h);			\
    }

    /*
     * Catch the four signals that POSIX specifies if they aren't ignored.
     * JobPassSig will take care of calling JobInterrupt if appropriate.
     */
    ADDSIG(SIGINT, JobPassSig)
    ADDSIG(SIGHUP, JobPassSig)
    ADDSIG(SIGTERM, JobPassSig)
    ADDSIG(SIGQUIT, JobPassSig)

    /*
     * There are additional signals that need to be caught and passed if
     * either the export system wants to be told directly of signals or if
     * we're giving each job its own process group (since then it won't get
     * signals from the terminal driver as we own the terminal)
     */
#if defined(RMT_WANTS_SIGNALS) || defined(USE_PGRP)
    ADDSIG(SIGTSTP, JobPassSig)
    ADDSIG(SIGTTOU, JobPassSig)
    ADDSIG(SIGTTIN, JobPassSig)
    ADDSIG(SIGWINCH, JobPassSig)
    ADDSIG(SIGCONT, JobContinueSig)
#endif
#undef ADDSIG

    begin = Targ_FindNode(".BEGIN", TARG_NOCREATE);

    if (begin != NILGNODE) {
	JobRun(begin);
	if (begin->made == ERROR) {
	    PrintOnError("\n\nStop.");
	    exit(1);
	}
    }
    postCommands = Targ_FindNode(".END", TARG_CREATE);
}

static void JobSigReset(void)
{
#define DELSIG(s)					\
    if (sigismember(&caught_signals, s)) {		\
	(void)signal(SIGINT, SIG_DFL);			\
    }

    DELSIG(SIGINT)
    DELSIG(SIGHUP)
    DELSIG(SIGQUIT)
    DELSIG(SIGTERM)
#if defined(RMT_WANTS_SIGNALS) || defined(USE_PGRP)
    DELSIG(SIGTSTP)
    DELSIG(SIGTTOU)
    DELSIG(SIGTTIN)
    DELSIG(SIGWINCH)
    DELSIG(SIGCONT)
#endif
#undef DELSIG
    (void)signal(SIGCHLD, SIG_DFL);
}

/*-
 *-----------------------------------------------------------------------
 * Job_Empty --
 *	See if the job table is empty.  Because the local concurrency may
 *	be set to 0, it is possible for the job table to become empty,
 *	while the list of stoppedJobs remains non-empty. In such a case,
 *	we want to restart as many jobs as we can.
 *
 * Results:
 *	TRUE if it is. FALSE if it ain't.
 *
 * Side Effects:
 *	None.
 *
 * -----------------------------------------------------------------------
 */
Boolean
Job_Empty(void)
{
    if (nJobs == 0) {
	if (!Lst_IsEmpty(stoppedJobs) && !aborting) {
	    /*
	     * The job table is obviously not full if it has no jobs in
	     * it...Try and restart the stopped jobs.
	     */
	    JobRestartJobs();
	    return(FALSE);
	} else {
	    return(TRUE);
	}
    } else {
	return(FALSE);
    }
}

/*-
 *-----------------------------------------------------------------------
 * JobMatchShell --
 *	Find a shell in 'shells' given its name.
 *
 * Results:
 *	A pointer to the Shell structure.
 *
 * Side Effects:
 *	None.
 *
 *-----------------------------------------------------------------------
 */
static Shell *
JobMatchShell(const char *name)
{
    Shell	*sh;

    for (sh = shells; sh->name != NULL; sh++) {
	if (strcmp(name, sh->name) == 0)
		return (sh);
    }
    return (NULL);
}

/*-
 *-----------------------------------------------------------------------
 * Job_ParseShell --
 *	Parse a shell specification and set up commandShell, shellPath
 *	and shellName appropriately.
 *
 * Input:
 *	line		The shell spec
 *
 * Results:
 *	FAILURE if the specification was incorrect.
 *
 * Side Effects:
 *	commandShell points to a Shell structure (either predefined or
 *	created from the shell spec), shellPath is the full path of the
 *	shell described by commandShell, while shellName is just the
 *	final component of shellPath.
 *
 * Notes:
 *	A shell specification consists of a .SHELL target, with dependency
 *	operator, followed by a series of blank-separated words. Double
 *	quotes can be used to use blanks in words. A backslash escapes
 *	anything (most notably a double-quote and a space) and
 *	provides the functionality it does in C. Each word consists of
 *	keyword and value separated by an equal sign. There should be no
 *	unnecessary spaces in the word. The keywords are as follows:
 *	    name  	    Name of shell.
 *	    path  	    Location of shell.
 *	    quiet 	    Command to turn off echoing.
 *	    echo  	    Command to turn echoing on
 *	    filter	    Result of turning off echoing that shouldn't be
 *	    	  	    printed.
 *	    echoFlag	    Flag to turn echoing on at the start
 *	    errFlag	    Flag to turn error checking on at the start
 *	    hasErrCtl	    True if shell has error checking control
 *	    check 	    Command to turn on error checking if hasErrCtl
 *	    	  	    is TRUE or template of command to echo a command
 *	    	  	    for which error checking is off if hasErrCtl is
 *	    	  	    FALSE.
 *	    ignore	    Command to turn off error checking if hasErrCtl
 *	    	  	    is TRUE or template of command to execute a
 *	    	  	    command so as to ignore any errors it returns if
 *	    	  	    hasErrCtl is FALSE.
 *
 *-----------------------------------------------------------------------
 */
ReturnStatus
Job_ParseShell(char *line)
{
    char	**words;
    char	**argv;
    int		argc;
    char	*path;
    Shell	newShell;
    Boolean	fullSpec = FALSE;
    Shell	*sh;

    while (isspace((unsigned char)*line)) {
	line++;
    }

    if (shellArgv)
	free(UNCONST(shellArgv));

    memset(&newShell, 0, sizeof(newShell));

    /*
     * Parse the specification by keyword
     */
    words = brk_string(line, &argc, TRUE, &path);
    shellArgv = path;

    for (path = NULL, argv = words; argc != 0; argc--, argv++) {
	    if (strncmp(*argv, "path=", 5) == 0) {
		path = &argv[0][5];
	    } else if (strncmp(*argv, "name=", 5) == 0) {
		newShell.name = &argv[0][5];
	    } else {
		if (strncmp(*argv, "quiet=", 6) == 0) {
		    newShell.echoOff = &argv[0][6];
		} else if (strncmp(*argv, "echo=", 5) == 0) {
		    newShell.echoOn = &argv[0][5];
		} else if (strncmp(*argv, "filter=", 7) == 0) {
		    newShell.noPrint = &argv[0][7];
		    newShell.noPLen = strlen(newShell.noPrint);
		} else if (strncmp(*argv, "echoFlag=", 9) == 0) {
		    newShell.echo = &argv[0][9];
		} else if (strncmp(*argv, "errFlag=", 8) == 0) {
		    newShell.exit = &argv[0][8];
		} else if (strncmp(*argv, "hasErrCtl=", 10) == 0) {
		    char c = argv[0][10];
		    newShell.hasErrCtl = !((c != 'Y') && (c != 'y') &&
					   (c != 'T') && (c != 't'));
		} else if (strncmp(*argv, "check=", 6) == 0) {
		    newShell.errCheck = &argv[0][6];
		} else if (strncmp(*argv, "ignore=", 7) == 0) {
		    newShell.ignErr = &argv[0][7];
		} else if (strncmp(*argv, "errout=", 7) == 0) {
		    newShell.errOut = &argv[0][7];
		} else if (strncmp(*argv, "comment=", 8) == 0) {
		    newShell.commentChar = argv[0][8];
		} else {
		    Parse_Error(PARSE_FATAL, "Unknown keyword \"%s\"",
				*argv);
		    free(words);
		    return(FAILURE);
		}
		fullSpec = TRUE;
	    }
    }

    if (path == NULL) {
	/*
	 * If no path was given, the user wants one of the pre-defined shells,
	 * yes? So we find the one s/he wants with the help of JobMatchShell
	 * and set things up the right way. shellPath will be set up by
	 * Job_Init.
	 */
	if (newShell.name == NULL) {
	    Parse_Error(PARSE_FATAL, "Neither path nor name specified");
	    free(words);
	    return(FAILURE);
	} else {
	    if ((sh = JobMatchShell(newShell.name)) == NULL) {
		    Parse_Error(PARSE_WARNING, "%s: No matching shell",
				newShell.name);
		    free(words);
		    return(FAILURE);
	    }
	    commandShell = sh;
	    shellName = newShell.name;
	}
    } else {
	/*
	 * The user provided a path. If s/he gave nothing else (fullSpec is
	 * FALSE), try and find a matching shell in the ones we know of.
	 * Else we just take the specification at its word and copy it
	 * to a new location. In either case, we need to record the
	 * path the user gave for the shell.
	 */
	shellPath = path;
	path = strrchr(path, '/');
	if (path == NULL) {
	    path = UNCONST(shellPath);
	} else {
	    path += 1;
	}
	if (newShell.name != NULL) {
	    shellName = newShell.name;
	} else {
	    shellName = path;
	}
	if (!fullSpec) {
	    if ((sh = JobMatchShell(shellName)) == NULL) {
		    Parse_Error(PARSE_WARNING, "%s: No matching shell",
				shellName);
		    free(words);
		    return(FAILURE);
	    }
	    commandShell = sh;
	} else {
	    commandShell = emalloc(sizeof(Shell));
	    *commandShell = newShell;
	}
    }

    if (commandShell->echoOn && commandShell->echoOff) {
	commandShell->hasEchoCtl = TRUE;
    }

    if (!commandShell->hasErrCtl) {
	if (commandShell->errCheck == NULL) {
	    commandShell->errCheck = "";
	}
	if (commandShell->ignErr == NULL) {
	    commandShell->ignErr = "%s\n";
	}
    }

    /*
     * Do not free up the words themselves, since they might be in use by the
     * shell specification.
     */
    free(words);
    return SUCCESS;
}

/*-
 *-----------------------------------------------------------------------
 * JobInterrupt --
 *	Handle the receipt of an interrupt.
 *
 * Input:
 *	runINTERRUPT	Non-zero if commands for the .INTERRUPT target
 *			should be executed
 *	signo		signal received
 *
 * Results:
 *	None
 *
 * Side Effects:
 *	All children are killed. Another job will be started if the
 *	.INTERRUPT target was given.
 *-----------------------------------------------------------------------
 */
static void
JobInterrupt(int runINTERRUPT, int signo)
{
    LstNode	ln;		/* element in job table */
    Job		*job;		/* job descriptor in that element */
    GNode	*interrupt;	/* the node describing the .INTERRUPT target */
    sigset_t	mask;

    aborting = ABORT_INTERRUPT;

    JobSigLock(&mask);

    (void)Lst_Open(jobs);
    while ((ln = Lst_Next(jobs)) != NILLNODE) {
	GNode *gn;

	job = (Job *)Lst_Datum(ln);
	gn = job->node;

	if ((gn->type & (OP_JOIN|OP_PHONY)) == 0 && !Targ_Precious(gn)) {
	    char *file = (gn->path == NULL ? gn->name : gn->path);
	    if (!noExecute && eunlink(file) != -1) {
		Error("*** %s removed", file);
	    }
	}
#ifdef RMT_WANTS_SIGNALS
	if (job->flags & JOB_REMOTE) {
	    /*
	     * If job is remote, let the Rmt module do the killing.
	     */
	    if (!Rmt_Signal(job, signo)) {
		/*
		 * If couldn't kill the thing, finish it out now with an
		 * error code, since no exit report will come in likely.
		 */
		WAIT_T status;

		WSET_EXITCODE(status, 1, 0);
		JobFinish(job, status);
	    }
	} else if (job->pid) {
	    KILL(job->pid, signo);
	}
#else
	if (job->pid) {
	    if (DEBUG(JOB)) {
		(void)fprintf(stdout,
			   "JobInterrupt passing signal %d to child %d.\n",
			   signo, job->pid);
		(void)fflush(stdout);
	    }
	    KILL(job->pid, signo);
	}
#endif /* RMT_WANTS_SIGNALS */
    }
    Lst_Close(jobs);

#ifdef REMOTE
   (void)Lst_Open(stoppedJobs);
    while ((ln = Lst_Next(stoppedJobs)) != NILLNODE) {
	GNode *gn;

	job = (Job *)Lst_Datum(ln);
	gn = job->node;

	if (job->flags & JOB_RESTART) {
	    if (DEBUG(JOB)) {
		(void)fprintf(stdout, "%s%s",
			       "JobInterrupt skipping job on stopped queue",
			       "-- it was waiting to be restarted.\n");
		(void)fflush(stdout);
	    }
	    continue;
	}
	if ((gn->type & (OP_JOIN|OP_PHONY)) == 0 && !Targ_Precious(gn)) {
	    char *file = (gn->path == NULL ? gn->name : gn->path);
	    if (eunlink(file) == 0) {
		Error("*** %s removed", file);
	    }
	}
	/*
	 * Resume the thing so it will take the signal.
	 */
	if (DEBUG(JOB)) {
	    (void)fprintf(stdout,
			   "JobInterrupt passing CONT to stopped child %d.\n",
			   job->pid);
	    (void)fflush(stdout);
	}
	KILL(job->pid, SIGCONT);
#ifdef RMT_WANTS_SIGNALS
	if (job->flags & JOB_REMOTE) {
	    /*
	     * If job is remote, let the Rmt module do the killing.
	     */
	    if (!Rmt_Signal(job, SIGINT)) {
		/*
		 * If couldn't kill the thing, finish it out now with an
		 * error code, since no exit report will come in likely.
		 */
		WAIT_T status;
		
		WSET_EXITCODE(status, 1, 0);
		JobFinish(job, status);
	    }
	} else if (job->pid) {
	    if (DEBUG(JOB)) {
		(void)fprintf(stdout,
		       "JobInterrupt passing interrupt to stopped child %d.\n",
			       job->pid);
		(void)fflush(stdout);
	    }
	    KILL(job->pid, SIGINT);
	}
#endif /* RMT_WANTS_SIGNALS */
    }
    Lst_Close(stoppedJobs);
#endif /* REMOTE */

    JobSigUnlock(&mask);

    if (runINTERRUPT && !touchFlag) {
	interrupt = Targ_FindNode(".INTERRUPT", TARG_NOCREATE);
	if (interrupt != NILGNODE) {
	    ignoreErrors = FALSE;
	    JobRun(interrupt);
	}
    }
    Trace_Log(MAKEINTR, 0);
    exit(signo);
}

/*
 *-----------------------------------------------------------------------
 * Job_Finish --
 *	Do final processing such as the running of the commands
 *	attached to the .END target.
 *
 * Results:
 *	Number of errors reported.
 *
 * Side Effects:
 *	None.
 *-----------------------------------------------------------------------
 */
int
Job_Finish(void)
{
    if (postCommands != NILGNODE && !Lst_IsEmpty(postCommands->commands)) {
	if (errors) {
	    Error("Errors reported so .END ignored");
	} else {
	    JobRun(postCommands);
	}
    }
    Job_TokenFlush();
    return(errors);
}

/*-
 *-----------------------------------------------------------------------
 * Job_End --
 *	Cleanup any memory used by the jobs module
 *
 * Results:
 *	None.
 *
 * Side Effects:
 *	Memory is freed
 *-----------------------------------------------------------------------
 */
void
Job_End(void)
{
#ifdef CLEANUP
    if (shellArgv)
	free(shellArgv);
#endif
}

/*-
 *-----------------------------------------------------------------------
 * Job_Wait --
 *	Waits for all running jobs to finish and returns. Sets 'aborting'
 *	to ABORT_WAIT to prevent other jobs from starting.
 *
 * Results:
 *	None.
 *
 * Side Effects:
 *	Currently running jobs finish.
 *
 *-----------------------------------------------------------------------
 */
void
Job_Wait(void)
{
    aborting = ABORT_WAIT;
    while (nJobs != 0) {
	Job_CatchOutput();
#ifndef RMT_WILL_WATCH
	Job_CatchChildren(!usePipes);
#endif /* RMT_WILL_WATCH */
    }
    Job_TokenFlush();
    aborting = 0;
}

/*-
 *-----------------------------------------------------------------------
 * Job_AbortAll --
 *	Abort all currently running jobs without handling output or anything.
 *	This function is to be called only in the event of a major
 *	error. Most definitely NOT to be called from JobInterrupt.
 *
 * Results:
 *	None
 *
 * Side Effects:
 *	All children are killed, not just the firstborn
 *-----------------------------------------------------------------------
 */
void
Job_AbortAll(void)
{
    LstNode	ln;	/* element in job table */
    Job		*job;	/* the job descriptor in that element */
    WAIT_T	foo;
    sigset_t	mask;

    aborting = ABORT_ERROR;

    if (nJobs) {

	JobSigLock(&mask);
	(void)Lst_Open(jobs);
	while ((ln = Lst_Next(jobs)) != NILLNODE) {
	    job = (Job *)Lst_Datum(ln);

	    /*
	     * kill the child process with increasingly drastic signals to make
	     * darn sure it's dead.
	     */
#ifdef RMT_WANTS_SIGNALS
	    if (job->flags & JOB_REMOTE) {
		(void)Rmt_Signal(job, SIGINT);
		(void)Rmt_Signal(job, SIGKILL);
	    } else {
		KILL(job->pid, SIGINT);
		KILL(job->pid, SIGKILL);
	    }
#else
	    KILL(job->pid, SIGINT);
	    KILL(job->pid, SIGKILL);
#endif /* RMT_WANTS_SIGNALS */
	}
	Lst_Close(jobs);
	JobSigUnlock(&mask);
    }

    /*
     * Catch as many children as want to report in at first, then give up
     */
    while (waitpid((pid_t) -1, &foo, WNOHANG) > 0)
	continue;
}

#ifdef REMOTE
/*-
 *-----------------------------------------------------------------------
 * JobFlagForMigration --
 *	Handle the eviction of a child. Called from RmtStatusChange.
 *	Flags the child as remigratable and then suspends it.
 *
 * Input:
 *	hostID		ID of host we used, for matching children
 *
 * Results:
 *	none.
 *
 * Side Effects:
 *	The job descriptor is flagged for remigration.
 *
 *-----------------------------------------------------------------------
 */
void
JobFlagForMigration(int hostID)
{
    Job		  *job;	    	/* job descriptor for dead child */
    LstNode       jnode;    	/* list element for finding job */

    if (DEBUG(JOB)) {
	(void)fprintf(stdout, "JobFlagForMigration(%d) called.\n", hostID);
	(void)fflush(stdout);
    }
    jnode = Lst_Find(jobs, (ClientData)&hostID, JobCmpRmtID);

    if (jnode == NILLNODE) {
	jnode = Lst_Find(stoppedJobs, (ClientData)hostID, JobCmpRmtID);
		if (jnode == NILLNODE) {
		    if (DEBUG(JOB)) {
			Error("Evicting host(%d) not in table", hostID);
		    }
		    return;
		}
    }
    job = (Job *)Lst_Datum(jnode);

    if (DEBUG(JOB)) {
	(void)fprintf(stdout,
		       "JobFlagForMigration(%d) found job '%s'.\n", hostID,
		       job->node->name);
	(void)fflush(stdout);
    }

    KILL(job->pid, SIGSTOP);

    job->flags |= JOB_REMIGRATE;
}

#endif

/*-
 *-----------------------------------------------------------------------
 * JobRestartJobs --
 *	Tries to restart stopped jobs if there are slots available.
 *	Note that this tries to restart them regardless of pending errors.
 *	It's not good to leave stopped jobs lying around!
 *
 * Results:
 *	None.
 *
 * Side Effects:
 *	Resumes(and possibly migrates) jobs.
 *
 *-----------------------------------------------------------------------
 */
static void
JobRestartJobs(void)
{
    sigset_t	mask;

    JobSigLock(&mask);
    while (!Lst_IsEmpty(stoppedJobs)) {
	if (DEBUG(JOB)) {
	    (void)fprintf(stdout, "Restarting a stopped job.\n");
	    (void)fflush(stdout);
	}
	if (JobRestart((Job *)Lst_DeQueue(stoppedJobs)) != 0)
		break;
    }
    JobSigUnlock(&mask);
}

#ifndef RMT_WILL_WATCH
static void
watchfd(Job *job)
{
    int i;
    if (job->inPollfd != NULL)
	Punt("Watching watched job");
    if (fds == NULL) {
	maxfds = JBSTART;
	fds = emalloc(sizeof(struct pollfd) * maxfds);
	jobfds = emalloc(sizeof(Job **) * maxfds);

	fds[0].fd = job_pipe[0];
	fds[0].events = POLLIN;
	jobfds[0] = &tokenWaitJob;
	tokenWaitJob.inPollfd = &fds[0];
	nfds++;

	fds[1].fd = exit_pipe[0];
	fds[1].events = POLLIN;
	jobfds[1] = &childExitJob;
	childExitJob.inPollfd = &fds[1];
	nfds++;
    } else if (nfds == maxfds) {
	maxfds *= JBFACTOR;
	fds = erealloc(fds, sizeof(struct pollfd) * maxfds);
	jobfds = erealloc(jobfds, sizeof(Job **) * maxfds);
	for (i = 0; i < nfds; i++)
	    jobfds[i]->inPollfd = &fds[i];
    }

    fds[nfds].fd = job->inPipe;
    fds[nfds].events = POLLIN;
    jobfds[nfds] = job;
    job->inPollfd = &fds[nfds];
    nfds++;
}

static void
clearfd(Job *job)
{
    int i;
    if (job->inPollfd == NULL)
	Punt("Unwatching unwatched job");
    i = job->inPollfd - fds;
    nfds--;
    /*
     * Move last job in table into hole made by dead job.
     */
    if (nfds != i) {
	fds[i] = fds[nfds];
	jobfds[i] = jobfds[nfds];
	jobfds[i]->inPollfd = &fds[i];
    }
    job->inPollfd = NULL;
}

static int
readyfd(Job *job)
{
    if (job->inPollfd == NULL)
	Punt("Polling unwatched job");
    return (job->inPollfd->revents & POLLIN) != 0;
}
#endif

/*-
 *-----------------------------------------------------------------------
 * JobTokenAdd --
 *	Put a token into the job pipe so that some make process can start
 *	another job.
 *
 * Side Effects:
 *	Allows more build jobs to be spawned somewhere.
 *
 *-----------------------------------------------------------------------
 */

static void
JobTokenAdd(void)
{

    if (DEBUG(JOB))
	printf("deposit token\n");
    write(job_pipe[1], "+", 1);
}

/*-
 *-----------------------------------------------------------------------
 * Job_ServerStartTokenAdd --
 *	Prep the job token pipe in the root make process.
 *
 *-----------------------------------------------------------------------
 */

void
Job_ServerStart(int maxproc)
{
    int i, flags;
    char jobarg[64];
    
    if (pipe(job_pipe) < 0)
	Fatal("error in pipe: %s", strerror(errno));

    /*
     * We mark the input side of the pipe non-blocking; we poll(2) the
     * pipe when we're waiting for a job token, but we might lose the
     * race for the token when a new one becomes available, so the read 
     * from the pipe should not block.
     */
    flags = fcntl(job_pipe[0], F_GETFL, 0);
    flags |= O_NONBLOCK;
    fcntl(job_pipe[0], F_SETFL, flags);

    /*
     * Mark job pipes as close-on-exec.
     * Note that we will clear this when executing submakes.
     */
    fcntl(job_pipe[0], F_SETFD, 1);
    fcntl(job_pipe[1], F_SETFD, 1);

    snprintf(jobarg, sizeof(jobarg), "%d,%d", job_pipe[0], job_pipe[1]);

    Var_Append(MAKEFLAGS, "-J", VAR_GLOBAL);
    Var_Append(MAKEFLAGS, jobarg, VAR_GLOBAL);			
	
    /*
     * Preload job_pipe with one token per job, save the one
     * "extra" token for the primary job.
     * 
     * XXX should clip maxJobs against PIPE_BUF -- if maxJobs is
     * larger than the write buffer size of the pipe, we will
     * deadlock here.
     */
    for (i=1; i < maxproc; i++)
	JobTokenAdd();
}

/*
 * this tracks the number of tokens currently "out" to build jobs.
 */
int jobTokensRunning = 0;
int jobTokensFree = 0;
/*-
 *-----------------------------------------------------------------------
 * Job_TokenReturn --
 *	Return a withdrawn token to the pool.
 *
 *-----------------------------------------------------------------------
 */

void
Job_TokenReturn(void)
{
    jobTokensRunning--;
    if (jobTokensRunning < 0)
	Punt("token botch");
    if (jobTokensRunning)
	jobTokensFree++;
}

/*-
 *-----------------------------------------------------------------------
 * Job_TokenWithdraw --
 *	Attempt to withdraw a token from the pool.
 *
 * Results:
 *	Returns TRUE if a token was withdrawn, and FALSE if the pool
 *	is currently empty.
 *
 * Side Effects:
 * 	If pool is empty, set wantToken so that we wake up
 *	when a token is released.
 *
 *-----------------------------------------------------------------------
 */


Boolean
Job_TokenWithdraw(void)
{
    char tok;
    int count;

    wantToken = FALSE;

    if (aborting)
	    return FALSE;

    if (jobTokensRunning == 0) {
	if (DEBUG(JOB))
	    printf("first one's free\n");
	jobTokensRunning++;
	return TRUE;
    }
    if (jobTokensFree > 0) {
	jobTokensFree--;
	jobTokensRunning++;
	return TRUE;
    }
    count = read(job_pipe[0], &tok, 1);
    if (count == 0)
	Fatal("eof on job pipe!");
    else if (count < 0) {
	if (errno != EAGAIN) {
	    Fatal("job pipe read: %s", strerror(errno));
	}
	if (DEBUG(JOB))
	    printf("blocked for token\n");
	wantToken = TRUE;
	return FALSE;
    }
    jobTokensRunning++;
    if (DEBUG(JOB))
	printf("withdrew token\n");
    return TRUE;
}

/*-
 *-----------------------------------------------------------------------
 * Job_TokenFlush --
 *	Return free tokens to the pool.
 *
 *-----------------------------------------------------------------------
 */

void
Job_TokenFlush(void)
{
    if (compatMake) return;
	
    while (jobTokensFree > 0) {
	JobTokenAdd();
	jobTokensFree--;
    }
}

#ifdef USE_SELECT
int
emul_poll(struct pollfd *fd, int nfd, int timeout)
{
    fd_set rfds, wfds;
    int i, maxfd, nselect, npoll;
    struct timeval tv, *tvp;
    long usecs;

    FD_ZERO(&rfds);
    FD_ZERO(&wfds);

    maxfd = -1;
    for (i = 0; i < nfd; i++) {
	fd[i].revents = 0;

	if (fd[i].events & POLLIN)
	    FD_SET(fd[i].fd, &rfds);

	if (fd[i].events & POLLOUT)
	    FD_SET(fd[i].fd, &wfds);

	if (fd[i].fd > maxfd)
	    maxfd = fd[i].fd;
    }
    
    if (maxfd >= FD_SETSIZE) {
	Punt("Ran out of fd_set slots; " 
	     "recompile with a larger FD_SETSIZE.");
    }

    if (timeout < 0) {
	tvp = NULL;
    } else {
	usecs = timeout * 1000;
	tv.tv_sec = usecs / 1000000;
	tv.tv_usec = usecs % 1000000;
        tvp = &tv;
    }

    nselect = select(maxfd + 1, &rfds, &wfds, 0, tvp);

    if (nselect <= 0)
	return nselect;

    npoll = 0;
    for (i = 0; i < nfd; i++) {
	if (FD_ISSET(fd[i].fd, &rfds))
	    fd[i].revents |= POLLIN;

	if (FD_ISSET(fd[i].fd, &wfds))
	    fd[i].revents |= POLLOUT;

	if (fd[i].revents)
	    npoll++;
    }

    return npoll;
}
#endif /* USE_SELECT */
