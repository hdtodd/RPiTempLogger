#Makefile for RPiTempLogger, a Raspberry Pi TempLogger
#Program to log Pi core temps to a sqlite3 database
#HDTodd, Williston VT/Bozeman MT,  November, 2015
#
#CHANGE database location and name in DBPath and DBName below if you want
#  BUT IF YOU CHANGE THE PATH, MODIFY "MkDataDir.bsh" accordingly

PROJ = RPiTempLogger
#  If you change the destination for the executable here, change it
#    in the /etc/rc.local system startup file, too.
BINPATH = /usr/local/bin/
CC = gcc
DBPATH = /var/databases/
DBNAME = MyPiTemps.db
CFLAGS = -DDBName=\"${DBPATH}${DBNAME}\" -lsqlite3
LDFLAGS = -lsqlite3
OBJS = RPiTempLogger.o

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
	mv ${PROJ} ${BINPATH}

clean:
	/bin/rm -f *~ *.o

really-clean: 
	/bin/rm -f *~ *.o  $(PROJ) ${BINPATH}${PROJ}

#WARNING: this one deletes the database file!
scrupulously-clean:
	/bin/rm -f *~ *.o  $(PROJ) ${BINPATH}${PROJ} ${DBPATH}${DBNAME}
