#lang racket

;;; Tyrel Hiebert
;;; V00898825
;;; CSC 330 Programming Languages

(provide (all-defined-out)) ;; so we can put tests in a second file


(define (sequence l h s)
  (if (> l h)
    null
    (cons l (sequence (+ l s) h s))
  )
)


(define (string-append-map xs suffix)
  (map (lambda (x) (string-append x suffix)) xs)
)


(define (list-nth-mod xs n)
  (if (< n 0)
    (error "list-nth-mod: negative number")
    (if (null? xs)
      (error "list-nth-mod: empty list")
      (list-ref xs (remainder n (length xs)))
    )
  )
)


(define (stream-for-n-steps s n)
  (if (= 0 n)
  null
  (cons (car (s)) (stream-for-n-steps (cdr (s)) (- n 1))))
)


(define funny-number-stream
  (letrec (
    [f (lambda (x)
      (if (zero? (remainder x 5)) 
      (cons (- x) (lambda () (f (+ x 1))))
      (cons x (lambda () (f (+ x 1))))
      )
    )
    ]) (lambda () (f 1))
  )
)


(define cat-then-dog
  (letrec (
    [f (lambda (x)
      (if (string=? x "cat.jpg") 
      (cons "cat.jpg" (lambda () (f "dog.jpg")))
      (cons "dog.jpg" (lambda () (f "cat.jpg")))
      )
    )
    ]) (lambda () (f "cat.jpg"))
  )
)


(define (stream-add-zero s)
  (letrec (
    [f (lambda (s) 
      (cons (cons 0 (car (s))) (lambda () (f (cdr (s)))))
    )
    ]) (lambda () (f s))
  )
)


(define (cycle-lists xs ys)
  (letrec (
    [f (lambda (n xs ys) 
      (cons (cons (list-nth-mod xs n) (list-nth-mod ys n)) (lambda () (f (+ n 1) xs ys)))
    )
    ]
  ) (lambda () (f 0 xs ys))
  )
)


(define (vector-assoc v vec)
  (letrec (
    [f (lambda (val i arr)
      (if (< i (vector-length arr))
        (if (pair? (vector-ref arr i))
          (if (= val (car(vector-ref arr i)))
            (vector-ref arr i)
            (f val (+ i 1) arr) ;; recursive call if val not equal
          )
          (f val (+ i 1) arr)   ;; recursive call if not pair
        )
        #f ;; return false if end of vector
      )
    )
    ]
  ) (f v 0 vec)
  )
)


(define (cached-assoc xs n)
  (let* (
    [cache (make-vector n #f)]
    [idx 0]
    [f (lambda (v)
      (let ([ans (vector-assoc v cache)])
        (if ans ;; if answer was in cache
          ans   ;; return ans
          (let ([new_ans (assoc v xs)])
            (if new_ans
              (begin
                (vector-set! cache (remainder idx n) new_ans) ;; update cache
                (set! idx (+ idx 1)) ;; iterate cache index
                new_ans ;; return answer
              )
              #f ;; return false if not found
            )
          )
        )
      )
    )]
  )
  f  ; return f that accepts v
  )
)


(define-syntax while-less
  (syntax-rules (do)
    [(while-less e1 do e2)
      (letrec (
        [v1 (if (procedure? e1) (e1) e1)]
        [f (lambda () 
          (if (>= e2 v1)
            #t
            (f)
          )
        )]
      )(f)) ; 
    ]
  )
)