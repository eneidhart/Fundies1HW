;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname TetrisFun_updated) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

;; Problem Set 8
;; Neidhart, Ethan
;; Unaka, Muigai

;; Problem 6 - Tetris

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

;; TODO: I think we can use foldr for this...probably not necessary though. Do last.
;; to-draw function, Draws the world onto the scene
;; World -> Image
(define (draw-world w)
  (draw-tetra (world-tetra w)
              (draw-tetra (tetra-ghost (world-tetra w))
                          (draw-blocks (world-pile w) (draw-score (world-score w) GRID)))))

;; DID! TODO: Replace with lambda
;; Draws a single block
;; Block -> Image
#|(define (draw-block color)
  (overlay (square 25 "outline" "black")
           (square 25 "solid" color)))

(check-expect (draw-block "red") (overlay (square 25 "outline" "black")
                                          (square 25 "solid" "red")))
(check-expect (draw-block "green") (overlay (square 25 "outline" "black")
                                            (square 25 "solid" "green")))|#

;; Draws a tetra on a scene
;; Tetra, Image -> Image
(define (draw-tetra tetra scene)
  (draw-blocks (tetra-blocks tetra) scene))

;; DID! TODO: map or fold will probably work well here
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

;; TODO: move-down-blocks can be a local
;; Moves the Tetra down by one grid-unit.
;; Tetra -> Tetra
(define (move-down tetra)
  (make-tetra (make-posn 
               (posn-x (tetra-center tetra))
               (+ (posn-y (tetra-center tetra)) GRID-SIZE))
              (move-down-blocks (tetra-blocks tetra))
              (tetra-ghost tetra)))

;; DID! TODO: Map will probably work well here
;; Helper function for move-down.
;; Moves a BSet down by one grid-unit.
;; BSet -> BSet
(define (move-down-blocks blocks)
  (local [(define (move-down-block block)
            (make-block (block-x block)
                        (+ (block-y block) GRID-SIZE)
                        (block-color block)))]
    (map move-down-block blocks)))
#|(cond[(cons? blocks) 
        (cons (make-block (block-x (first blocks)) 
                          (+ (block-y (first blocks)) GRID-SIZE)
                          (block-color (first blocks)))
              (move-down-help (rest blocks)))]
       [(empty? blocks) empty]))
DELETE ME
DELETE ME
DELETE ME|#

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

;; DID! TODO: append probably works best here
;; Adds a BSet to a Pile
;; Pile, BSet -> Pile
(define (grow-pile pile blocks)
  (append blocks pile)) #| (cond[(cons? blocks) (cons (first blocks) 
                             (grow-pile pile (rest blocks)))]
       [(empty? blocks) pile])) |#

;; Makes a txt containing the user's score determined by pile size,
;; at the correct location for a score.
;; Pile -> txt
(define (score current-score)
  (+ 4 current-score))

;; TODO: score should just be a number saved in the world...not calculated from scratch
;; Determines the player's score from the pile
;; Pile -> number
(define (compute-score pile)
  (cond[(cons? pile)
        (+ 1 (compute-score (rest pile)))]
       [(empty? pile) 0]))

;; DID! TODO: ormap is probably best here
;; Determines if a set of blocks is overlapping with the pile,
;; or has passed the lower bound of the grid.
;; BSet, Pile -> Boolean
(define (hit-bottom? blocks pile)
   (ormap (λ (block) (or (in-pile? block pile)
                         (> (block-y block) (* GRID-SIZE 19)))) blocks))
  #|(cond[(cons? blocks)
        (or (in-pile? (first blocks) pile)
            (> (block-y (first blocks)) 
               (* GRID-SIZE 19))
            (hit-bottom? (rest blocks) pile))]
       [(empty? blocks) false]))|#

