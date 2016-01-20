#Makefile for RPiTempLogger, a Raspberry Pi TempLogger
#Program to log Pi core temps to a sqlite3 database
#HDTodd, Williston VT/Bozeman MT,  November, 2015
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
#	 d.  Create an entry in /etc/rc.local, just before
#		'exit 0', to run the logging program as
#		a daemon upon reboot
#    3.  make clean: cleanup of files in this directory
#    4.  make really-clean: clean + remove executable and
#	 daemon startup line in /etc/rc.local
#    5.  make scrupulously-clean: really-clean + remove database file
#
#There are a number of parameters here for location of the database,
# location of the executable, etc.  If you change any of them, check
# carefully to verify that the changes worked correctly -- they haven't
# been tested extensively


CC = gcc
PROJ = RPiTempLogger
#  If you change the destination for the executable here, change it
#    in the /etc/rc.local system startup file, too, if you've
#    had to manually set up the daemon startup commands.  Changed
#    automatically if you're using using dependency based boot sequencing
#    and the code in 'make install' below is working correctly.
BINPATH = /usr/local/bin/
#  'escaped' version of BINPATH for use in sed command
EBINPATH = \/usr\/local\/bin\/
#  'RCLOCAL' below  is the boot startup file for localized installs of daemons.
#  If your system isn't using dependency based boot sequencing,
#  you'll need to modify the code in 'install' below.  The goal is to put
#  a line like '/usr/local/bin/RPiTempLogger &' into a startup
#  script so that the executable is started up automatically at boot time.
#  Don't forget to remove that line upon de-install if you edit manually.
RCLOCAL = /etc/rc.local
#CHANGE database location and name in DBPATH and DBNAME below if you want
#  BUT IF YOU CHANGE THE PATH, MODIFY "MkDataDir.bsh" accordingly
DBPATH = /var/databases/
DBNAME = MyPiTemps.db
CFLAGS = -DDBName=\"${DBPATH}${DBNAME}\" -lsqlite3
LDFLAGS = -lsqlite3
OBJS = ${PROJ}.o

all:	${PROJ}

.SUFFIXES: .c

.o:	.c

.c.o:	
	$(CC) $(CFLAGS) -c $<

${PROJ}: ${OBJS}
	$(CC) -o $@ $(LDFLAGS) ${OBJS}

install:
#	Create the database directory if necessary, and
#	  check to see if we can move the executable to 
#	  the destination directory; then move it
	./MkDataDir.bsh
	cp ${PROJ} ${BINPATH}
#	Copy the graphing files to the web site
#	If you don't already have an index.php in /var/www,
#	  manually rename the index-RTL file there to be index.php;
#	  If you don't have an index.html file there,
#	  this will become your web home page
	cp CPUTemps.py /var/www/cgi-bin/CPUTemps.py
	cp index.php /var/www/index-RTL.php
#	Make sure there is only one entry in the boot startup file
#	'/etc/rc.local' by deleting any prior entries, in case
#	we've been installed before.  Ignore path in prior installs
#	since there might have been a path change in subsequent
#	'make'-'make install' invocations.
	sed -i -e '/${PROJ} \&/d' ${RCLOCAL}
#	Now make an entry in the boot startup file so the
#	logger runs as a daemon using the path from this install
#	This entry goes just before the "exit 0" statement at the end
	sed -i -e 's/^exit 0/${EBINPATH}${PROJ} \&\nexit 0/' ${RCLOCAL}

clean:
	/bin/rm -f *~ *.o ${PROJ}

really-clean: 
	/bin/rm -f *~ *.o  ${PROJ} ${BINPATH}${PROJ}
	sed -i -e '/${PROJ} &/d' ${RCLOCAL}

#WARNING: this one deletes the database file!
scrupulously-clean:
	/bin/rm -f *~ *.o  $(PROJ) ${BINPATH}${PROJ} ${DBPATH}${DBNAME}
	sed -i -e '/${PROJ} &/d' ${RCLOCAL}
