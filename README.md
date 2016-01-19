RPiTempLogger
Raspberry Pi CPU Core Temperature Logging Program

This program appends datetime-stamped recordings of Raspberry Pi CPU core temperatures as rows 
in an sqlite3 database.  The program uses (creates if necessary) the sqlite3 database, creates
a table for the data if necessary, and appends rows at regular periodic intervals.  Use
sqlite3 to view the data [ $sqlite3 MyPiTemps.db <cr> select * from PiCoreTemps; <cr> ]

Compilation 
  Program compilation/linking requires packages for sqlite3 and libsqlite3-dev
  Use "sudo apt-get install sqlite3 libsqlite3-dev" to install those if you haven't already.
  Connect to install directory and type "$make" to simply compile and link, and then
    "$make install" to move the resulting executable to "/usr/local/bin"
  Compile parameters:
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

You can generate a graphical representation of the data using the python program CPUTemps.py,
or you can copy that file to /var/www/cgi-bin/ and use it as a displayable web page
on your Pi's web site if you're running Apache.

  Written by HDTodd, Williston Vermont, November, 2015
