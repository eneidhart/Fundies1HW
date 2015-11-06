;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname TetrisFun_updated) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

;; Problem Set 8
;; Neidhart, Ethan
;; Unaka, Muigai

;; Problem 4 - Tetris

;; This code has been divided into 5 sections:
;; - The main function
;; - 4 big-bang functions called by the main,
;;   each with their own set of helping functions

;; Constants

;; - The size of each grid block 
(define GRID-SIZE 25)

;; - The number of blocks in the grid height
(define GRID-HEIGHT 20)

;; - The number of blocks in the grid width
(define GRID-WIDTH 10)

;; - Our empty scene
(define GRID (overlay/align
              "left" "middle"
              (rectangle (* GRID-SIZE GRID-WIDTH)
                         (* GRID-SIZE GRID-HEIGHT)
                         "outline" "black")
              (empty-scene 
               (* GRID-SIZE GRID-WIDTH 1.5) 
               (* GRID-SIZE GRID-HEIGHT))))

;; World Definitions

;; A Block is a (make-block Number Number Color)
(define-struct block (x y color))

;; A Tetra is a (make-tetra Posn BSet Ghost)
;; The center point is the point around which the tetra rotates
;; when it spins.
;; - A Ghost is a (make-tetra Posn BSet) where:
;;   - The blocks are transparent
;;   - The position of the blocks are identical to those of the
;;     world's tetra, moved down all the way
;;   - A Ghost's tetra is unused and is therefore an empty
(define-struct tetra (center blocks ghost))

;; A txt is a (make-txt String Number Number)
;; Represents the occurrence of the given text at the given location,
;; in computer-graphics coordinates.
(define-struct txt [content x y])

;; A Set of Blocks (BSet) is one of:
;; - empty
;; - (cons Block BSet)
;; Order does not matter.

;; A Pile is a BSet which represents
;; the pile of blocks at the bottom of the screen.

;; A Text is an Image of a string

;; A Direction is one of:
;; - "left" 
;; - "right" 
;; - "a" (counterclockwise)
;; - "s" (clockwise)
;; - "down" (automatically puts piece on bottom)
;; - "up" (clockwise rotation for 1 handed playing)


;; A World is a (make-world Tetra Pile Number)
(define-struct world (tetra pile score))

;; - Constant Tetra definitions:

;; tetra-O
(define BLOCK-O1 (make-block 
                  (* 4 GRID-SIZE) (* -1 GRID-SIZE) "green"))
(define BLOCK-O2 (make-block 
                  (* 5 GRID-SIZE) (* -1 GRID-SIZE) "green"))
(define BLOCK-O3 (make-block 
                  (* 4 GRID-SIZE) (* -2 GRID-SIZE) "green"))
(define BLOCK-O4 (make-block
                  (* 5 GRID-SIZE) (* -2 GRID-SIZE) "green"))
(define BLOCKS-O (list BLOCK-O1 BLOCK-O2 BLOCK-O3 BLOCK-O4))
(define TETRA-O
  (make-tetra (make-posn (* 4.5 GRID-SIZE) (* -1.5 GRID-SIZE))
              BLOCKS-O
              empty))

;; tetra-I
(define BLOCK-I1 (make-block 
                  (* 3 GRID-SIZE) (* -1 GRID-SIZE) "blue"))
(define BLOCK-I2 (make-block 
                  (* 4 GRID-SIZE) (* -1 GRID-SIZE) "blue"))
(define BLOCK-I3 (make-block 
                  (* 5 GRID-SIZE) (* -1 GRID-SIZE) "blue"))
(define BLOCK-I4 (make-block
                  (* 6 GRID-SIZE) (* -1 GRID-SIZE) "blue"))
(define BLOCKS-I (list BLOCK-I1 BLOCK-I2 BLOCK-I3 BLOCK-I4))
(define TETRA-I
  (make-tetra (make-posn (* 4 GRID-SIZE) (* -1 GRID-SIZE))
              BLOCKS-I
              empty))

;; tetra-L
(define BLOCK-L1 (make-block
                  (* 3 GRID-SIZE) (* -1 GRID-SIZE) "purple"))
