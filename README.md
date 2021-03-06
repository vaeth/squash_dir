# squash_dir

(C) Martin Väth (martin at mvath.de).
The license of this package is the GNU Public License GPL-2.

## Warning

This project is no longer maintained. Use instead the successor project(s)
-	https://github.com/vaeth/squashmount/
-	https://github.com/vaeth/openrc-wrapper/

__squashmount__ is more generic, support also overlay(fs) from __linux-3.18__
and newer and __squashfuse__ and works without problems with any init system.
Moreover, __squashmount__ has a highly improved control interface.

The above __openrc-wrapper__ script might receive further development,
while the corresponding script from __squash_dir__ is frozen and
no longer maintained.

## What is this project?

This is essentially an initscript for __openrc__ and/or __systemd__ which
allows to keep a directory compressed by __squashfs__ but simultaneously allows
to write on it using some of (depending on the configuration and what is
available):

- __overlayfs__, seehttp://git.kernel.org/?p=linux/kernel/git/mszeredi/vfs.git
- __aufs__, see http://aufs.sourceforge.net
- __unionfs-fuse__, see http://podgorny.cz/moin/UnionFsFuse
  (__unionfs-fuse-0.25__ or newer is required)
- __unionfs__, see http://www.fsl.cs.sunysb.edu/project-unionfs.html
- __funionfs__, see http://bugs.gentoo.org/show_bug.cgi?id=151673

The idea is that on shutdown the data is recompressed
(and the temporary modified data removed).
This approach is originally due to __synss__' script from
http://forums.gentoo.org/viewtopic-t-465367-highlight-.html

In that forum thread you can also ask for help about this project.

If the Gentoo portage tree `/usr/portage` is compressed this way
(without `$DISTDIR` which you should store somewhere else when using
this script),
the required disk space is only about 50 MB (instead of about 180 MB,
the actual space requirement depending essentially on the filesystem),
and usually the access is even faster.

