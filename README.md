# RPiTempLogger
## Raspberry Pi CPU Core Temperature Logging Program

This program appends datetime-stamped recordings of Raspberry Pi CPU core temperatures as rows 
in an sqlite3 database.  The program uses (creates if necessary) the sqlite3 database, creates
a table for the data if necessary, and appends rows at regular periodic intervals.  Use
sqlite3 to view the data

    $sqlite3 MyPiTemps.db
    >select * from PiCoreTemps

The package also includes a php page suitable as the foundation for a web site home page that displays
a graphical presentation of the time/temp data, and the package includes a python program
that will generate an html file for the graphical presentation.  The installation is set to
install the logging program as a daemon so that it is automatically started at boot time.

Compilation 
1.  Program compilation/linking requires packages for sqlite3 and libsqlite3-dev
2.  Use `sudo apt-get install sqlite3 libsqlite3-dev` to install those if you haven't already.
3.  Connect to install directory and type `make` to simply compile and link to create the executable data logger. Or compile with `gcc -o RPiTempLogger -lsqlite3 RPiTempLogger.c`
4.  Type `sudo make install` to move the resulting executable to "/usr/local/bin", set it up
    to start as a daemon at reboot, and copy the graphing code to "/var/www"

Review "Makefile" for more detailed instruction, including options for changing the names and locations of files.

The C program contains several ompile parameters that can be changed, too:
      DelaySec:  time between samplings, in seconds, as an integer [default 300]
      DBName:    path and filename of the database file in which the data will be stored
                 [default is "MyPiTemps.db" in "/var/databases", which is created upon install]

Run as   `RPiTempLogger &` to run detached, or include in startup scripts to run as daemon, which is done as part of install.

When the program is running, it doesn't keep the database file open: when the program wakes
up periodically, it samples the data, opens the database, appends the reading, and closes the 
database.  So exposure to table corruption as a result of a Pi restart or crash is minimized.

You can generate a graphical representation of the data using the python program CPUTemps.py
that is copied during install to /var/www/cgi-bin/ and use it as a displayable web page
on your Pi's web site if you're running Apache.  The file index-RTL.php is copied to /var/www
as a prototype for a web site home page that will display the data graphically.

  Written by HDTodd, Williston Vermont, November, 2015

[Sample page from index.php](https://github.com/hdtodd/RPiTempLogger/blob/master/RPiTL.jpg)
