;; Tyrel Hiebert
;; V00898825
;; Programming Languages, Homework 5 version 1.1
#lang racket

(provide (all-defined-out)) ;; so we can put tests in a second file

;; definition of structures for MUPL programs - Do NOT change
(struct var  (string) #:transparent)  ;; a variable, e.g., (var "foo")
(struct int  (num)    #:transparent)  ;; a constant number, e.g., (int 17)
(struct add  (e1 e2)  #:transparent)  ;; add two expressions
(struct ifgreater (e1 e2 e3 e4)    #:transparent) ;; if e1 > e2 then e3 else e4
(struct fun  (nameopt formal body) #:transparent) ;; a recursive(?) 1-argument function
(struct call (funexp actual)       #:transparent) ;; function call
(struct mlet (var e body) #:transparent) ;; a local binding (let var = e in body)
(struct apair (e1 e2)     #:transparent) ;; make a new pair
(struct fst  (e)    #:transparent) ;; get first part of a pair
(struct snd  (e)    #:transparent) ;; get second part of a pair
(struct aunit ()    #:transparent) ;; unit value -- good for ending a list
(struct isaunit (e) #:transparent) ;; evaluate to 1 if e is unit else 0

;; a closure is not in "source" programs; it is what functions evaluate to
(struct closure (env fun) #:transparent)


;; Problem A

;; CHANGE (put your solutions here)
(define (mupllist->racketlist lst)
  (if (aunit? lst)
    '()
    (cons
      (cond
        [(apair? (apair-e1 lst)) (mupllist->racketlist (apair-e1 lst))]
        [#t (apair-e1 lst)]
      )
      (mupllist->racketlist (apair-e2 lst))
    )
  )
)

(define (racketlist->mupllist lst)
  (if (null? lst)
    (aunit)
    (apair
      (cond
        [(list? (car lst)) (racketlist->mupllist (car lst))]
        [#t (car lst)]
      )
      (racketlist->mupllist (cdr lst))
    )
  )
)


;; Problem B

;; lookup a variable in an environment
;; Do NOT change this function
(define (envlookup env str)
  (cond [(null? env) (error "unbound variable during evaluation" str)]
        [(equal? (car (car env)) str) (cdr (car env))]
        [#t (envlookup (cdr env) str)]))

;; Do NOT change the two cases given to you.
;; DO add more cases for other kinds of MUPL expressions.
;; We will test eval-under-env by calling it directly even though
;; "in real life" it would be a helper function of eval-exp.
(define (eval-under-env e env)
  (cond 
    [(var? e)
      (envlookup env (var-string e))
    ]

    [(add? e)
      (let
        (
          [v1 (eval-under-env (add-e1 e) env)]
          [v2 (eval-under-env (add-e2 e) env)]
        )
      (if (and (int? v1) (int? v2))
        (int (+ (int-num v1) (int-num v2)))
        (error "MUPL addition applied to non-number"))
      )
    ]

    ;; "CHANGE" add more cases here
    ;; one for each type of expression

    [(int? e) e]

    [(ifgreater? e)
      (let 
        (
          [v1 (eval-under-env (ifgreater-e1 e) env)]
          [v2 (eval-under-env (ifgreater-e2 e) env)]
        )
        (if (and (int? v1) (int? v2))
          (if (> (int-num v1) (int-num v2))
            (eval-under-env (ifgreater-e3 e) env)
            (eval-under-env (ifgreater-e4 e) env)
          )
          (error "MUPL ifgreater applied to non-number")
        )
      )
    ]

    [(apair? e)
      (let
        (
          [v1 (eval-under-env (apair-e1 e) env)]
          [v2 (eval-under-env (apair-e2 e) env)]
        )
        (apair v1 v2)
      )
    ]

    [(fst? e)
      (let
        ([p (eval-under-env (fst-e e) env)])
        (if (apair? p)
          (apair-e1 p)
          (error "MUPL fst applied to non-pair")
        )
      )
    ]

    [(snd? e)
      (let
        ([p (eval-under-env (snd-e e) env)])
        (if (apair? p)
          (apair-e2 p)
          (error "MUPL snd applied to non-pair")
        )
      )
    ]

    [(isaunit? e)
      (if (aunit? (eval-under-env (isaunit-e e) env))
        (int 1)
        (int 0)
      )
    ]

    [(aunit? e) e]

    [(mlet? e)
      (let
        (
          [env2 (cons (cons (mlet-var e) (eval-under-env (mlet-e e) env)) env)]
        )
        (eval-under-env (mlet-body e) env2)
      )
    ]

    [(fun? e)
      (closure env e)
    ]

    [(call? e)
      (let
        (
          [c (eval-under-env (call-funexp e) env)]
          [p (eval-under-env (call-actual e) env)]
        )
        (if (closure? c)
          (let*
            (
              [f (closure-fun c)]
              [cenv (closure-env c)]
              [fname (fun-nameopt (closure-fun c))]
              [pname (fun-formal (closure-fun c))]
              [fbody (fun-body (closure-fun c))]
              [fnameandbody (cons fname c)]
              [pnameandbody (cons pname p)]
            )
            (eval-under-env
              fbody
              (if fname
                (cons pnameandbody (cons fnameandbody cenv))
                (cons pnameandbody cenv)
              )
            )
          )
          (error "MUPL call applied to non-function")
        )
      )
    ]

    [#t (error (format "bad MUPL expression: ~v" e))]
  )
)

;; Do NOT change
(define (eval-exp e)
  (eval-under-env e null))


;; Problem C

(define (ifaunit e1 e2 e3)
  (mlet
    "v1"
    e1
    (ifgreater
      (isaunit (var "v1"))
      (int 0)
      e2
      e3
    )
  )
)

(define (mlet* lstlst e)
  (if (null? lstlst)
    e
    (mlet
      (caar lstlst)
      (cdar lstlst)
      (mlet* (cdr lstlst) e)
    )
  )
)

(define (ifeq e1 e2 e3 e4)
  (mlet
    "_x"
    e1
    (mlet
      "_y"
      e2
      (ifgreater (var "_x") (var "_y") e4
        (ifgreater (var "_y") (var "_x") e4 e3)
      )
    )
  )
)


;; Problem D

(define mupl-map
  (fun #f "f"
    (fun "mupl-map" "lst"
      (ifgreater                                    ;; use ifgreater as if to check for end of list
        (isaunit (var "lst"))                       ;; base case condition
        (int 0)
        (aunit)                                     ;; base case
        (apair                                      ;; build new list
          (call (var "f") (fst (var "lst")))        ;; call f on head element
          (call (var "mupl-map") (snd (var "lst"))) ;; recursively call mupl-map on tail
        )
      )
    )
  )
)
;; this binding is a bit tricky. it must return a function.
;; the first two lines should be something like this:
;;
;;   (fun "mupl-map" "f"    ;; it is  function "mupl-map" that takes a function f
;;       (fun #f "lst"      ;; and it returns an anonymous function
;;          ...
;;
;; also remember that we can only call functions with one parameter, but
;; because they are curried instead of
;;    (call funexp1 funexp2 exp3)
;; we do
;;    (call (call funexp1 funexp2) exp3)

(define mupl-mapAddN
  (mlet
    "map"
    mupl-map
    (fun #f "i"
      (call
        (var "map")                            ;; return map
        (fun #f "a" (add (var "a") (var "i"))) ;; with this anon addition function
      )
    )
  )
)