In addition, this project contains an `openrc-wrapper` script which can be used
to use simple initscripts of __openrc__ even if openrc is not running:
In particular, these scripts can then be used with __systemd__ (and also this
script is sometimes handy from the command line for administrative purposes).
If the initscripts are simple enough, __openrc__ need not even be installed for
the `openrc-wrapper``to work: For this reason, this project will also work
with *only* systemd, although natively it is meant for __openrc__.

## Requirements

The script requires of course that __squashfs__ support is activated in the
kernel (and supports the `COMPRESSION` method), that the `mksquashfs` tool
is available, and also that some of the above mentioned unionfs-type tools
is available and supported by the kernel.
Moreover, a POSIX shell and `find` are needed with the following extensions
(which are not yet POSIX):
1. The `find` command must know the `-path` option
2. A `mktemp` program must be available in `$PATH` if you make use
   of the temporary file name feature (described later)
3. `flock` is needed unless you disable file locking
   (see `LOCKFILE` below).

Some standard tools like `/bin/false` are also assumed (if `/bin/false`
is missing, it is also ok, but it must not do something else than return
nonzero status).
Of course, for the case that you use the `FILE_TBZ` feature, also the
corresponding `TARCMD` and its requirement (like `tar` and `bzip2`) must exist.

If you want that the hard status line is set, also the `title` script from
https://github.com/vaeth/runtitle (version 2.3 or newer) is required in your
`$PATH`.

It is strongly recommended to put

`alias squash_dir='noglob squash_dir'`

into your `~/.zshrc`, `/etc/zsh/zshrc`, or `/etc/zshrc`, so that things like

`squash_dir start *`

will work in your __zsh__ as intended without the need to quote `*`.
(I assume that you do not use a poor shell instead of __zsh__.)


## Main Example

In this example, it is assumed that you have already installed/copied the
`/etc/init.d/squash_dir` script and that you want to keep the three directories
`/usr/portage`, `/var/db`, and `/usr/share/texmf-dist` compressed
(as a remark: other good candidates for compression are the kernel sources
and on some systems also `/usr/share/games`).
Create three symbolic links:
-	`ln -s squash_dir /etc/init.d/squash_portage`
-	`ln -s squash_dir /etc/init.d/squash_db`
-	`ln -s squash_dir /etc/init.d/squash_tex`

You have to create the corresponding three config-files of the same name
in `/etc/conf.d/`.
Here are typical examples of the content of these files:

`/etc/conf.d/squash_portage`:
```
DIRECTORY=/usr/portage
DIR_CHANGE=$DIRECTORY.changes
DIR_SQUASH=$DIRECTORY.readonly
COMPRESSION=
THRESHOLD=40000
```

`/etc/conf.d/squash_tex`:
```
DIRECTORY=/usr/share/texmf-dist
DIR_CHANGE=$DIRECTORY.changes
DIR_SQUASH=$DIRECTORY.readonly
IGNORETOUCH=ls-R
IGNORETOUCH=$IGNORETOUCH"|tex"
IGNORETOUCH=$IGNORETOUCH"|tex/generic"
IGNORETOUCH=$IGNORETOUCH"|tex/generic/config"
IGNORETOUCH=$IGNORETOUCH"|tex/generic/config/language.dat"
IGNORETOUCH=$IGNORETOUCH"|tex/generic/config/language.dat.lua"
IGNORETOUCH=$IGNORETOUCH"|tex/generic/config/language.def"
```

`/etc/conf.d/squash_db`:
```
DIRECTORY=/var/db
FILE_SQFS_OLD=$DIRECTORY.sqfs.bak
DIR_CHANGE=$DIRECTORY.changes
DIR_SQUASH=$DIRECTORY.readonly
COMPRESSION=lzo
THRESHOLD=1000
```

Optionally, you can also modify global defaults in `/etc/conf.d/squash_dir`;
see the comments in the same `conf.d/squash_dir` file for details

The meaning of this configuration data is the following:
The first line determines the directory you want to keep compressed and
be writable; the corresponding compressed data will be expected/created
in the file `$DIRECTORY.sqfs` (e.g. in `/usr/share/portage.sqfs`).
Moreover, later, there will be auxiliary directories `$DIRECTORY.changes`
and `$DIRECTORIES.readonly` available. The latter is the content of
the compressed data without any modifications (this directory is readonly),
and the former contains the modified files (and some metadata, depending
on which of
__overlayfs__ | __aufs__ | __unionfs-fuse__ | __unionfs__ | __funionfs__
you are using).
The `THRESHOLD` value means that your changes will not be compressed on every
shutdown but only if `$DIRECTORY.changes` gets large enough.
Moreover, the `IGNORETOUCH`-value in `squash_tex` means that changes only in
the date of the file `/usr/share/texmf-dist/ls-R` or
`/usr/share/texmf-dist/generic/config/language.{dat{,.lua},def}`
should not cause a recompression on shutdown
(these files are usually often recreated with the same content,
and so if nothing else happens, it is reasonable to ignore this change).
The `FILE_SQFS_OLD` value in `/etc/conf.d/squash_db` means that a
backup should always be kept of the previous compressed data for `/var/db`;
this is for security reasons, since that directory is rather vital to
your system (the other two directories could be re-synced resp. re-emerged
in case something bad happens, but if `/var/db` is lost, you have practically
completely messed up your system).
The settings of `COMPRESSION` mean the following:
- `squash_tex`: Use the usually best compressing algorithm (currently: `xz`)
- `squash_portage`: Use the default `mksquash` algorithm (currently: `gzip`)
- `squash_db`: Use the `lzo` algorithm (usually the fastest)

Of course, you should make sure that the squashfs in your kernel supports
the corresponding algorithms.

Now to actually make these settings active, start the initscripts.
You can do this manually in the classical way using (in case of __openrc__)
-	`/etc/init.d/squash_portage start`
-	`/etc/init.d/squash_tex start`
-	`/etc/init.d/squash_db start`

or using (in case of __systemd__)
-	`systemctl start squash_dir@portage.service`
-	`systemctl start squash_dir@tex.service`
-	`systemctl start squash_dir@db.service`

or in a more convenient way using the `/usr/sbin/squash_dir`
command line interface to start them all with only one command:
-	`squash_dir start`
or
-	`squash_dir start portage tex db`
(this assumes of course that `/usr/sbin/squash_dir` will be found in your
`$PATH`).

Be very careful that you made no mistake before, when you make this step!
The starting of the initscripts will create the corresponding
squashed files and **clean** the directories (i.e. if you want to undo this
change for some reason using _unsquashfs_ on the created files, you might
have lost some information permanently like e.g. hard-links within the
cleaned directories).

If the above step appears too dangerous to you, you can of course also
create the file manually
-	`mksquashfs /usr/portage /usr/portage.sqfs`
-	`mksquashfs /usr/share/texmf-dist /usr/share/texmf-dist.sqfs`
-	`mksquashfs /var/db /var/db.sqfs`

and if this was successful, for testing only **move** the corresponding
directories
`/usr/portage`, `/usr/share/texmf-dist`, `/var/db`
somewhere else; actually, the latter is not mandatory: The directories will
just get "over-mounted", i.e. you will not see the previous content anymore.

If the squashed file exists (i.e. if you created them manually using
'mksquashfs`), you can start the initscript safely,
i.e. in this case `$DIRECTORY` will not get cleaned automatically.

