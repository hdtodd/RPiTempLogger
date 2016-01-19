<!-- Template for a web site home page that also displays the history of
       CPU core temperatures as a graph
     Uses Google Charts for the display
     Written by HDTodd, January, 2016
       borrowing heavily from numerous prior authors 
-->
<?php  //Parameters
$HISTORY="'-48 hours'";	   //period of time over which to display temps
$DB_LOC="/var/databases/"; //location of the sqlite3 db
$DB_NAME="MyPiTemps.db";   //name of sqlite3 db
?>

<?php
// First, PHP code to populate an array with the [time,temp] data pairs
//   and create a JSON array for the Javascript below

$db = new PDO('sqlite:' . $DB_LOC . $DB_NAME) 
      	  or die('Cannot open database ' . $DB_NAME);
$query = "SELECT * FROM PiCoreTemps WHERE DateTime>datetime('now','-48 hours')"; 
foreach ($db->query($query) as $row) 
  $chart_array[]=array((string)$row['DateTime'],(real)$row['CPUTemp']); 
//Now convert to a JSON array for the Javascript
$temp_data=json_encode($chart_array);
//For debugging, uncomment the following
//echo $temp_data;
?>

<!-- Here's the HTML code for the site, followed by the JS component for the chart -->
<html>
<center>
<h1>The <?php echo gethostname() ?> Web Site</h1>
<p>This is the default web page for the <?php echo gethostname() ?> Web server.</p>
<p>The web server software is running to offer specialized web-based services.</p>
<p>It does not (yet) offer pretty pages or photos.</p>
  <head>
    <!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>

    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = new google.visualization.DataTable();
        data.addColumn("string","DateTime");
	data.addColumn("number","Temp (C)");
        data.addRows( <?php echo $temp_data ?>);
        var options = {
          title: 'Temp (C)'
        };
        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
  </head>
  <body>
    <!--Div that will hold the line graph-->
    <h2><?php echo gethostname() ?> CPU Core Temperature Chart</h2>
    <div id="chart_div" style="width: 900px; height: 500px;"></div>
  </body>
</center>
</html>
