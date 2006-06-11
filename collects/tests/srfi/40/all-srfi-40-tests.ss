(module all-srfi-40-tests mzscheme
  
  (require (planet "test.ss" ("schematics" "schemeunit.plt" 1 1))
           (lib "40.ss" "srfi"))
  (provide all-srfi-40-tests)
  
  (define from0
    (let loop ((x 0))
      (stream-delay
       (stream-cons x (loop (+ x 1))))))
  (define (take5 s)
    (stream-unfoldn
     (lambda (x)
       (let ((n (car x)) (s (cdr x)))
         (if (zero? n)
             (values 'dummy '())
             (values
              (cons (- n 1) (stream-cdr s))
              (list (stream-car s))))))
     (cons 5 s)
     1))
  (define (finite-stream->list s)
    (if (stream-null? s)
        null
        (cons (stream-car s)
              (finite-stream->list (stream-cdr s)))))
  
  (define all-srfi-40-tests
    (make-test-suite 
     "All tests for SRFI 40"
     (make-test-case
      "stream?"
      (assert-true
       (stream? stream-null))
      (assert-true
       (stream? (stream-cons 'a stream-null)))
      (assert-false
       (stream? 3)))
     (make-test-case
      "stream-null?"
      (assert-true
       (stream-null? stream-null))
      (assert-false
       (stream-null? (stream-cons 'a stream-null)))
      (assert-false
       (stream-null? 3)))
     (make-test-case
      "stream-pair?"
      (assert-false
       (stream-pair? stream-null))
      (assert-true
       (stream-pair? (stream-cons 'a stream-null)))
      (assert-false
       (stream-pair? 3)))
     (make-test-case
      "stream"
      (assert-true
       (stream-null? (stream)))
      (assert-equal? (finite-stream->list (stream 'a (+ 3 4) 'c))
                     '(a 7 c)))
     (make-test-case
      "stream-unfoldn"
      (assert-equal? (finite-stream->list (take5 from0))
                     '(0 1 2 3 4)))
     (make-test-case
      "stream-for-each"
      (assert-equal?
       (let ((l '()))
         (stream-for-each (lambda (n) (set! l (cons n l)))
                          (take5 from0))
         l)
       '(4 3 2 1 0)))
     (make-test-case
      "stream-map"
      (assert-equal? (finite-stream->list (take5 (stream-map (lambda (x) (+ x x)) from0)))
                     '(0 2 4 6 8))
      (assert-equal? (finite-stream->list (stream-map + (stream 1 2 3) (stream 4 5 6)))
                     '(5 7 9))
      (assert-equal? (finite-stream->list
                      (stream-map (lambda (x) (expt x x))
                                  (stream 1 2 3 4 5)))
                     '(1 4 27 256 3125)))
     (make-test-case
      "stream-filter"
      (assert-true
       (stream-null? (stream-filter odd? stream-null)))
      (assert-equal? (finite-stream->list (take5 (stream-filter odd? from0)))
                     '(1 3 5 7 9))))))