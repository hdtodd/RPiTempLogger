#Makefile for RPiTempLogger, a Raspberry Pi TempLogger
#Program to log Pi core temps to a sqlite3 database
#2018.03.18	Updated Makefile to set up as a systemd service
#2015.11.19	First release via Github
#Author: HDTodd, Williston VT/Bozeman MT
#
#This makefile does a full install of the Raspberry Pi
# temperature logging system:
#    1.  make: Compile and link the C-language logging code
#    2.  make install: (must use 'sudo make install') 
#	 a.  Confirm existence or create database directory
#		as /var/databases  (database file is
#		automatically created by logging program if
#		needed)
#	 b.  Move the executable to /usr/local/bin
#	 c.  To provide for graphical display of collected data,
#		copy the index.php file to /var/www and
#		copy the CPUTemps.py file to /var/www/cgi-bin	
#	 d.  Copy a .service file to unit .service directory
#		and set up systemd service
#	     (rc.local system startup commented out in install: )
#    3.  make clean: cleanup of files in this directory
#    4.  make really-clean: clean + remove executable
#    5.  make uninstall: really-clean + remove executable, web files,
#	   & database file
#
#There are a number of parameters here for location of the database,
# location of the executable, etc.  If you change any of them, check
# carefully to verify that the changes worked correctly -- they haven't
# been tested extensively

CC = gcc
PROJ = RPiTempLogger
RPT = CheckTemp.sqlite3
# DEFAULT to Raspbian systemctl location and directory for unit .service files
SYSCTL = /bin/systemctl
UNITDIR= /lib/systemd/system/
# openSUSE systemctl & .service locations
ifdef SUSE
SYSCTL = /usr/bin/systemctl
UNITDIR= /etc/systemd/user/
endif

#  If you change BINDIR, the destination for the executable here, change it
#    in the /etc/rc.local system startup file, too, if you've
#    had to manually set up the daemon startup commands.  Changed
#    automatically if you're using using dependency based boot sequencing
#    and the code in 'make install' below is working correctly.
BINDIR = /usr/local/bin/
VDIR   = /var/
WWWDIR = ${VDIR}www/
PHPDIR = ${WWWDIR}cgi-bin/
DBDIR  = ${VDIR}databases/
DBNAME = MyPiTemps.db

#  'escaped' version of BINDIR for use in sed command in case you use rc.local
EBINDIR = \/usr\/local\/bin\/
#  'RCLOCAL' below  is the boot startup file for localized installs of daemons.
#  If your system isn't using dependency based boot sequencing,
#  you'll need to modify the code in 'install' below.  The goal is to put
#  a line like '/usr/local/bin/RPiTempLogger &' into a startup
#  script so that the executable is started up automatically at boot time.
#  Don't forget to remove that line upon de-install if you edit manually.
RCLOCAL = /etc/rc.local

CFLAGS = -DDBName=\"${DBDIR}${DBNAME}\" -lsqlite3
LDFLAGS = -lsqlite3
OBJS = ${PROJ}.o

all:	${PROJ}

.SUFFIXES: .c

.o:	.c

.c.o:	
	$(CC) $(CFLAGS) -c $<

${PROJ}: ${OBJS}
	$(CC) -o $@ ${OBJS} $(LDFLAGS)

