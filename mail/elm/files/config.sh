#!/bin/sh
# config.sh
# This file was produced by running the Configure script.

Log='$Log'
Header='$Header'
bin="${PREFIX}/bin"
contains='grep'
cppstdin='/usr/bin/cpp'
cppminus=''
d_getopt='define'
d_memcpy='define'
d_rename='define'
d_symlink='define'
d_whoami='undef'
d_poll='define'
d_inttypes='define'
d_nointtypes='undef'
n='-n'
c=''
orderlib='false'
ranlib=':'
package='elm2'
pager='builtin++'
startsh='#!/bin/sh'
define='define'
loclist='
cat
chgrp
chmod
cp
echo
expr
grep
ln
ls
make
mv
rm
sed
sleep
touch
tr
'
expr='/bin/expr'
sed='/usr/bin/sed'
echo='/bin/echo'
cat='/bin/cat'
rm='/bin/rm'
mv='/bin/mv'
cp='/bin/cp'
tail=''
tr='/usr/bin/tr'
sort=''
uniq=''
grep='/usr/bin/grep'
trylist='
Mcc
compress
cpp
date
emacs
execmail
finger
ispell
line
lint
lp
locale
lpr
mailx
metamail
mips
more
nroff
pack
pg
pgp
pmake
pr
rmail
sendmail
shar
smail
submit
tar
tbl
test
troff
uname
uuname
vi
'
test='/bin/test'
inews=''
ispell='ispell'
egrep=''
more='/usr/bin/more'
pg='pg'
Mcc='Mcc'
vi='/usr/bin/vi'
mailx='/usr/bin/mailx'
mail=''
cpp='/usr/bin/cpp'
perl=''
emacs='emacs'
ls='/bin/ls'
rmail='/bin/rmail'
sendmail='/usr/sbin/sendmail'
shar='/usr/bin/shar'
smail='smail'
submit=''
tbl='/usr/bin/tbl'
troff='/usr/bin/troff'
nroff='/usr/bin/nroff'
uname='/usr/bin/uname'
uuname='/usr/bin/uuname'
line='line'
chgrp='/usr/bin/chgrp'
chmod='/bin/chmod'
lint='/usr/bin/lint'
sleep='/bin/sleep'
pr='/usr/bin/pr'
tar='/usr/bin/tar'
ln='/bin/ln'
lpr='/usr/bin/lpr'
lp='/usr/bin/lp'
touch='/usr/bin/touch'
make='/usr/bin/make'
date='/bin/date'
csh=''
pmake='pmake'
mips='false'
col=''
pack='pack'
compress='/usr/bin/compress'
execmail=''
libswanted='intl nls'
noaddlib='yes'
c_date='Tue Apr 13 17:07:42 GMT 1999'
d_ascii='undef'
d_broke_ctype='undef'
d_calendar='define'
calendar='calendar'
d_chown_neg1='define'
d_content='undef'
d_crypt='define'
cryptlib='-lcrypt'
d_cuserid='undef'
d_disphost='undef'
d_domname='define'
d_usegetdom='define'
d_errlst='undef'
d_flock='define'
d_dotlock='undef'
d_fcntlock='undef'
has_flock='define'
has_fcntl='define'
d_ftruncate='define'
d_gethname='define'
d_douname='undef'
d_host_comp='undef'
ign_hname='n'
d_havetlib='define'
termlib='-ltermlib'
d_index='define'
d_internet=''
d_ispell='define'
ispell_path='ispell'
ispell_options=''
d_locale='define'
d_nl_types='define'
d_msgcat='define'
d_usenls='undef'
d_mallocvoid='define'
d_mboxedit='define'
metamail_path='none'
defencoding=''
d_8bitmime='undef'
d_binarymime='undef'
d_dsn='define'
defcharset='DISPLAY'
defdispcharset='ISO-8859-1'
d_mmdf='undef'
d_newauto='define'
d_noaddfrom='define'
d_usedomain='undef'
d_noxheader='undef'
d_pidcheck='define'
d_ptem='undef'
d_putenv='define'
d_remlock='undef'
maxattempts='6'
d_setgid='undef'
d_savegrpmboxid='undef'
mailermode='755'
d_sigvec='undef'
d_sigvectr='undef'
d_sigset='undef'
d_sighold='undef'
d_sigprocmask='define'
d_sigblock='undef'
d_waitpid='define'
d_sigaction='define'
d_strcspn='define'
d_strspn='define'
d_strpbrk='define'
d_strerror='define'
d_strftime='define'
d_strings='undef'
d_pwdinsys='undef'
strings='/usr/include/string.h'
includepath=''
d_strstr='define'
d_strtok='define'
d_subshell='define'
d_tempnam='define'
tempnamo=''
tempnamc=''
d_termio='undef'
d_termios='define'
d_utimbuf='define'
d_vfork='define'
defbatsub='no subject (file transmission)'
defeditor='/usr/bin/vi'
editoropts=''
hostname="${Hostname}"
phostname='hostname'
mydomain="${Domain}"
autohostname='define'
i_memory='define'
i_stdarg=''
i_stdlib='define'
i_time='define'
i_systime='define'
d_systimekernel='undef'
i_unistd='define'
i_utime='define'
i_sysutime='undef'
lib="${PREFIX}/lib"
libc='/usr/lib/libc.so.12.40'
linepr='/usr/bin/lp'
maildir='/var/mail'
mailer='/usr/sbin/sendmail'
mailgrp='bin'
mansrc="${PREFIX}/man/man1"
catmansrc="${PREFIX}/man/cat1"
manext='.1'
manext_choice='.1'
catmanext='.0'
catmanext_choice='.0'
packed='n'
manroff='/usr/bin/nroff'
manroffopts=''
suffix=''
packer=''
models='none'
split=''
small=''
medium=''
large=''
huge=''
optimize="$CFLAGS"
ccflags=''
cppflags=''
ldflags='-s'
cc='cc'
libs=''
nametype='bsd'
d_passnames='define'
d_berknames='define'
d_usgnames='undef'
# passcat=''
rmttape='unknown-remote-tape-unit'
roff='/usr/bin/troff'
roffopts=''
sigtype='void'
spitshell='cat'
shsharp='true'
sharpbang='#!'
tmpdir='/tmp'
tzname_handling='TM_ZONE'
use_pmake='n'
xencf=''
xenlf=''
d_xenix='undef'
d_bsd='define'
locale='locale'
d_pgp='define'
pgp='pgp'
pgp_path="${PREFIX}/bin/pgp"
special_path='/sbin'
d_remailer='undef'
finger='/usr/bin/finger'
finger_path=''
CONFIG=true
