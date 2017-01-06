<?php
## STANFORD WILDCARD #######################################################


// The command you just typed in shell.
$command = $_SERVER['argv'];

// Look at every argument...
foreach ($command as $arg){
  // There aren't many cases where there are '.'...
  // 0 => "@sse"
  // 1 => "ds_history"
  $test = explode('.',$arg);

  // $first = "@sse"
  // $test[0] = "ds_history"
  $first = array_shift($test);

  switch($first) {
    case "@local":
      // Set the project to be whatever the alias was
      $project_alias = str_replace('@', '', $arg);
      $project_name = array_pop($test);
      $root = '$BASEDIR/stanford_travisci_scripts/'. $project_name;
      break;
  }
}

// project alias; this will be sse.ds_foo, uat.ds_foo, or ppl.dp_sunetid
$aliases[$project_alias] = array(
  'remote-host' => $remote_host,
  'remote-user' => $remote_user,
  'root' => $root,
  'uri' => 'default',
  'ssh-options' => $ssh_options,
  'path-aliases' => array(
    '%dump-dir' => '/tmp/',
  ),
);