install:
#Check that we have root access to install components.
#  Create the database directory if necessary, and
#  check to see if we can move the executable to 
#  the destination directory; then move it
#If DBDIR exists, we don't worry about writing it since root will be running the
#  RPiTempLogger executable and should have privs to write that directory and will
#  create the database file if needed.  But we do need to make sure the directory exists.
#Create the directories for the web-based graphing programs if necessary
#If systemd is in use, make sure RPiTempLogger service is stopped first
#  then install files and enable+start service
#Copy the graphing files to the web site
#If you don't already have an index.php in /var/www,
#  manually rename the index-RTL file there to be index.php;
#  If you don't have an index.html file there, this will become your web home page.

	@if  [ `id -u` != 0 ] ; then \
		echo "You don't have root privileges needed to install ${PROJ}" ; \
		echo "Try 'sudo make install'" ; \
	else \
		echo "Verify that required directories are accessible" ; \
		if  [ ! -w ${BINDIR} ] ; then \
			echo "${BINDIR} either doesn't exist or can't be written" ; \
			echo "Correct and try 'sudo make install' again" ; \
		else \
			echo "${BINDIR} exists and can be written" ; \
			fi ; \
		if  [ ! -w ${VDIR}   ] ; then \
			echo "${VDIR} either doesn't exist or can't be written" ; \
			echo "Correct and try 'sudo make install' again" ; \
		else \
			echo "${VDIR} exists and can be written" ; \
			fi ; \
		if [ -w ${VDIR}   ] && [ ! -d ${DBDIR}  ] ; then \
			mkdir ${DBDIR} ; \
			echo "Created ${DBDIR}" ; \
			fi ; \
		if [ -w ${VDIR}   ] && [ ! -d ${WWWDIR} ] ; then \
			mkdir ${WWWDIR} ; \
			echo "Created ${WWWDIR}" ; \
			fi ; \
		if [ -w ${WWWDIR} ] && [ ! -d ${PHPDIR} ] ; then \
			mkdir ${PHPDIR} ; \
			echo "Created ${PHPDIR}" ; \
			fi ; \
		echo "Create data and web directories if necessary" ; \
		if [ `${SYSCTL} is-system-running` != "running" ] && [ `${SYSCTL} is-system-running` != "degraded" ]; then \
			echo "systemd not running" ; \
			echo "Either install and start systemd or manually install rc.local" ; \
		else \
			echo "Installing systemd boot-time startup of ${PROJ}" ; \
			if [ `${SYSCTL} is-active ${PROJ}` = "active" ] ; then \
				echo "Stopping ${PROJ} service" ; \
				${SYSCTL} stop ${PROJ}.service ; \
				fi ; \
			cp ${PROJ} ${BINDIR} ; \
			cp ${RPT} ${BINDIR} ; \
			cp ${PROJ}.service ${UNITDIR} ; \
			${SYSCTL} enable ${PROJ}.service ; \
			${SYSCTL} start ${PROJ}.service ; \
			echo "Enabled and started ${PROJ} service" ; \
			if [ -w ${PHPDIR} ] ; then cp CPUTemps.py ${PHPDIR} ; fi ; \
			if [ -w ${WWWDIR} ] ; then cp index.php ${WWWDIR}/index-RTL.php ; fi ; \
			fi ; \
		fi

#	ARCHIVAL: the following is detritus left from old rc.local installation
#	If you're using rc.local and not systemd, these may come in handy.
#	Make sure there is only one entry in the boot startup file
#	'/etc/rc.local' by deleting any prior entries, in case
#	we've been installed before.  Ignore path in prior installs
#	since there might have been a path change in subsequent
#	'make'-'make install' invocations.
#		sed -i -e '/${PROJ} \&/d' ${RCLOCAL} ; \
#	Now make an entry in the boot startup file so the
#	logger runs as a daemon using the path from this install
#	This entry goes just before the "exit 0" statement at the end
#		sed -i -e 's/^exit 0/${EBINDIR}${PROJ} \&\nexit 0/' ${RCLOCAL} ; \

clean:
	/bin/rm -f *~ *.o ${PROJ}

really-clean: 
	/bin/rm -f *~ *.o  ${PROJ} ${BINDIR}${PROJ}

#WARNING: this one deletes the database file!
uninstall:
	/bin/rm -f *~ *.o  $(PROJ) ${BINDIR}${PROJ} ${DBDIR}${DBNAME}
	if [ `${SYSCTL} is-system-running` = "running" ] || [ `${SYSCTL} is-system-running` = "degraded" ]; then \
		echo "Uninstalling systemd boot-time startup of ${PROJ}" ; \
		${SYSCTL} stop ${PROJ}.service ; \
		${SYSCTL} disable ${PROJ}.service ; \
		/bin/rm -f ${BINDIR}${PROJ} ; \
		/bin/rm -f ${UNITDIR}${PROJ}.service ; \
		/bin/rm -f ${PHPDIR}CPUTemps.py ; \
		/bin/rm -f ${WWWDIR}/index-RTL.php ; \
		fi
#And, again, useful if you're using rc.local rather than systemd
#	if [ -e ${RCLOCAL} ] ; \
#	then sed -i -e '/${PROJ} &/d' ${RCLOCAL} ; \
#	fi

