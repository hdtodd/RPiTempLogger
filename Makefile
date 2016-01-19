#Makefile for RPiTempLogger, a Raspberry Pi TempLogger
#Program to log Pi core temps to a sqlite3 database
#Developed on OSX 10.11, November, 2015
#HDTodd, Williston VT/Bozeman MT
#
#  CHANGE NAME in DBName to path and filename desired
#

PROJ = RPiTempLogger
CC = gcc
DBName = MyPiTemps.db
CFLAGS = -DDBName=\"${DBName}\" -lsqlite3
LDFLAGS = -lsqlite3
OBJS = RPiTempLogger.o

all:	${PROJ}

.SUFFIXES: .c

.o:	.c

.c.o:	
	$(CC) $(CFLAGS) -c $<

${PROJ}: ${OBJS}
	$(CC) -o $@ $(LDFLAGS) ${OBJS}

clean:
	/bin/rm -f *.o *~

install:
	mv ${PROJ} /usr/local/bin/

really-clean: 
	/bin/rm -f *~ *.o ${DBName} $(PROJ) 
