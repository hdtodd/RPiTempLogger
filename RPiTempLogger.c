/*
RPiTempLogger
Raspberry Pi CPU Core Temperature Logging Program

This program appends datetime-stamped recordings of Raspberry Pi CPU core temperatures as rows 
in a sqlite3 database.  The program uses (creates if necessary) the sqlite3 database, creates
a table for the data if necessary, and appends rows at regular periodic intervals.  Use
sqlite3 to view the data [ $sqlite3 MyPiTemps.db <cr> select * from PiCoreTemps; <cr> ]

Compilation 
  Program compilation/linking requires packages for sqlite3 and libsqlite3-dev
  Use "sudo apt-get install sqlite3 libsqlite3-dev" to install those if you haven't already.
  Connect to install directory and type "$make" to simply compile and link, and then
    "$make install" to move the resulting executable to "/usr/local/bin"
  Compile parameters (define below):
      DelaySec:  time between samplings, in seconds, as an integer [default 300]
      DBName:    path and filename of the database file in which the data will be stored
                 [default is "MyPiTemps.db" in the user's current working directory]
  Or compile with "gcc -o RPiTempLogger -lsqlite3 RPiTempLogger.c"
  
Run as 
  $RPiTempLogger &
to run detached, or include in startup scripts to run as daemon
When the program is running, it doesn't keep the database file open: when the program wakes
up periodically, it samples the data, opens the database, appends the reading, and closes the 
database.  So exposure to table corruption as a result of a Pi restart or crash is minimized.

  Written by HDTodd, Williston Vermont, November, 2015
*/

#ifndef DelaySec
  #define DelaySec 300
#endif
#ifndef DBName
  #define DBName "/var/databases/MyPiTemps.db"
#endif

#include <stdio.h>
#include <stdlib.h>
#include <sqlite3.h>
#include <time.h>

static int callback(void *NotUsed, int argc, char **argv, char **azColName);  // not used at present

void main(int argc, char **argv) {
  sqlite3 *db;             // database handle
  char *zErrMsg = 0,       // returned error message
       *sql,               // sql command string
       outstr[200],        // space for datetime string 
       sqlIns[200];        // space for sql INSERT command
  int rc;                  // result code from sqlite3 function calls

  FILE *temperatureFile;   // Raspbian processor status file
  double T;                // CPU temp

  time_t t;                // structures for creating datetime string
  struct tm *tmp;

  fprintf(stdout,"RPiTempLogger: logging Raspberry Pi CPU Core Temperatures\n");
  // Open or create the database file
  rc = sqlite3_open(DBName, &db);
  if ( rc ) {
    fprintf(stderr, "Can't open or create database %s\n%s\n", DBName, sqlite3_errmsg(db));
    exit(0);
  } else {
    fprintf(stdout, "Opened database %s;\t", DBName);
  };

  // If the table doesn't exist, create it
  sql = "CREATE TABLE if not exists  PiCoreTemps(DateTime TEXT, CPUTemp REAL);";
  rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
  if ( rc != SQLITE_OK ) {
    fprintf(stderr, "\n?RPiTempLogger: Can't open or create database table 'PiCoreTemps'\n");
    fprintf(stderr, "SQL error: %s\n", zErrMsg);
    sqlite3_free(zErrMsg);
    exit(0);
  } else {
    fprintf(stdout, "Table 'PiCoreTemps' opened or created successfully\n");
  };
  sqlite3_close(db); 
  
  /* Now loop forever, sampling and recording temp every "DelaySec" seconds */
  while (1) {
    /* Open database */
    rc = sqlite3_open(DBName, &db);
    if ( rc ) {
      fprintf(stderr, "?RPiTempLogger: Can't open database file '%s'\n%s\n", 
	      DBName, sqlite3_errmsg(db));
      exit(0);
    };

    /* Get CPUTemp */
    temperatureFile = fopen ("/sys/class/thermal/thermal_zone0/temp", "r");
    if ( temperatureFile == NULL ) {
      fprintf(stderr,"? RPiTempLogger can't open temp file!\n");
      T = 0;
    } else {
      fscanf (temperatureFile, "%lf", &T);
      T /= 1000;
      fclose (temperatureFile);
    };

    /* Create DateTime string */
    t = time(NULL);
    tmp = localtime(&t);
    if (tmp == NULL) {
      perror("?RPiTempLogger: localtime retrieval failed!\n");
      exit(EXIT_FAILURE);
    };
    if (strftime(outstr, sizeof(outstr), "%F %T", tmp) == 0) {
      fprintf(stderr, "?RPiTempLogger: strftime returned 0 while formatting time\n");
      exit(EXIT_FAILURE);
    };

    fprintf(stdout, "DateTime: %s\tTemp=%6.2f C\n", outstr, T); 

    /* Create and execute the INSERT with these data values as parameters*/
    sprintf(sqlIns,"INSERT INTO PiCoreTemps (DateTime, CPUTemp) VALUES (\"%s\", %6.2f);\n",
	    outstr, (float) T);
    rc = sqlite3_exec(db, sqlIns, callback, 0, &zErrMsg);
    if ( rc != SQLITE_OK ) {
      fprintf(stderr, "%RPiTempLogger SQL error during row insert: %s\n", zErrMsg);
      fprintf(stderr, "Can't write to database file %s\n", DBName);
      sqlite3_free(zErrMsg);
      exit(EXIT_FAILURE);
    };

    /* Done with the DB for now so close it */
    sqlite3_close(db);

    sleep(DelaySec); // Sleep for a while before repeating
    };
};


static int callback(void *NotUsed, int argc, char **argv, char **azColName){
  int i;
  for (i=0; i<argc; i++) {
    printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
  }
  printf("\n");
  return 0;
}
