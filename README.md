# RPiTempLogger
## Raspberry Pi CPU Core Temperature Logging Program

### Description

This program appends datetime-stamped recordings of Raspberry Pi CPU core temperatures as rows 
in a sqlite3 database.  The program uses (creates if necessary) the sqlite3 database, creates
a table for the data if necessary, and appends rows at regular periodic intervals.  Use
sqlite3 to view the data

    $sqlite3 MyPiTemps.db
    >select * from PiCoreTemps

The package also includes a php page suitable as the foundation for a web site home page that displays
a graphical presentation of the time/temp data, and the package includes a python program
that will generate an html file for the graphical presentation.  

[Sample page from index.php](https://github.com/hdtodd/RPiTempLogger/blob/master/RPiTL.jpg)

### Setup

The data logger will acquire data, and you can obtain formatted text reports on that data, with just the sqlite3
packages installed (described below).

If you intend to display the results graphically, you'll need to either be running Apache2 (if you want to 
display the graphs on your own web pages) or you'll generate an html file with the Python program included here and
then view the html file with a browser.  If you haven't done so, you might install Apache2 in preparation for using
this package.  The Apache2 installation on Raspbian is well documented and won't be repeated here.

The PHP code that pulls the data from the sqlite3 database and formats it for the Google Charts graphing
system requires the php-sqlite3 module.  Even if you have Apache2 running and have installed the sqlite3
packages, you might not have installed the interface module.  Prepare for graphical display by installing that
package: `sudo apt-get install php5-sqlite`.

The graphing programs use the
Google Charts system for doing the actual graphing, and that system in invoked at the time
those programs are run, so no package installation is required for those.  The Makefile installation is set to
install the logging program as a daemon so that it is automatically started at boot time.

### Compilation 

  1. Program compilation/linking requires packages for sqlite3 and libsqlite3-dev
  2.  Use `sudo apt-get install sqlite3 libsqlite3-dev` to install those if you haven't already.
  3.  Connect to install directory and type `make` to simply compile and link to create the executable data logger. Or compile with `gcc -o RPiTempLogger -lsqlite3 RPiTempLogger.c`
  4.  Type `sudo make install` to move the resulting executable to "/usr/local/bin", set it up
    to start as a daemon at reboot, and copy the graphing code to "/var/www"

Review "Makefile" for more detailed instructions, including options for changing the names and locations of files.

### Parameterization

The C program contains several compile parameters that can be changed, too:
  * DelaySec:  time between samplings, in seconds, as an integer [default 300]
  * DBName:    path and filename of the database file in which the data will be stored [default is "MyPiTemps.db" in "/var/databases", which is created upon install]

### Testing

Run as `RPiTempLogger` to test the program.  It starts by sampling an printing the temperature and adding the sample data to the sqlite3 database; it repeats that (every 5 minutes, by default) until terminated.  Run as `RPiTempLogger &` to run detached, which it will do until a reboot.   Or include the command `RPiTempLogger` in a startup script to run as daemon automatically whenever the system is rebooted; that command is added to "/etc/rc.local" by `make install`.

### Routine Operation and Displaying Data

When the program is running, it doesn't keep the database file open: when the program wakes
up periodically, it samples the data, opens the database, appends the sample reading, and closes the 
database.  Exposure to table corruption as a result of a Pi restart or crash is minimized.

You can generate a graphical representation of the data using the python program CPUTemps.py
that is copied during install to /var/www/cgi-bin/ and use it as a displayable web page
on your Pi's web site if you're running Apache.  The file index-RTL.php is copied to /var/www
as a prototype for a web site home page that will display the data graphically.

### Author

Written by HDTodd, Williston Vermont, November, 2015

