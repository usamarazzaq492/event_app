<?php

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;

if (!function_exists('sendMail')) {
  function sendMail($emailTo, $subject, $message)
  {

      // Additional headers
      $headers = "MIME-Version: 1.0\r\n";
      $headers .= "Content-type: text/html; charset=iso-8859-1\r\n";

      // Send mail
      return mail($emailTo, $subject, $message, $headers);
  }
}