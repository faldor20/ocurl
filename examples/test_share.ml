(*
 * test_share.ml
 *
 * Copyright (c) 2024, OCurl contributors
 *
 * Test for the curl share interface
 *)

let test_share_creation () =
  let share = Curl.share_init () in
  Curl.share_cleanup share;
  Printf.printf "✓ Share creation and cleanup test passed\n"

let test_share_options () =
  let share = Curl.share_init () in
  try
    (* Test setting each share option *)
    Curl.share_setopt share (Curl.CURLSHOPT_SHARE Curl.CURLSHOPT_SHARE_COOKIE);
    Curl.share_setopt share (Curl.CURLSHOPT_SHARE Curl.CURLSHOPT_SHARE_DNS);
    Curl.share_setopt share (Curl.CURLSHOPT_SHARE Curl.CURLSHOPT_SHARE_SSL_SESSION);
    Curl.share_setopt share (Curl.CURLSHOPT_SHARE Curl.CURLSHOPT_SHARE_CONNECT);
    
    (* Test unsetting options *)
    Curl.share_setopt share (Curl.CURLSHOPT_UNSHARE Curl.CURLSHOPT_SHARE_COOKIE);
    Curl.share_setopt share (Curl.CURLSHOPT_UNSHARE Curl.CURLSHOPT_SHARE_DNS);
    
    Curl.share_cleanup share;
    Printf.printf "✓ Share options test passed\n"
  with
  | e ->
      Curl.share_cleanup share;
      Printf.printf "✗ Share options test failed: %s\n" (Printexc.to_string e)

let test_share_with_curl_handle () =
  let share = Curl.share_init () in
  try
    (* Configure share *)
    Curl.share_setopt share (Curl.CURLSHOPT_SHARE Curl.CURLSHOPT_SHARE_DNS);
    
    (* Create a curl handle and associate it with the share *)
    let h = Curl.init () in
    Curl.set_url h "https://httpbin.org/status/200";
    Curl.setopt h (Curl.CURLOPT_SHARE share);
    
    (* Set up a simple write function to discard data *)
    Curl.set_writefunction h (fun _ -> 0);
    
    (* Test that the handle works with the share *)
    (try
      Curl.perform h;
      Printf.printf "✓ Curl handle with share test passed\n"
    with
    | Curl.CurlException (code, errno, msg) ->
        Printf.printf "✗ Curl handle with share test failed: %s (code=%d, errno=%d)\n" 
          msg (Curl.int_of_curlCode code) errno
    | e ->
        Printf.printf "✗ Curl handle with share test failed: %s\n" (Printexc.to_string e)
    );
    
    Curl.cleanup h;
    Curl.share_cleanup share
  with
  | e ->
      Curl.share_cleanup share;
      Printf.printf "✗ Share with curl handle test failed: %s\n" (Printexc.to_string e)

let run_all_tests () =
  Printf.printf "Running curl share interface tests...\n\n";
  
  test_share_creation ();
  test_share_options ();
  test_share_with_curl_handle ();
  
  Printf.printf "\nAll share tests completed.\n"

let () =
  Curl.global_init Curl.CURLINIT_GLOBALALL;
  
  try
    run_all_tests ();
    Curl.global_cleanup ()
  with
  | e ->
      Printf.printf "Fatal error: %s\n" (Printexc.to_string e);
      Curl.global_cleanup () 