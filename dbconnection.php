<?php
function dbconnection()
{

//     $con = mysqli_connect("localhost", "root", "", "fertismart");
//             return $con;

    $con = mysqli_connect("localhost", "root", "", "fertismart", 3307);
        return $con;

    }
?>