#lang racket

(provide (all-defined-out))

(define (mymap f)
  (lambda (lst)
    (letrec
      (
        [g (lambda (l) 
          (if (null? l)
            null
            (cons (f (car l)) (g (cdr l)))
          )
        )]
      )
      (g lst)
    )
  )
)

(define (plusone x)
  (+ 1 x)
)

((mymap plusone) (cons 1 (cons 2 (cons 3 null))))
;;; (mymap h (cons 1 (cons 2 (cons 3 null))))

(define (myfilter f)
  (lambda (lst)
    (letrec
      (
        [g (lambda (l)
          (cond
            [(null? l) null]
            [(list? l)
              (if (f (car l))
                (cons (car l) (g (cdr l)))
                (g (cdr l))
              )
            ]
          )
        )]
      )
      (g lst)
    )
  )
)

(define (even x)
  (zero? (remainder x 2))
)

((myfilter even) (cons 1 (cons 2 (cons 3 (cons 4 null)))))

(define (myfold f)
  (lambda (init)
    (lambda (lst)
      (letrec (
        [g (lambda (l acc)
          (cond
            [(null? l) acc]
            [(list? l)
              (g (cdr l) (f acc (car l)))
            ]
          )
        )]
      )(g lst init))
    )
  )
)

(define (sum acc x)
  (+ acc x)
)

(((myfold sum) 0) (cons 1 (cons 2 (cons 3 (cons 4 null)))))

(cons (cons 1 (cons 2 (cons 3 null))) 1)