In order to start the initscripts also on the next boot, add them
to your default runlevel (if you use openrc):
-	`rc-config add squash_portage default`
-	`rc-config add squash_tex default`
-	`rc-config add squash_db default`

If you use systemd, to start all configured scripts at once on system start:
-	`systemctl enable squash_dir`

When you shutdown the computer (more precisely: When the above initscripts
are stopped) any modifications to the directories are recompressed
(unless the `THRESHOLD` is not reached or the touching of
`/usr/share/texmf-dist/ls-R` was the only modification).

In some situations you might want to recompress the directories even
before you shutdown the system (or perhaps even if the `THRESHOLD` is not
yet reached or no serious modifications were done).
In this case you can call e.g. (in __openrc__)
-	`/etc/init.d/squash_portage restart`
-	`/etc/init.d/squash_tex restart`
-	`/etc/init.d/squash_db restart`

or (in __systemd__)
-	`systemctl restart squash_dir@portage.service`
-	`systemctl restart squash_dir@tex.service`
-	`systemctl restart squash_dir@db.service`

or you can use the `/usr/sbin/squash_dir` command line interface with
corresponding parameters to execute (some or all) of these commands in a row
(calling the interface without parameters shows the options; the interface
offers with `-s` resp. `-sf` also the possibility to e.g. create magic files
to override the `THRESHOLD` option).

If you plan to squash the Gentoo portage tree `/usr/portage`, you should keep
`$DISTDIR` in a different directory in advance:
It makes no sense (i.e. it costs enormous time and needs lot of temporary
diskspace without much gain) to compress compressed tarballs. Hence:
Move `/usr/portage/distdir` to some other place (outside the `/usr/portage`
hierarchy) and modify `$DISTDIR` in `/etc/portage/make.conf` correspondingly,
before you start the initscripts for the first time.


## A Word of None-Warning

It is in general rather safe to squash a directory, even a rather vital one:
Even if e.g. you boot from a kernel which has no support for some of
__aufs__ | __overlayfs__ | __unionfs-fuse__ | __unionfs__ | __funionfs__
to make the directory writable, the script will mount it at least as read-only
(using `mount --bind` if necessary).
Moreover, if everything goes wrong you can still use `unsquashfs`
to unpack the directory manually.
Probably the only danger in packing "strange" directories are special files
like hard links (this information will usually get lost) or special devices
which are perhaps not supported by the used tools.


## Modules and Mounting

If you compiled __squashfs__, __aufs__, __overlayfs__, or __fuse__ as modules,
you should `modprobe` these modules first (or better put them into
`/etc/conf.d/modules`).
squash_dir will make no attempt to load the modules (unless this happens
automatically by the corresponding mount program): The script will just
attempt to mount the directories using the corresponding tool and
will check its return status for success.
If the mount fails, the next tool is attempted for mounting, until one
succeeds (the order and which tools are attempted can be influenced using
the `ORDER` variable described below).
If no tool succeeds, it is attempted to use `mount --bind` to get
the directory at least readonly on the expected place, so even in
this bad situation (which probably only happens if you boot from an
experimental kernel or a brand new kernel without corresponding support)
you can still access the directory read-only. Hence, also rather vital
directories can be compressed as long as it is not vital to write to them
(and as long as the relevant programs for mounting etc. are not contained
withing these directories, of course).


## Patching squashfs-tools

It is recommended to use a patched version of squashfs-tools which
redirects its progress bar to stderr (instead of stdout).
Cf. the description of the `VERBOSE_MODE` variable for details.