(define BLOCK-L2 (make-block
                  (* 4 GRID-SIZE) (* -1 GRID-SIZE) "purple"))
(define BLOCK-L3 (make-block
                  (* 5 GRID-SIZE) (* -1 GRID-SIZE) "purple"))
(define BLOCK-L4 (make-block
                  (* 5 GRID-SIZE) (* -2 GRID-SIZE) "purple"))
(define BLOCKS-L (list BLOCK-L1 BLOCK-L2 BLOCK-L3 BLOCK-L4))
(define TETRA-L
  (make-tetra (make-posn (* 4 GRID-SIZE) (* -1 GRID-SIZE))
              BLOCKS-L
              empty))

;; tetra-J
(define BLOCK-J1 (make-block
                  (* 3 GRID-SIZE) (* -1 GRID-SIZE) "cyan"))
(define BLOCK-J2 (make-block
                  (* 4 GRID-SIZE) (* -1 GRID-SIZE) "cyan"))
(define BLOCK-J3 (make-block
                  (* 5 GRID-SIZE) (* -1 GRID-SIZE) "cyan"))
(define BLOCK-J4 (make-block
                  (* 3 GRID-SIZE) (* -2 GRID-SIZE) "cyan"))
(define BLOCKS-J (list BLOCK-J1 BLOCK-J2 BLOCK-J3 BLOCK-J4))
(define TETRA-J
  (make-tetra (make-posn (* 4 GRID-SIZE) (* -1 GRID-SIZE))
              BLOCKS-J
              empty))

;; tetra-T
(define BLOCK-T1 (make-block
                  (* 3 GRID-SIZE) (* -1 GRID-SIZE) "orange"))
(define BLOCK-T2 (make-block
                  (* 4 GRID-SIZE) (* -1 GRID-SIZE) "orange"))
(define BLOCK-T3 (make-block
                  (* 5 GRID-SIZE) (* -1 GRID-SIZE) "orange"))
(define BLOCK-T4 (make-block
                  (* 4 GRID-SIZE) (* -2 GRID-SIZE) "orange"))
(define BLOCKS-T (list BLOCK-T1 BLOCK-T2 BLOCK-T3 BLOCK-T4))
(define TETRA-T
  (make-tetra (make-posn (* 4 GRID-SIZE) (* -1 GRID-SIZE))
              BLOCKS-T
              empty))

;; tetra-Z
(define BLOCK-Z1 (make-block
                  (* 3 GRID-SIZE) (* -2 GRID-SIZE) "pink"))
(define BLOCK-Z2 (make-block
                  (* 4 GRID-SIZE) (* -1 GRID-SIZE) "pink"))
(define BLOCK-Z3 (make-block
                  (* 5 GRID-SIZE) (* -1 GRID-SIZE) "pink"))
(define BLOCK-Z4 (make-block
                  (* 4 GRID-SIZE) (* -2 GRID-SIZE) "pink"))
(define BLOCKS-Z (list BLOCK-Z1 BLOCK-Z2 BLOCK-Z3 BLOCK-Z4))
(define TETRA-Z
  (make-tetra (make-posn (* 4 GRID-SIZE) (* -1 GRID-SIZE))
              BLOCKS-Z
              empty))

;; tetra-S
(define BLOCK-S1 (make-block
                  (* 3 GRID-SIZE) (* -1 GRID-SIZE) "red"))
(define BLOCK-S2 (make-block
                  (* 4 GRID-SIZE) (* -1 GRID-SIZE) "red"))
(define BLOCK-S3 (make-block
                  (* 5 GRID-SIZE) (* -2 GRID-SIZE) "red"))
(define BLOCK-S4 (make-block
                  (* 4 GRID-SIZE) (* -2 GRID-SIZE) "red"))
(define BLOCKS-S (list BLOCK-S1 BLOCK-S2 BLOCK-S3 BLOCK-S4))
(define TETRA-S
  (make-tetra (make-posn (* 4 GRID-SIZE) (* -1 GRID-SIZE))
              BLOCKS-S
              empty))