;; DID! TODO: ormap is probably best here
;; Helper function for hit-bottom?
;; Determines if a block is overlapping with the pile
;; Block, Pile -> Boolean
(define (in-pile? block pile)
  (local [(define (same-position? block1 block2)
            (and (= (block-x block1) (block-x block2))
                 (= (block-y block1) (block-y block2))))]
    (ormap (λ (pile-block) (same-position? block pile-block)) pile)))
  #|(cond[(cons? pile)
        (or (same-position? block (first pile))
            (in-pile? block (rest pile)))]
       [(empty? pile) false]))|#

;; TODO: make local of this function
;; Helper function for in-pile?
;; Determines if two blocks are in the same location
;; Block, Block -> Boolean
#|(define (same-position? block1 block2)
  (and (= (block-x block1) (block-x block2))
       (= (block-y block1) (block-y block2))))|#

;; DID! TODO: Do you know of any loops that might work here? I made my own
;; Moves a Tetra as far down as it can go
;; Tetra, Pile -> Tetra
(define (move-down-bottom tetra pile)
  (while-apply move-down
               (λ (a-tetra)
                 (hit-bottom? (tetra-blocks (move-down a-tetra)) pile))
               tetra))
  #|(if (hit-bottom? (tetra-blocks (move-down tetra)) pile)
      tetra
      (move-down-bottom (move-down tetra) pile)))|#

;; Given any Tetra, returns the same Tetra, but with a ghost underneath
;; Tetra -> Tetra
(define (ghost-tetra tetra pile)
  (make-tetra (tetra-center tetra)
              (tetra-blocks tetra)
              (move-down-bottom (make-tetra (tetra-center tetra)
                                            (seethru (tetra-blocks tetra))
                                            empty)
                                pile)))

;; DID! TODO: Map will probably work best here
;; Colors a set of blocks light gray (for the ghost)
;; BSet -> BSet
(define (seethru blocks)
  (map (λ (block) (make-block (block-x block)
                              (block-y block)
                              "LightGray"))
       blocks))
  #|(cond[(cons? blocks)
        (cons (make-block (block-x (first blocks))
                          (block-y (first blocks))
                          "LightGray")
              (seethru (rest blocks)))]
       [(empty? blocks) empty]))|#

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

;; DID! TODO: map is probably best here
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
  #|(cond[(cons? blocks)
        (cons (move-block (first blocks) d) (move-blocks (rest blocks) d))]
       [(empty? blocks) empty]))|#

;; DID! TODO: this can probably be a lambda/local
;; Helper function for move-blocks
;; Moves a single block in a direction (left or right)
;; Block, direction -> Block
#|(define (move-block block d)
  (cond[(string=? "left" d)
        (make-block (- (block-x block) GRID-SIZE)
                    (block-y block) (block-color block))]
       [(string=? "right" d)
        (make-block (+ (block-x block) GRID-SIZE)
                    (block-y block) (block-color block))]))|#

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

;; DID! TODO: map will probably work best here
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
  #|(cond[(cons? blocks) (cons (block-rotate center (first blocks) d)
                             (rotate-blocks (rest blocks) center d))]
       [(empty? blocks) empty]))|#

;; DID! TODO: Could this be a lambda or local?
;; Helper function for rotate-blocks
;; Rotates the block 90 degrees about the Posn
;; Posn, Block, direction -> Block
#|(define (block-rotate center block d)
  (cond[(string=? "a" d)
        (block-rotate-ccw center block)]
       [(or (string=? "s" d) (string=? "up" d))
        (block-rotate-cw center block)]))|#

;; This could also be a local in rotate-blocks...I guess
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

;; This could also be a local...but maybe that's going a bit overboard?
;; Helper function for block-rotate
;; Rotate the block 90 counter-clockwise around the posn.
;; block-rotate-ccw : Posn Block -> Block
(define (block-rotate-ccw ctr blk)
  (block-rotate-cw ctr 
                   (block-rotate-cw ctr
                                    (block-rotate-cw ctr blk))))