## Call of the Initscripts

Besides the usual options like `start`/`stop`/`restart`, there are also
helper options for the `/etc/init.d/squash_`* scripts which are meant to be
used from other scripts (for example, they are used by the
`/usr/sbin/squash_dir` command line interface).

- `STOP`

  Executes the actions of `stop` without actually stopping.
  Moreover, this can be called even if the script was not started.
  Use this only in case of fatal problems and with extreme care!

- `START`

  Execute the actions of `start` without actually starting.
  For instance, it is not required that dependencies are started.
  Moreover, this can be called even if the script was started.
  Use this only in case of fatal problems and with extreme care!

- `RESTART`

  Execute the actions `STOP` && `START` without actually restarting.
  For instance, dependencies are not restarted.
  Moreover, this can be called even if the script was stopped.
  Use this only in case of fatal problems and with extreme care!

- `will_squash`

  returns _true_/_false_ (and a corresponding message unless `-q` is used)
  depending on whether the `stop` operation would re-squash
  or kill `$DIR_CHANGE` (the latter means that `$KILL_FILE` exists).

- `need_squash`

  returns _true_/_false_ depending on whether new data was written.
  (If no `$MAGIC_FILE` exists - see below - this is the same as `will_squash`).

- `have_magic`

  returns _true_/_false_ depending on whether `$MAGIC_FILE` exists.

- `have_kill`

  returns _true_/_false_ depending on whether `$KILL_FILE` exists.

- `print_dir_change`

  outputs the effective path to `DIR_CHANGE` to stderr,
  taking the temporary name feature into account (see below).

- `print_dir_squash`

  outputs the effective path to DIR_SQUASH to stderr,
  taking the temporary name feature into account (see below).

- `print_ignore_threshold`

  outputs the effective value of `IGNORE_THRESHOLD`,
  taking the temporary name feature into account (see below).
  If `THRESHOLD` is not used, the empty string is output.

- `print_magic_file`

  outputs the effective value of `MAGIC_FILE`,
  taking the temporary name feature into account (see below).

- `print_kill_file`

   outputs the effective value of `KILL_FILE`,
   taking the temporary name feature into account (see below).

(It may be faulty to use the `print_`* commands if the temporary name
feature is used in the corresponding paths and the script was not started).

Unfortunately, the return value of initscripts is ignored with openrc.
Therefore, the answer (`1` for _true_, `0` for _false_) for the first three
functions is written to stderr instead of being passed as an exit status.
For the directory names of the `print_dir_`* options a `/` is appended to
make it easier for calling scripts to deal with trailing spaces.

## Variables (Configuration in `/etc/conf.d/squash_`*)

The subsequent variables can be defined in `/etc/conf.d/squash_`*
Three values are mandatory:

`DIRECTORY` **must** be defined, and usually you will want to specify at least
`DIR_CHANGE` and probably also `DIR_SQUASH`; for the others, default values
are assumed as described below.

The corresponding directories will be created if they do not exist.
Some variables support the "temporary name feature". This means that a path
ending with `XXXXXX` (like e.g. `/tmp/squash_foo.XXXXXXXX`) is transformed into
a corresponding file/directoryname using `mktemp` (or `mktemp -d`,
respectively) when it is used.
Using paths in world-writable directories (e.g. `/tmp` or `/dev/shm`)
for some data is a security risk and therefore strongly discouraged.
An exception of this rule is of course for those paths for which you use
the temporary name feature which is handled safely - that's why this feature
was introduced.

- `DIRECTORY`

  The directory where the squashed filesystem should finally
  be mounted, i.e. the path of the "original" directory.
  If you want to use this script to compress your portage tree,
  it might be a good idea to set this variables with
  ```
  DIRECTORY=`. /etc/portage/make.conf 2>/dev/null; printf '%s' "$PORTDIR"`
  ```
  or the slower but more portable
  ```
  DIRECTORY="`portageq portdir`"
  ```
  The only restriction concerning `DIRECTORY` is that none of
  the following files or directories should reside within this
  directory.
  Note that you will get problems if you squash a directory
  containing data needed to run this script (e.g. the
  kernel module for __squashfs__ or - if you ever plan to upgrade
  your kernel - tools to build the kernel modules) because you
  can of course not access the squash'ed directory until this
  script was successfully started...

