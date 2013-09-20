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

let () = 
  generate_latex () 