;; Custom loop function
;; Applies f to item until pred is true
;; [X -> X], [X -> Boolean], X -> X
(define (while-apply f pred item)
  (cond[(pred item) item]
       [else (while-apply f pred (f item))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;             MAIN             ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Launches the game from a given world
;; World -> World
(define (main w)
  (big-bang w
            [to-draw draw-world]
            [on-tick move-world .5]
            [on-key shift-piece]
            [stop-when overflow?]))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;          DRAW WORLD          ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; to-draw function, Draws the world onto the scene
;; World -> Image
(define (draw-world w)
  (draw-tetra (world-tetra w)
              (draw-tetra (tetra-ghost (world-tetra w))
                          (draw-blocks (world-pile w) (draw-score (world-score w) GRID)))))

;; Draws a tetra on a scene
;; Tetra, Image -> Image
(define (draw-tetra tetra scene)
  (draw-blocks (tetra-blocks tetra) scene))

;; Draws pile, Helper function for draw-tetra
;; Draws each block of a BSet
;; BSet, Image -> Image
(define (draw-blocks blocks scene)
  ; block -> posn
  ; makes a posn out of a blocks x and y
  (local [(define (return-posn block)
            (make-posn (block-x block) (block-y block)))]
    (place-images/align (map (λ (color) (overlay (square 25 "outline" "black")
                                                 (square 25 "solid" color)))
                             (map block-color blocks))
                        (map return-posn blocks)
                        "left" "top" scene)))

(check-expect (draw-blocks BLOCKS-O GRID)
              (place-images/align (list (overlay
                                         (square 25 "outline" "black")
                                         (square 25 "solid" "green"))
                                        (overlay
                                         (square 25 "outline" "black")
                                         (square 25 "solid" "green"))
                                        (overlay
                                         (square 25 "outline" "black")
                                         (square 25 "solid" "green"))
                                        (overlay
                                         (square 25 "outline" "black")
                                         (square 25 "solid" "green")))
                                  (list (make-posn 100 -25)
                                        (make-posn 125 -25)
                                        (make-posn 100 -50)
                                        (make-posn 125 -50))
                                  "left" "top" GRID))

;; Draws Text on a scene
;; Number, Image -> Image
(define (draw-score score scene)
  (place-image (string->text (number->string score))
               312.5 50
               scene))

(check-expect (draw-score 0 GRID)
              (place-image (text "0" 20 "black")
                           312.5 50 GRID))
(check-expect (draw-score 12 GRID)
              (place-image (text "12" 20 "black")
                           312.5 50 GRID))

;; Turns a string into an Image of the string
;; String -> Text (... Text is an Image)
(define (string->text txt)
  (text txt 20 "black"))

(check-expect (string->text "0") (text "0" 20 "black"))
(check-expect (string->text "score") (text "score" 20 "black"))
(check-expect (string->text "test") (text "test" 20 "black"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;          MOVE WORLD          ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; on-tick function, creates a new world
;; which is affected by the passage of time
;; - moves the Tetra down, or
;; - adds Tetra to the pile, makes new Tetra
;; World -> World
;; Explanation: If the Tetra hits the bottom (bottom edge or top edge of pile),
;;              creates a random new tetra, adds the old tetra to the pile,
;;              and increases the score.  Otherwise, moves the Tetra down.
(define (move-world w)
  (if (hit-bottom? (tetra-blocks (move-down (world-tetra w))) (world-pile w))
      (make-world (new-tetra (random 7) (grow-pile (world-pile w) (tetra-blocks (world-tetra w)))) 
                  (grow-pile (world-pile w) (tetra-blocks (world-tetra w)))
                  (score (world-score w)))
      (make-world (move-down (world-tetra w)) (world-pile w)
                  (world-score w))))

;; Moves the Tetra down by one grid-unit.
;; Tetra -> Tetra
(define (move-down tetra)
  (make-tetra (make-posn 
               (posn-x (tetra-center tetra))
               (+ (posn-y (tetra-center tetra)) GRID-SIZE))
              (move-down-blocks (tetra-blocks tetra))
              (tetra-ghost tetra)))

;; Helper function for move-down.
;; Moves a BSet down by one grid-unit.
;; BSet -> BSet
(define (move-down-blocks blocks)
  (local [(define (move-down-block block)
            (make-block (block-x block)
                        (+ (block-y block) GRID-SIZE)
                        (block-color block)))]
    (map move-down-block blocks)))

;; Returns a new Tetra of the specified type.
;; Also creates the Tetra's Ghost (not defined for constants)
;; Number -> Tetra
(define (new-tetra type pile)
  (cond[(= type 0)
        (ghost-tetra TETRA-O pile)]
       [(= type 1)
        (ghost-tetra TETRA-I pile)]
       [(= type 2)
        (ghost-tetra TETRA-L pile)]
       [(= type 3)
        (ghost-tetra TETRA-J pile)]
       [(= type 4)
        (ghost-tetra TETRA-T pile)]
       [(= type 5)
        (ghost-tetra TETRA-Z pile)]
       [(= type 6)
        (ghost-tetra TETRA-S pile)]))

;; Determines if the line that contains the given block is full
;; Pile, Number -> Boolean
(define (full-line? pile a-block)
  (= (length (filter (λ (block) (= (block-y a-block) (block-y block))) pile)) 10))

;; Adds a BSet to a Pile
;; Removes full lines created by the addition of a new BSet
;; Pile, BSet -> Pile
(define (grow-pile pile blocks)
  (local [(define (line-remover grown-pile added-blocks)
            (cond[(cons? added-blocks)
                  (if (full-line? grown-pile (first added-blocks))
                      (line-remover
                       (append (filter (λ (pile-block)
                                         (> (block-y pile-block) (block-y (first added-blocks))))
                                       grown-pile)
                               (move-down-blocks (filter (λ (pile-block)
                                                           (< (block-y pile-block) (block-y (first added-blocks))))
                                                         grown-pile)))
                       (rest added-blocks))
                      (line-remover grown-pile (rest added-blocks)))]
                 [(empty? added-blocks) grown-pile]))]
    (if (ormap (λ (block) (full-line? (append blocks pile) block)) blocks)
        (line-remover (append blocks pile) blocks)
        (append blocks pile))))


;; Makes a txt containing the user's score determined by pile size,
;; at the correct location for a score.
;; Pile -> txt
(define (score current-score)
  (+ 4 current-score))

;; Determines if a set of blocks is overlapping with the pile,
;; or has passed the lower bound of the grid.
;; BSet, Pile -> Boolean
(define (hit-bottom? blocks pile)
  (ormap (λ (block) (or (in-pile? block pile)
                        (> (block-y block) (* GRID-SIZE 19)))) blocks))

;; Helper function for hit-bottom?
;; Determines if a block is overlapping with the pile
;; Block, Pile -> Boolean
(define (in-pile? block pile)
  (local [(define (same-position? block1 block2)
            (and (= (block-x block1) (block-x block2))
                 (= (block-y block1) (block-y block2))))]
    (ormap (λ (b) (same-position? block b)) pile)))

;; Moves a Tetra as far down as it can go
;; Tetra, Pile -> Tetra
(define (move-down-bottom tetra pile)
  (while-apply move-down
               (λ (a-tetra)
                 (hit-bottom? (tetra-blocks (move-down a-tetra)) pile))
               tetra))

;; Given any Tetra, returns the same Tetra, but with a ghost underneath
;; Tetra -> Tetra
(define (ghost-tetra tetra pile)
  (make-tetra (tetra-center tetra)
              (tetra-blocks tetra)
              (move-down-bottom (make-tetra (tetra-center tetra)
                                            (seethru (tetra-blocks tetra))
                                            empty)
                                pile)))

;; Colors a set of blocks light gray (for the ghost)
;; BSet -> BSet
(define (seethru blocks)
  (map (λ (block) (make-block (block-x block)
                              (block-y block)
                              "LightGray"))
       blocks))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;          SHIFT PIECE          ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; World, Key -> World
;; Shifts Tetra left, right, clockwise or counterclockwise
;; based on key-event
;; Only makes a new world if the key pressed is a direction
(define (shift-piece w d)
  (if (or (string=? "left" d)
          (string=? "right" d)
          (string=? "a" d)
          (string=? "s" d)
          (string=? "down" d)
          (string=? "up" d))
      (make-world (shift-piece-help (world-tetra w) (world-pile w) d)
                  (world-pile w)
                  (world-score w))
      w))


;; Helper function for shift-piece
;; Determines if direction is for moving sideways, rotating, or putting piece directly on bottom
;; Tetra, Pile, direction -> Tetra
(define (shift-piece-help tetra pile d)
  (cond[(or (string=? "left" d) (string=? "right" d))
        (move-side tetra pile d)]
       [(or (string=? "a" d) (string=? "s" d) (string=? "up" d))
        (tetra-rotate tetra pile d)]
       [(string=? "down" d)
        (move-down-bottom tetra pile)]))

;; Helper function for shift-piece-help
;; Moves a Tetra left or right when legal to do so
;; Tetra, Pile, direction -> Tetra
;; Explanation: If moving the Tetra left or right will not move it out of bounds,
;;              and moving it left or right will not move it into the pile,
;;              the Tetra will be moved.  Otherwise, the Tetra will remain
;;              in the same place.
(define (move-side tetra pile d)
  (if (and (not (hit-sides? (move-blocks (tetra-blocks tetra) d)))
           (not (hit-pile? (move-blocks (tetra-blocks tetra) d) pile)))
      (cond[(string=? "left" d)
            (ghost-tetra (make-tetra (make-posn (- (posn-x (tetra-center tetra)) GRID-SIZE)
                                                (posn-y (tetra-center tetra)))
                                     (move-blocks (tetra-blocks tetra) d)
                                     empty)
                         pile)]
           [(string=? "right" d)
            (ghost-tetra (make-tetra (make-posn (+ (posn-x (tetra-center tetra)) GRID-SIZE)
                                                (posn-y (tetra-center tetra)))
                                     (move-blocks (tetra-blocks tetra) d) empty)
                         pile)])
      tetra))

;; Helper function for move-side
;; Moves a BSet in a given direction (left or right)
;; BSet, direction -> BSet
(define (move-blocks blocks d)
  (local [(define (move-block a-block)
            (cond[(string=? "left" d)
                  (make-block (- (block-x a-block) GRID-SIZE)
                              (block-y a-block) (block-color a-block))]
                 [(string=? "right" d)
                  (make-block (+ (block-x a-block) GRID-SIZE)
                              (block-y a-block) (block-color a-block))]))]
    (map (λ (block) (move-block block)) blocks)))

;; Helper function for shift-piece-help
;; Rotates a Tetra in a given direction (cw or ccw)
;; Tetra, Pile, direction -> Tetra
;; Explanation: If rotating the tetra in the given direction would cause
;;              the Tetra to hit the Pile, does not rotate the Tetra.
;;              If rotating the Tetra causes the Tetra to be out of bounds
;;              on the left side, rotates it and moves it right until it is
;;              back in bounds.
;;              If rotating the Tetra causes it to be out of bounds on the
;;              right side, rotates it and moves it left until it is in bounds.
;;              If none of the above is true, simply rotates the Tetra.
(define (tetra-rotate tetra pile d)
  (cond[(hit-pile? (rotate-blocks (tetra-blocks tetra) (tetra-center tetra) d) pile)
        tetra]
       [(hit-left? (rotate-blocks (tetra-blocks tetra) (tetra-center tetra) d))
        (put-right (ghost-tetra (make-tetra (tetra-center tetra)
                                            (rotate-blocks (tetra-blocks tetra) (tetra-center tetra) d)
                                            empty)
                                pile)
                   pile)]
       [(hit-right? (rotate-blocks (tetra-blocks tetra) (tetra-center tetra) d))
        (put-left (ghost-tetra (make-tetra (tetra-center tetra)
                                           (rotate-blocks (tetra-blocks tetra) (tetra-center tetra) d)
                                           empty)
                               pile)
                  pile)]
       [else (ghost-tetra (make-tetra (tetra-center tetra)
                                      (rotate-blocks (tetra-blocks tetra) (tetra-center tetra) d)
                                      empty)
                          pile)]))

;; Helper funciton for tetra-rotate
;; Rotates a BSet about a Posn
;; BSet, Posn, direction -> BSet
(define (rotate-blocks blocks center d)
  (local [(define (block-rotate block)
            (cond[(string=? "a" d)
                  (block-rotate-ccw center block)]
                 [(or (string=? "s" d) (string=? "up" d))
                  (block-rotate-cw center block)]))]
    (map (λ (block) (block-rotate block)) blocks)))

;; Helper function for block-rotate
;; Rotate the block 90 clockwise around the posn.
;; block-rotate-ccw : Posn Block -> Block
(define (block-rotate-cw ctr blk)
  (make-block (+ (posn-x ctr)
                 (- (posn-y ctr)
                    (block-y blk)))
              (+ (posn-y ctr)
                 (- (block-x blk)
                    (posn-x ctr)))
              (block-color blk)))

;; Helper function for block-rotate
;; Rotate the block 90 counter-clockwise around the posn.
;; block-rotate-ccw : Posn Block -> Block
(define (block-rotate-ccw ctr blk)
  (block-rotate-cw ctr 
                   (block-rotate-cw ctr
                                    (block-rotate-cw ctr blk))))

;; Determines if blocks are out of bounds
;; BSet -> Boolean
(define (hit-sides? blocks)
  (ormap (λ (block) (or (< (block-x block) (* 0 GRID-SIZE))
                        (> (block-x block) (* 9 GRID-SIZE))))
         blocks))

;; Determines if blocks are out of bounds to the left
;; BSet -> Boolean
(define (hit-left? blocks)
  (ormap (λ (block) (< (block-x block) (* 0 GRID-SIZE))) blocks))

;; Determines if blocks are out of bounds to the right
;; BSet -> Boolean
(define (hit-right? blocks)
  (ormap (λ (block) (> (block-x block) (* 9 GRID-SIZE))) blocks))

;; Determines if a set of blocks overlaps the pile.
;; BSet -> Boolean
(define (hit-pile? blocks pile)
  (ormap (λ (block) (in-pile? block pile)) blocks))

;; If tetra is out of bounds to the left, move right until in bounds
;; Tetra, Pile -> Tetra
(define (put-right tetra pile)
  (while-apply (λ (a-tetra)
                 (ghost-tetra
                  (make-tetra (make-posn (+ (posn-x (tetra-center a-tetra)) GRID-SIZE)
                                         (posn-y (tetra-center a-tetra)))
                              (move-blocks (tetra-blocks a-tetra) "right") empty) pile))
               (λ (a-tetra) (not (hit-left? (tetra-blocks a-tetra))))
               tetra))

;; If tetra is out of bounds to the right, move left until in bounds
;; Tetra, Pile -> Tetra
(define (put-left tetra pile)
  (while-apply (λ (a-tetra)
                 (ghost-tetra
                  (make-tetra (make-posn (- (posn-x (tetra-center a-tetra)) GRID-SIZE)
                                         (posn-y (tetra-center a-tetra)))
                              (move-blocks (tetra-blocks a-tetra) "left") empty) pile))
               (λ (a-tetra) (not (hit-right? (tetra-blocks a-tetra))))
               tetra))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;           OVERFLOW           ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Determines if the grid is overflowed with blocks
;; Does the pile extend above the upper bound of the grid?
;; World -> Boolean
(define (overflow? w)
  (local [(define (pile-overflow? pile)
            (ormap (λ (pile-block) (< (block-y pile-block) 0)) pile))]
    (pile-overflow? (world-pile w))))

(check-expect (overflow? (make-world TETRA-O empty "0")) false)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;         LAUNCH GAME!         ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A world reflecting the state of the start of the game
(define world1 (make-world (new-tetra (random 7) empty) empty 0))

;; Launch the game
(main world1)






