- `TMPDIR`

  This variable is only used in the defaults of the following
  variables. If you leave it empty, it defaults to `/tmp`.

- `DIR_CHANGE`

  The directory where the modifications of `DIRECTORY` will go.
  This should be on a partition where you have sufficient space.
  This variable supports the temporary name feature described
  above. However, you should use a temporary directory or a
  ramdisk only if your changes to `DIRECTORY` will always only
  be temporary, i.e. if you are really prepared to loose your
  changes after a cleanup of the temporary directory or after
  a reboot.
  Normally (i.e. if you do not use the temporary name feature
  and `DIR_CHANGE` is not cleaned) all your changes will survive
  a reboot even if you make use of the `MAGIC_FILE` feature below.

  Note that some earlier versions of __squash_dir__ failed to empty
  `DIR_CHANGE` if it used the temporary file name feature, but now
  it should be save to use it.

  You can leave this variable empty: If you do this, __squash_dir__
  will assume that you do not want to be able to write to
  `DIRECTORY`, i.e. `DIRECTORY` will be mounted readonly.
  In this case you will probably also want to leave the following
  variable empty.

- `RM_DIR_CHANGE`

  If this variable is true (not empty, not `0` or `-` and does not start
  with `f`, `F`, `n`, or `N`), the script will remove `DIR_CHANGE` at stopping.
  If it contains `p` or `P` also empty parents are removed.
  `RM_DIR_CHANGE` defaults to `parents` if the temporary name
  feature is used for `DIR_CHANGE`.

- `RUNPATH`

  This is only used in the defaults of `DIR_SQUASH`.
  It defaults to `/run`, `/var/run`, or `/`, depending on what exists.

- `DIR_SQUASH`

  This is a directory which is needed for technical reasons
  when `DIR_CHANGE` is non-empty (i.e. if you really want to mount
  `DIRECTORY` writable). This directory will contain a read-only
  version of the contents of `FILE_SQFS`.
  In case things go wrong when making `DIRECTORY` writable (e.g.
  if __aufs__/__overlayfs__/__unionfs-fuse__/__unionfs__/__funionfs__
  all fail due to missing support by the kernel) you can still access
  `DIR_SQUASH`; you can also use this directory to compare the content
  of currently changed files with their "original" stored in the most current
  version of `FILE_SQFS`.

  With some earlier versions of __squash_dir__, the temporary
  name feature was not or not properly supported for this
  variable, but now it is safe to use it.

  If you leave this variable empty and `DIR_CHANGE` is nonempty,
  `DIR_SQUASH` defaults to `$RUNPATH/$SVCNAME.readonly`.

  If `DIR_CHANGE` is empty, `DIR_SQUASH` is not really needed and
  should usually be left empty. Nevertheless, if you set
  `DIR_SQUASH` anyway, the `DIR_SQUASH` directory will contain an
  identical copy of `DIRECTORY` (this is useful if you use some
  scripts which rely on `DIR_SQUASH`, and you change `DIR_CHANGE`
  temporarily from nonempty to empty).

- `RM_DIR_SQUASH`

  If this variable is true, the script will remove `DIR_SQUASH`
  at stopping (if `DIR_SQUASH` is set and the directory does not
  contain files). If it contains the letter `p`, also empty
  parents are removed.
  `RM_DIR_SQUASH` defaults to true if the default (and nonempty)
  value is used for `DIR_SQUASH`.
  It defaults to `parents` if the temporary name feature is used
  for `DIR_SQUASH`.

- `NAME_FILE`

  If you use the temporary name feature for `DIR_CHANGE` or
  `DIR_SQUASH`, this variable must contain the name of a file
  which is used to store these temporary names. If no errors
  occur, this file is created/removed on start/stop.
  If `NAME_FILE` is empty, it defaults to `$RUNPATH/$SVCNAME`.

- `TMP_SQFS`

  This is a filename (which supports the temporary name feature)
  which is used during shutdown for the squashfs-file which
  is created from `DIRECTORY`. After successfull creation that file
  is moved to `FILE_SQFS`.
  On the partition of this file there must be enough space to
  store the new `FILE_SQFS`. If possible, you should use the
  same partition on which also `FILE_SQFS` is stored (then the
  move command does not have to copy the data once more).
  Alternatively, if you have sufficient ram, you can also
  use a ramdisk like `/dev/shm/dir_squash_tmp_sqfs.XXXXXXXX`
  (but you will not get much speed increase from doing so).
  If `TMP_SQFS` is empty, it defaults to
  `$TMPDIR/$SVCNAME.sqfs.XXXXXXXX`.

