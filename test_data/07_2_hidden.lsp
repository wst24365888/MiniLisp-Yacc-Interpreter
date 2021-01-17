(define a 10)
(define b 20)
(print-num
  (if (= 2 ((fun (x) (+ x 1)) 1)) 1 0))
