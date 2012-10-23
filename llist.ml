open Lazy
open Util

type 'a llist = Nil | Cons of 'a * 'a llist Lazy.t

let hd = function | Nil -> failwith "hd" | Cons (x, xs) -> x
let tl = function | Nil -> failwith "tl" | Cons (x, xs) -> !$xs

let rec take n l =
  match n, l with
  | 0, _ -> []
  | n, Nil -> []
  | n, Cons (x, xs) -> x :: take (n-1) !$xs

let rec map f = function
  | Nil -> Nil
  | Cons (x, xs) -> Cons (f x, lazy (map f !$xs))

let rec repeat x = Cons (x, lazy (repeat x));;

let rec app xs ys =
  match xs with
  | Nil -> ys
  | Cons (x, xs) -> Cons (x, lazy (app (!$ xs) ys))

let rec combine xs ys =
  match (xs,ys) with 
  | Cons(x,xs),Cons(y,ys) -> Cons((x,y), lazy (combine !$xs !$ys))
  | _ -> Nil

let rec filter f xs =
  match xs with
  | Nil -> Nil
  | Cons(x, xs) when f x -> Cons (x, lazy (filter f !$xs))
  | Cons(x, xs) -> filter f !$xs

let rec concat xss =
  match xss with 
  | Nil -> Nil
  | Cons(Nil, xss') -> concat !$xss'
  | Cons(Cons(x,lazy xs'), xss') -> Cons(x, lazy (concat (Cons(xs', xss'))))

let rec unfoldr f b =
  match f b with
  | Some (a, new_b) -> Cons(a, lazy (unfoldr f new_b))
  | None -> Nil

let continually make =
  let f () = try Some(make (), ()) with _ -> None in
  unfoldr f ()

(* int llist *)
let rec from n = Cons (n, lazy (from (n+1)))


(* llist <--> stream *)
let rec of_stream str =
  try
    Cons (Stream.next str, lazy (of_stream str))
  with
  | Stream.Failure -> Nil

let sllist ?(items:int=20) delim show l =
  let fin = take items l in
  if List.length fin <= items then
    slist delim show fin
  else
    slist delim show fin ^ "..."

(* string -> llist *)
let of_string =
  of_stream $ Stream.of_string