- `FILE_SQFS`

  This is the file which contains the actual squashfs data of
  `DIRECTORY` (this file must exist when you start this script.
  See the output message of the script on how to create it.)
  If you leave this empty, it defaults to `$DIRECTORY.sqfs`.

- `FILE_SQFS_OLD`

  If defined, this file will be an (automatically updated)
  copy of your previous `FILE_SQFS` file.

- `MV_FILE_SQFS`

  Here you can define the `mv` command which is used to create
  `FILE_SQFS_OLD`. You might want to set this e.g. to
  `mv --backup --`, `mv --version-control --`, or similar things.
  The default is `mv --`.

- `FILE_TBZ`

  If defined, this file will contain a copy of `FILE_SQFS`,
  but in `.tar.bz2` format (updated during stopping).
  This may be handy in case of problems when you do not have
  access to a kernel with an sqfs-module or to `unsquashfs`.

- `TARCMD`

  This is the command (including options) used to create the
  `FILE_TBZ` archive. It defaults to `tar -cjf`, but you might
  want set it to `/home/bin/tbzd -R` if you installed my
  compression scripts there (this will save slightly more space
  by stripping the parent directory names and using `bzip -9`).
  Of course, you can also use your own script analogously or
  use another compression program.

- `FILE_TBZ_OLD`

  If defined, this file will be an (automatically updated)
  copy of your previous `FILE_SQFS_TBZ` file.

- `MV_FILE_TBZ`

  Here you can define the `mv` command which is used to create
  `FILE_TBZ_OLD`. See `MV_FILE_SQFS`.

- `IGNORETOP`

  This is a list of paths relative to the top-level `$DIRECTORY`
  whose changes (which actually occur in `$DIR_CHANGE`)
  are ignored when __squash_dir__ decides whether the directory
  needs to be re-squashed. So, for example if you define

  `IGNORETOP='\"A \\\"magic\\\" link\" \"subdir/device-*\"'`

  then changes in the files/links/devices/whatever called
  -	`$DIR_CHANGE/A "magic" file`
  -	`$DIR_CHANGE/subdir/device-`_something may follow here_

  will get ignored. Do not use this for directories if you also want to
  ignore the content of the directories - use `IGNOREDIR` for the latter.
  The format of the list is space-separated but quoting is allowed.
  More precisely, the list is first eval'ed, and then each item is
  eval'ed within "..." context (and interpreted as a filenane pattern),
  therefore the included `"` needs to be triple-quoted and the space and `*`
  needs not be quoted if used within \" ... \".

- `IGNORETOPFILE`

  This is like `IGNORETOP`, but it is explicitly checked that the match
  is a file (a link to a file does not count either); those of other
  type are ignored.

- `IGNORETOPDIR`

  This is like `IGNORETOPFILE`, but it is explicitly checked that the
  match is a directory. In this case, also the content of the directory
  is ignored.

- `IGNORE`

  This is like `IGNORETOP` with the difference that the content is not
  a list of names but an expression which is passed to find in an
  eval "..." context.
  Here you can check also for other files which are not in the
  top-level directory. If you use -path, note that the pathname starts
  with `$DIR_CHANGE`, so e.g. to ignore the link `.bad_link` in the
  top-level of `$DIRECTORY`, but only if this is really a link)
  you can define

  `IGNORE='-path "\$DIR_CHANGE"/.bad_link -type l'`

  If your match is a directory and you call `-prune`, then also the
  content of the directory is ignored.

- `IGNOREFILE`

  This is similar to `IGNORE`, but it is additionally (automatically)
  added code for find to check that the match is a file.

- `IGNOREDIR`

  This is similar to `IGNORE`, but it is additionally (automatically)
  added code for find to check that the match is a directory.
  Moreover, in this case also `-prune` is called to ignore the
  content of this directory.