;; DID! TODO: ormap will probably work best here
;; Determines if blocks are out of bounds
;; BSet -> Boolean
(define (hit-sides? blocks)
  (ormap (λ (block) (or (< (block-x block) (* 0 GRID-SIZE))
                        (> (block-x block) (* 9 GRID-SIZE))))
         blocks))
  #|(cond[(cons? blocks)
        (or (< (block-x (first blocks)) (* 0 GRID-SIZE))
            (> (block-x (first blocks)) (* 9 GRID-SIZE))
            (hit-sides? (rest blocks)))]
       [(empty? blocks) false]))|#

;; DID! TODO:  ormap will probably work best here
;; Determines if blocks are out of bounds to the left
;; BSet -> Boolean
(define (hit-left? blocks)
  (ormap (λ (block) (< (block-x block) (* 0 GRID-SIZE))) blocks))
  #|(cond[(cons? blocks)
        (or (< (block-x (first blocks)) (* 0 GRID-SIZE))
            (hit-left? (rest blocks)))]
       [(empty? blocks) false]))|#

;; DID! TODO: ormap will probably work best here
;; Determines if blocks are out of bounds to the right
;; BSet -> Boolean
(define (hit-right? blocks)
  (ormap (λ (block) (> (block-x block) (* 9 GRID-SIZE))) blocks))
 #|
DELETE ME!!!
DELETE ME!!!
(cond[(cons? blocks)
        (or (> (block-x (first blocks)) (* 9 GRID-SIZE))
            (hit-right? (rest blocks)))]
       [(empty? blocks) false])) DELETE ME!!!|#

;; DID! TODO: ormap will probably work best here
;; Determines if a set of blocks overlaps the pile.
;; BSet -> Boolean
(define (hit-pile? blocks pile)
  (ormap (λ (block) (in-pile? block pile)) blocks))
  #|(cond[(cons? blocks)
        (or (in-pile? (first blocks) pile)
            (hit-pile? (rest blocks) pile))]
       [(empty? blocks) false]))|#

;; DID! TODO: I can't think of a loop for this...do we need one? I wrote one
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
               
  #|(cond[(hit-left? (tetra-blocks tetra))
        (put-right (ghost-tetra (make-tetra (make-posn (+ (posn-x (tetra-center tetra)) GRID-SIZE)
                                                       (posn-y (tetra-center tetra)))
                                            (move-blocks (tetra-blocks tetra) "right")
                                            empty)
                                pile)
                   pile)]
       [else tetra]))|#

;; DID! TODO: same as put-right
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
  #|(cond[(hit-right? (tetra-blocks tetra))
        (put-left (ghost-tetra (make-tetra (make-posn (- (posn-x (tetra-center tetra)) GRID-SIZE)
                                                      (posn-y (tetra-center tetra)))
                                           (move-blocks (tetra-blocks tetra) "left")
                                           empty)
                               pile)
                  pile)]
       [else tetra]))|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;           OVERFLOW           ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; DID! TODO: Replace helper, use ormap
;; Determines if the grid is overflowed with blocks
;; Does the pile extend above the upper bound of the grid?
;; World -> Boolean
(define (overflow? w)
  (local [(define (pile-overflow? pile)
            (ormap (λ (pile-block) (< (block-y pile-block) 0)) pile))]
    (pile-overflow? (world-pile w))))

(check-expect (overflow? (make-world TETRA-O empty "0")) false)

#|
DELETEME!!!
DELETEME!!!
;; TODO: ormap would work best here
;; Helper function for overflow?
;; Determines if a given pile extends above the upper grid bound
;; Pile -> Boolean
#;(define (pile-overflow? pile)
    (ormap (λ (pile) (< (block-y pile) 0)) pile))
DELETEME!!!
DELETEME!!!
|#



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;         LAUNCH GAME!         ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A world reflecting the state of the start of the game
(define world1 (make-world (new-tetra (random 7) empty) empty 0))

;; Launch the game
;(main world1)






























