let generate_latex () = 
  let inv = new ToLatex.toLatex in
  List.iter (fun (path, title) -> 
    inv # start_chapter title ;
    let chan = open_in ("chapters/" ^ path) in 
    let lexbuf = Lexing.from_channel chan in 
    Lex.latex inv lexbuf ;
    close_in chan 
  ) All.all ;
  print_endline "out/book.tex" ;
  let chan = open_out "out/book.tex" in
  output_string chan (inv # contents) ;
  close_out chan 

let generate_epub () = 

  (* OPF file (includes manifest) *) 
  let chan = open_out "epub/content.opf" in
  output_string chan ToEpub.opf_head ;
  List.iter (fun (path,_) -> output_string chan
    (Printf.sprintf "<item id=\"%s\" href=\"%s.htm\" media-type=\"application/xhtml+xml\"/>"
       path path)) All.all ;
  output_string chan ToEpub.opf_mid ; 
  List.iter (fun (path,_) -> output_string chan
    (Printf.sprintf "<itemref idref=\"%s\"/>" path)) All.all ;
  output_string chan ToEpub.opf_foot ; 
  close_out chan ;

  (* NCX file (table of contents) *)

  let chan = open_out "epub/toc.ncx" in
  output_string chan ToEpub.ncx_head ;
  let i = ref 1 in
  List.iter (fun x -> output_string chan (ToEpub.ncx_item (!i) x) ; incr i) All.all;
  output_string chan ToEpub.ncx_foot ;
  close_out chan ;

  (* Generate actual chapters *) 

  List.iter (fun (path, name) -> 
    let inv = new ToEpub.toEpub in
    inv # start_chapter name ;
    let chan = open_in ("chapters/" ^ path) in 
    let lexbuf = Lexing.from_channel chan in 
    Lex.latex inv lexbuf ;
    close_in chan ;
    print_endline ("epub/"^path^".htm") ;
    let chan = open_out ("epub/"^path^".htm") in
    output_string chan (inv # contents) ;
    close_out chan     
  ) All.all 


let () = 
  if Sys.argv.(1) = "--latex" then begin 
    generate_latex () ;
  end else if Sys.argv.(1) = "--ePub" then begin 
    generate_epub () ;
  end 