- `IGNORETOUCH`

  This is a list of paths relative to the top-level `$DIRECTORY`
  whose changes (which actually occur in `$DIR_CHANGE`) are ignored,
  provided that the `diff` utility shows that the file was not modified
  compared to the corresponding original file in `$DIR_SQUASH`.
  The format of the list is that of a `case` statement, i.e. you can
  use file globbing and `|` to separate alternatives and have to
  quote `|` or `)` if you use it as symbols. Note that no pruning of
  directories is done, i.e. with each directory also its whole content
  is checked against `IGNORETOUCH`; directories are by definition
  always equal if they existed before.
  __Typical example__:
  ```
  IGNORETOUCH=ls-R
  IGNORETOUCH=$IGNORETOUCH"|tex"
  IGNORETOUCH=$IGNORETOUCH"|tex/generic"
  IGNORETOUCH=$IGNORETOUCH"|tex/generic/config"
  IGNORETOUCH=$IGNORETOUCH"|tex/generic/config/language.dat"
  IGNORETOUCH=$IGNORETOUCH"|tex/generic/config/language.dat.lua"
  IGNORETOUCH=$IGNORETOUCH"|tex/generic/config/language.def"
  ```
  Even if the file `$DIRECTORY/ls-R` was recreated by one of your
  system tools, no re-squashing will be done if the new file is
  identical to the old one and if there were no other changes.
  Note that also parent directories must be explicitly listed to
  ignore the possible changes in them.

- `KEEP`

  If `$KILL_FILE` does not exist but `$DIR_CHANGE` is cleaned without
  re-squashing (this can only happen if no other files than those in
  `IGNORE` or `IGNORETOUCH` were changed)
  then the files in this variable are kept anyway.
  Currently, only files/subdirs of `$DIRECTORY` are supported,
  no deeper nesting is allowed (i.e. you must not use `/` here).
  The format is that of `case`, i.e. you can use wildcards and
  separate several names with `|`. Quoting is of course supported.
  You must not use `)` in the name unless you quote it.

  __Example__: `KEEP=".*|'*)'"` will keep all files/subdirs of the form
  `$DIRECTORY/.`* or `$DIRECTORY/*)`"

- `KILL_NOT`

  If `$KILL_FILE` exists (so that `$DIR_CHANGE` is cleaned without
  re-squashing) then the files in this variable are kept anyway.
  The syntax is the same as that of `KEEP`.

- `ORDER`

  If the variable `DIR_CHANGE` is empty, this variable is ignored.
  Otherwise, its value should be a string consisting of
  all (or some) of the words

  overlayfs aufs unionfs-fuse funionfs unionfs  (*)

  Then the corresponding tool is used to make `DIRECTORY` writable.
  The tools are attempted in the given order: If the first tool
  fails, a warning message is printed, and the next tool is
  attempted and so on. If `ORDER` is empty, it defaults to (*).

- `MAGIC_FILE`

  Normally, if the directory `$DIR_CHANGE` is nonempty on shutdown,
  the _squash_ file and the _tbz_ file are created (and the
  backups are made), and afterwards directory `$DIR_CHANGE` is deleted.
  However, if the file `$MAGIC_FILE` exists during shutdown,
  nothing of these things happens, i.e. the information in directory
  `$DIR_CHANGE` is simply kept for the next start of this script
  (or for your manual interaction).
  In particular, creating the file `$MAGIC_FILE` temporarily, you can
  "delay" the update during shutdown until you delete `$MAGIC_FILE`
  again. This is useful e.g. for `/usr/src/linux` which you usually
  will not want to recompress after recompilation of the kernel.
  If you leave the variable `MAGIC_FILE` empty, it defaults to
  `$DIR_CHANGE/.no-save`.

- `KILL_FILE`

  This is similar to `MAGIC_FILE`, but with the difference that if this
  file exists during shutdown, directory `$DIR_CHANGE` is deleted
  nevertheless; only the files in $KILL_NOT are kept.
  So be very careful when creating this file: It means that your changes
  will be lost completely on shutdown or restart!
  If you leave the variable `KILL_FILE` empty, it defaults to
  `$DIR_CHANGE/.No-save`.

- `THRESHOLD`

  If this variable is a positive number, and directory `$DIR_CHANGE` is not
  larger than `THRESHOLD` kilobytes, then the effect is as if
  `MAGIC_FILE` exists, i.e. the update during shutdown will not
  happen. You can override this with:

- `IGNORE_THRESHOLD`

  If this file exists, then `THRESHOLD` is ignored during
  shutdown. If this file resides in directory `$DIR_CHANGE`, then it is
  removed before the compression. Of you leave `IGNORE_THRESHOLD`
  empty, it defaults to `$DIR_CHANGE/.do-save`.

- `COMPRESSION`

  Specify the compression method used by `mksquashfs`.
  If empty, the default `mksquashfs` algorithm (currently: `gzip`) is used.
  Other possible values are `gzip`, `xz`, `lzo`.
  If this variable is not specified, it defaults to that algorithm which
  is presumably best compressing (which is currently `xz`).

- `MKSQUASHFS`

  These options are used for `mksquashfs` (e.g. `-check_data`).
  The option `-noappend` is used automatically.
  Depending on `VERBOSE_MODE` and `COMPRESSION` also
  the options `-no-progress` or `-comp ...` might be used automatically.

- `VERBOSE_MODE`

  If this variable is

  * `0`

    then `-no-progress` is appended to `mksquashfs` options and
    the output of `mksquashfs` is redirected to `/dev/null`.

  * `1` or `` (empty)

    then stdout of `mksquashfs` is redirected to `/dev/null`
    Usually, this is the same as `0`, only marginally slower.
    However, you might apply a patch for `mksquashfs` to
    redirect the progress bar to stderr.
    This produces the nicest output with no redundant information.

  * `2`
    then `mksquashfs` is called without additional options or
    redirections.

- `MOUNT_AUFS`

  These are additional options used for the mount-command for __aufs__.
  The default is `-o noatime`.
  You might want to add options like `-o rdblk=0 -o rdhash=0`
  which help you if you have setup __aufs__ for userspace (RDU),
  see `man aufs` (e.g. from `sys-fs/aufs*[-util]`) for details.

- `MOUNT_OVERLAYFS`

  These are additional options used for the mount-command for __overlayfs__.
  The default is `-o noatime`.

- `MOUNT_UNIONFS_FUSE`

  These are additional mount options used for __unionfs-fuse__.
  The default is:

  `-o cow -o allow_other -o use_ino -o nonempty -o noatime -o hide_meta_files`

  So if you modify this variable, you should probably include
  these options. Omit them only if you know what you are doing.

- `UNIONFS_FUSE_HIDE`

  This variable is only used in the default value of `MOUNT_UNIONFS_FUSE`.
  If you do not set it, the default is either `-o hide_meta_files` or empty,
  depending on whether __unionfs-fuse__ is new enough.
  If you use __unionfs-fuse__, you might want to set this variable explicitly
  in order to save time for determining whether __unionfs-fuse__ is new
  enough (or if you do not agree with the default).

- `MOUNT_UNIONFS`

  These are additional mount options used for __unionfs__.
  The default is empty.

- `MOUNT_FUNIONFS`

  These are additional mount options used for __funionfs__.
  The default is `-o allow_other -o nonempty`.
  So if you modify this variable, you should probably include these options.
  Omit them only if you know what you are doing.

- `UMOUNT_OPTS`

  These are options which are used for `umount`ing.
  This defaults to `-i` because `/sbin/umount.aufs` causes problems
  in some cases.

- `LAZY_UMOUNT`

  If this variable is unset or _true_, a lazy umount is attempted
  after a failed umount. This means that the chances are good
  that this script will successfully stop even if the directory
  is still in use. However, it might happen that e.g.
  loop devices are not freed correctly.

- `LOCKFILE`

  Since `mount`/`umount` calls cannot properly be done in parallel
  (since apparently they do not properly lock `/etc/mtab`), we use
  `flock` for these calls to create a lockfile (which is never erased)
  to allow `rc_parallel=YES`.
  You can set this variable to the following values:

  1. to a path of the lockfile. The path must be absolute, i.e.
     starting with `/`. It is dangerous to use a user-writable
     directory here (like e.g. `/tmp`).
  2. to the magic value `auto` (or if you do not set this variable):
     In this case the lockfile `/etc/mtab.lock` is used unless
     `/etc/mtab` is a symbolic link. In the latter case the lockfile
     feature is switched off.
  3. In all other cases (e.g. if you set `LOCKFILE=` or `LOCKFILE=no`)
     the lockfile feature is switched off.
