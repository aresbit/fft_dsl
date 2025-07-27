
type complex = { re: float; im: float }

let complex_zero = { re = 0.0; im = 0.0 }
let complex_one = { re = 1.0; im = 0.0 }

let add_complex c1 c2 = { re = c1.re +. c2.re; im = c1.im +. c2.im }
let sub_complex c1 c2 = { re = c1.re -. c2.re; im = c1.im -. c2.im }
let mul_complex c1 c2 = 
  { re = c1.re *. c2.re -. c1.im *. c2.im;
    im = c1.re *. c2.im +. c1.im *. c2.re }

let twiddle_factor n k =
  let angle = -2.0 *. Float.pi *. (float_of_int k) /. (float_of_int n) in
  { re = cos angle; im = sin angle }

let print_complex c = Printf.printf "%g + %gi" c.re c.im


let fft4 input =
  let n = Array.length input in
  let output = Array.copy input in
  
  if n = 1 then (
    output.(0) <- input.(0);
    output
  ) else (
    (* 初始化临时变量 *)
    let w1h1 = ref complex_zero in
    let w0h0 = ref complex_zero in
    let w1 = ref complex_zero in
    let w0 = ref complex_zero in
    let h1 = ref complex_zero in
    let h0 = ref complex_zero in
    let g1 = ref complex_zero in
    let g0 = ref complex_zero in
    let odd1 = ref complex_zero in
    let odd0 = ref complex_zero in
    let even1 = ref complex_zero in
    let even0 = ref complex_zero in
    
    (* 执行用户定义的逻辑 *)
    even0 := input.(0);
    even1 := input.(2);
    odd0 := input.(1);
    odd1 := input.(3);
    g0 := (add_complex (!even0) (!even1));
    g1 := (sub_complex (!even0) (!even1));
    h0 := (add_complex (!odd0) (!odd1));
    h1 := (sub_complex (!odd0) (!odd1));
    w0 := (twiddle_factor 4 (0));
    w1 := (twiddle_factor 4 (1));
    w0h0 := (mul_complex (!w0) (!h0));
    w1h1 := (mul_complex (!w1) (!h1));
    output.(0) <- (add_complex (!g0) (!w0h0));
    output.(1) <- (add_complex (!g1) (!w1h1));
    output.(2) <- (sub_complex (!g0) (!w0h0));
    output.(3) <- (sub_complex (!g1) (!w1h1));
    
    output
  )


let () =
  if Array.length Sys.argv < 2 then begin
    Printf.printf "Usage: %s [real1 imag1 real2 imag2 ...]\\n" Sys.argv.(0);
    exit 1
  end;
  
  let args = Array.sub Sys.argv 1 (Array.length Sys.argv - 1) in
  
  let input = Array.init (Array.length args / 2) (fun i ->
    let real = float_of_string args.(2 * i) in
    let imag = float_of_string args.(2 * i + 1) in
    { re = real; im = imag }
  ) in
  
  Printf.printf "Input:\\n";
  Array.iteri (fun i c -> 
    Printf.printf "[%d]: %g %c %gi\\n" i c.re (if c.im >= 0.0 then '+' else '-') (abs_float c.im)
  ) input;
  
  let result = fft4 input in
  
  Printf.printf "\\nFFT Result:\\n";
  Array.iteri (fun i c -> 
    Printf.printf "[%d]: %g %c %gi\\n" i c.re (if c.im >= 0.0 then '+' else '-') (abs_float c.im)
  ) result
