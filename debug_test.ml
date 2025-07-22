
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



let rec test input =
  let n = Array.length input in
  let output = Array.copy input in
  
  (* Base case *)
  if n = 1 then (

    output
  ) else (
    (* Recursive case - Radix-2 Cooley-Tukey *)
    let half_n = n / 2 in
    let even = Array.init half_n (fun i -> input.(2 * i)) in
    let odd = Array.init half_n (fun i -> input.(2 * i + 1)) in
    
    let fft_even = test even in
    let fft_odd = test odd in
    
    (* Combine results *)
    for k = 0 to half_n - 1 do
      let w = twiddle_factor n k in
      let t = mul_complex w fft_odd.(k) in
      output.(k) <- add_complex fft_even.(k) t;
      output.(k + half_n) <- sub_complex fft_even.(k) t;
    done;
    

    output
  )


let () =
  (* 示例使用 *)
  let test_input = [|
    { re = 1.0; im = 0.0 };
    { re = 0.0; im = 0.0 };
    { re = 1.0; im = 0.0 };
    { re = 0.0; im = 0.0 };
  |] in
  
  Printf.printf "Input:\n";
  Array.iteri (fun i c -> 
    Printf.printf "[%d]: %g + %gi\n" i c.re c.im
  ) test_input;
  
  let result = test test_input in
  
  Printf.printf "\nFFT Result:\n";
  Array.iteri (fun i c -> 
    Printf.printf "[%d]: %g + %gi\n" i c.re c.im
  ) result