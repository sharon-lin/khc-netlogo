breed [ boards board ]
breed [ pieces piece ]
globals [ turn 
          white-move
          black-move
          click-number
          check?
          checkmate? ]
          
;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to startup
  setup
end

to setup
  ca
  ask patches
  [ sprout 1 [ board-setup ] ] 
  ask turtles with [ xcor = 4 or ycor = 4 ]
    [ die ]
  piece-setup
  label-board
  set turn white
  set check? false
  set checkmate? false
  display
end

to label-board
  ask patch -4 4 [ set plabel "a" ]
  ask patch -3 4 [ set plabel "b" ]
  ask patch -2 4 [ set plabel "c" ]
  ask patch -1 4 [ set plabel "d" ]
  ask patch 0 4 [ set plabel "e" ]
  ask patch 1 4 [ set plabel "f" ]
  ask patch 2 4 [ set plabel "g" ]
  ask patch 3 4 [ set plabel "h" ]
  ask patch 4 -4 [ set plabel "1" ]
  ask patch 4 -3 [ set plabel "2" ]
  ask patch 4 -2 [ set plabel "3" ]
  ask patch 4 -1 [ set plabel "4" ]
  ask patch 4 0 [ set plabel "5" ]
  ask patch 4 1 [ set plabel "6" ]
  ask patch 4 2 [ set plabel "7" ]
  ask patch 4 3 [ set plabel "8" ]
end

to-report even? [ x ]
 report ( remainder x 2 = 0)
end

to-report odd? [ x ]
 report not even? x
end

to board-setup
  color-board
  set breed boards
  set shape "square"
end

to color-board
  set color 6
  ask boards with [ (even? xcor and even? ycor) or (odd? xcor and odd? ycor) ] 
    [ set color 2 ]
end

to piece-setup
  crt 32
  [ set breed pieces
    set heading 0 ]
  make-pawns  
  make-rooks
  make-knights
  make-bishops
  make-queens
  make-kings
end

to make-pawns
  ask turtles with [ who >= 81 and who <= 88 ]
    [ set shape "chess pawn" 
      set color white
      setxy item (who - 81) [-4 -3 -2 -1 0 1 2 3 ] -3 ]
  ask turtles with [ who >= 89 and who <= 96 ]
    [ set shape "chess pawn"
      set color black 
      setxy item (who - 89) [-4 -3 -2 -1 0 1 2 3 ] 2] 
end

to make-rooks
  ask turtles with [ who = 97 or who = 98 ]
    [ set shape "chess rook"
      set color white
      setxy item (who - 97) [-4 3] -4 ]
  ask turtles with [ who = 99 or who = 100 ]
    [ set shape "chess rook"
      set color black
      setxy item (who - 99) [-4 3] 3 ]
end

to make-knights
  ask turtles with [ who = 101 or who = 102 ]
    [ set shape "chess knight"
      set color white
      setxy item (who - 101) [-3 2] -4 ]
  ask turtles with [ who = 103 or who = 104 ]
    [ set shape "chess knight"
      set color black
      setxy item (who - 103) [-3 2] 3 ]
end

to make-bishops
  ask turtles with [ who = 105 or who = 106 ]
    [ set shape "chess bishop"
      set color white
      setxy item (who - 105) [-2 1] -4 ]
  ask turtles with [ who = 107 or who = 108 ]
    [ set shape "chess bishop"
      set color black
      setxy item (who - 107) [-2 1] 3 ]
end

to make-queens
  ask turtles with [ who = 109 ]
    [ set shape "chess queen"
      set color white
      setxy -1 -4 ]
  ask turtles with [ who = 110 ]
    [ set shape "chess queen"
      set color black
      setxy -1 3 ]
end

to make-kings
  ask turtles with [ who = 111 ]
    [ set shape "chess king"
      set color white 
      setxy 0 -4 ]
  ask turtles with [ who = 112 ]
    [ set shape "chess king"
      set color black
      setxy 0 3 ]
end



;;;;;;;;;;;;;;;;;;;;;
;;; Go Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;

to go
  ask boards [highlight-moves]
  move-pieces
  convert-pawn1
  convert-pawn2
end

to move-pieces
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  if mouse-down? [
  ask patch a b [ if any? turtles-here 
    [
    let x one-of [who] of boards with [xcor = a and ycor = b] 
    if [color] of board x = cyan 
      [ transport-piece
        stop ]
    if  [color] of board x = pink
      [ kill-piece
        stop ]
    ] ] ]
end

to transport-piece
  let a round mouse-xcor
  let b round mouse-ycor
  let m one-of [xcor] of boards with [ color = yellow ] 
  let n one-of [ycor] of boards with [ color = yellow ] 
  if not any? pieces with [ xcor = m and ycor = n ] [ stop ] 
  let x one-of [who] of pieces with [ xcor = m and ycor = n ] 
  
  ask piece x [ move-to patch a b 
                reset-colors
                set click-number 0 
                change-turn ]  
end

to change-turn
  ifelse turn = white
  [ set turn black ]
  [ set turn white ]
end

to kill-piece
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  let x one-of [who] of pieces with [xcor = a and ycor = b]
  let y one-of [who] of boards with [xcor = a and ycor = b]
  let m one-of [xcor] of boards with [ color = yellow ]
  let n one-of [ycor] of boards with [ color = yellow ]
  if not any? pieces with [ xcor = m and ycor = n ] [ stop ]
  let z one-of [who] of pieces with [ xcor = m and ycor = n ]
  
  ask piece x [ die ]
  ask piece z [ move-to patch a b
                reset-colors
                set click-number 0
                change-turn ]
end

to highlight-moves
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  if mouse-down? and any? turtles with [ xcor = a and ycor = b and breed = pieces
     and not any? turtles with [ color = yellow ] and click-number = 0 ]
    [ ask patch a b [ if any? pieces-here with [ color = turn ] 
    [ ask boards with [ xcor = a and ycor = b ]
        [ set color yellow ]
      show-moves
      set click-number 1
       ]
    ] ]
  if not mouse-inside? and click-number = 1
    [   reset-colors
        set click-number 0 ]
end

to reset-colors
  ask boards [set color 6]
  ask boards with [ (even? xcor and even? ycor) or (odd? xcor and odd? ycor) ] 
    [ set color 2 ]
end

to show-moves
  ask patch round mouse-xcor round mouse-ycor
  [
      if any? pieces-here with [ shape = "chess pawn" ]
        [ ifelse any? other turtles-here with [ color = white ]
          [ w-pawn-moves
            w-pawn-kills ]
          [ b-pawn-moves 
            b-pawn-kills ] ]
      if any? pieces-here with [ shape = "chess pawn2" ]
        [ ifelse any? other turtles-here with [ color = white ]
          [ w-pawn2-moves
            w-pawn-kills ]
          [ b-pawn2-moves 
            b-pawn-kills ] ]
      if any? pieces-here with [ shape = "chess rook" ]
        [ rook-moves ]        
      if any? pieces-here with [ shape = "chess knight" ]
        [ knight-moves ]        
      if any? pieces-here with [ shape = "chess bishop" ]
        [ bishop-moves ]        
      if any? pieces-here with [ shape = "chess queen" ]
        [ queen-moves ]        
      if any? pieces-here with [ shape = "chess king" ]
        [ king-moves ]
   ]
end

to w-pawn-moves
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  ifelse count [pieces-at 0 1] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b + 1 ]
      [ set color cyan ] ]
         [ stop ] 
  ifelse count [pieces-at 0 2] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b + 2 ]
      [ set color cyan ] ]
          [ stop ]
end
      
to w-pawn-kills  
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  let x one-of [who] of pieces with [xcor = a and ycor = b]
  if count [pieces-at 1 1] of patch a b = 1
    [ ask boards with [ xcor = a + 1 and ycor = b + 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 1 and ycor = b + 1 ]
          [ set color pink ] ] ] ]          
  if count [pieces-at -1 1] of patch a b = 1
    [ ask boards with [ xcor = a - 1 and ycor = b + 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 1 and ycor = b + 1 ]
          [ set color pink ] ] ] ]
end

to b-pawn-kills  
  let a (round mouse-xcor)
  let b (round mouse-ycor)  
  let x one-of [who] of pieces with [xcor = a and ycor = b]
  if count [pieces-at 1 -1] of patch a b = 1
    [ ask boards with [ xcor = a + 1 and ycor = b - 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ] 
        [ ask boards with [ xcor = a + 1 and ycor = b - 1 ]
          [ set color pink ] ] ] ]          
  if count [pieces-at -1 -1] of patch a b = 1
    [ ask boards with [ xcor = a - 1 and ycor = b - 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 1 and ycor = b - 1 ]
          [ set color pink ] ] ] ]
end

to b-pawn-moves
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  ifelse count [pieces-at 0 -1] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b - 1 ]
      [ set color cyan ] ]
          [ stop ]
  ifelse count [pieces-at 0 -2] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b - 2 ]
      [ set color cyan ] ]
          [ stop ]
end

to w-pawn2-moves
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  ifelse count [pieces-at 0 1] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b + 1 ]
      [ set color cyan ] ]
          [ stop ]
end

to b-pawn2-moves
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  ifelse count [pieces-at 0 -1] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b - 1 ]
      [ set color cyan ] ]
          [ stop ]
end

to rook-moves 
  r-up
  r-down
  r-left
  r-right
end

to r-up
  let a (round mouse-xcor)
  let b (round mouse-ycor)  
  let x one-of [who] of pieces with [xcor = a and ycor = b]
  
  ifelse count [pieces-at 0 1] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b + 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b + 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b + 1 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 0 2] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b + 2 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b + 2 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b + 2 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 0 3] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b + 3 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b + 3 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b + 3 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 0 4] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b + 4 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b + 4 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b + 4 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 0 5] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b + 5 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b + 5 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b + 5 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 0 6] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b + 6 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b + 6 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b + 6 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 0 7] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b + 7 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b + 7 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b + 7 ]
          [ set color pink ] ] ] 
       stop ]       
end

to r-down
  let a (round mouse-xcor)
  let b (round mouse-ycor)  
  let x one-of [who] of pieces with [xcor = a and ycor = b]
      
  ifelse count [pieces-at 0 -1] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b - 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b - 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b - 1 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 0 -2] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b - 2 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b - 2 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b - 2 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 0 -3] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b - 3 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b - 3 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b - 3 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 0 -4] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b - 4 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b - 4 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b - 4 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 0 -5] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b - 5 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b - 5 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b - 5 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 0 -6] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b - 6 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b - 6 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b - 6 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 0 -7] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b - 7 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b - 7 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b - 7 ]
          [ set color pink ] ] ] 
       stop ]
end

to r-right
  let a (round mouse-xcor)
  let b (round mouse-ycor) 
  let x one-of [who] of pieces with [xcor = a and ycor = b]
       
  ifelse count [pieces-at 1 0] of patch a b = 0
    [ ask boards with [ xcor = a + 1 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 1 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 1 and ycor = b ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 2 0] of patch a b = 0
    [ ask boards with [ xcor = a + 2 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 2 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 2 and ycor = b ]
          [ set color pink ] ] ]
       stop ]       
  ifelse count [pieces-at 3 0] of patch a b = 0
    [ ask boards with [ xcor = a + 3 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 3 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 3 and ycor = b ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 4 0] of patch a b = 0
    [ ask boards with [ xcor = a + 4 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 4 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 4 and ycor = b ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 5 0] of patch a b = 0
    [ ask boards with [ xcor = a + 5 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 5 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 5 and ycor = b ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 6 0] of patch a b = 0
    [ ask boards with [ xcor = a + 6 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 6 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 6 and ycor = b ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 7 0] of patch a b = 0
    [ ask boards with [ xcor = a + 7 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 7 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 7 and ycor = b ]
          [ set color pink ] ] ] 
       stop ]
end

to r-left
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  let x one-of [who] of pieces with [xcor = a and ycor = b]
        
  ifelse count [pieces-at -1 0] of patch a b = 0
    [ ask boards with [ xcor = a - 1 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 1 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 1 and ycor = b ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -2 0] of patch a b = 0
    [ ask boards with [ xcor = a - 2 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 2 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 2 and ycor = b ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -3 0] of patch a b = 0
    [ ask boards with [ xcor = a - 3 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 3 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 3 and ycor = b ]
          [ set color pink ] ] ]
       stop ]
  ifelse count [pieces-at -4 0] of patch a b = 0
    [ ask boards with [ xcor = a - 4 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 4 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 4 and ycor = b ]
          [ set color pink ] ] ]
       stop ]
  ifelse count [pieces-at -5 0] of patch a b = 0
    [ ask boards with [ xcor = a - 5 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 5 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 5 and ycor = b ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -6 0] of patch a b = 0
    [ ask boards with [ xcor = a - 6 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 6 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 6 and ycor = b ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -7 0] of patch a b = 0
    [ ask boards with [ xcor = a - 7 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 7 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 7 and ycor = b ]
          [ set color pink ] ] ] 
       stop ]
end

to knight-moves 
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  let x one-of [who] of pieces with [xcor = a and ycor = b]

  ifelse count [pieces-at -1 2] of patch a b = 0
    [ ask boards with [ xcor = a - 1 and ycor = b + 2 ]
      [ set color cyan ] ] 
    [ ask boards with [ xcor = a - 1 and ycor = b + 2 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 1 and ycor = b + 2 ]
          [ set color pink ] ] ] ]         
  ifelse count [pieces-at -1 -2] of patch a b = 0
    [ ask boards with [ xcor = a - 1 and ycor = b - 2 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 1 and ycor = b - 2 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 1 and ycor = b - 2 ]
          [ set color pink ] ] ] ]          
  ifelse count [pieces-at 1 2] of patch a b = 0
    [ ask boards with [ xcor = a + 1 and ycor = b + 2 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 1 and ycor = b + 2 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 1 and ycor = b + 2 ]
          [ set color pink ] ] ] ]
  ifelse count [pieces-at 1 -2] of patch a b = 0
    [ ask boards with [ xcor = a + 1 and ycor = b - 2]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 1 and ycor = b - 2 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 1 and ycor = b - 2 ]
          [ set color pink ] ] ] ]      
  ifelse count [pieces-at 2 1] of patch a b = 0
    [ ask boards with [ xcor = a + 2 and ycor = b + 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 2 and ycor = b + 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 2 and ycor = b + 1 ]
          [ set color pink ] ] ] ]
  ifelse count [pieces-at 2 -1] of patch a b = 0
    [ ask boards with [ xcor = a + 2 and ycor = b - 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 2 and ycor = b - 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 2 and ycor = b - 1 ]
          [ set color pink ] ] ] ]          
  ifelse count [pieces-at -2 1] of patch a b = 0
    [ ask boards with [ xcor = a - 2 and ycor = b + 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 2 and ycor = b + 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 2 and ycor = b + 1 ]
          [ set color pink ] ] ] ]          
  ifelse count [pieces-at -2 -1] of patch a b = 0
    [ ask boards with [ xcor = a - 2 and ycor = b - 1 ]
      [ set color cyan ] ]  
    [ ask boards with [ xcor = a - 2 and ycor = b - 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 2 and ycor = b - 1 ]
          [ set color pink ] ] ] ]
end

to bishop-moves 
  b-RU
  b-RD
  b-LU
  b-LD
end

to b-RU
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  let x one-of [who] of pieces with [xcor = a and ycor = b]
  
  ifelse count [pieces-at 1 1] of patch a b = 0
    [ ask boards with [ xcor = a + 1 and ycor = b + 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 1 and ycor = b + 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 1 and ycor = b + 1 ]
          [ set color pink ] ] ] 
       stop ]       
  ifelse count [pieces-at 2 2] of patch a b = 0
    [ ask boards with [ xcor = a + 2 and ycor = b + 2 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 2 and ycor = b + 2 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 2 and ycor = b + 2 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 3 3] of patch a b = 0
    [ ask boards with [ xcor = a + 3 and ycor = b + 3 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 3 and ycor = b + 3 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 3 and ycor = b + 3 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 4 4] of patch a b = 0
    [ ask boards with [ xcor = a + 4 and ycor = b + 4 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 4 and ycor = b + 4 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 4 and ycor = b + 4 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 5 5] of patch a b = 0
    [ ask boards with [ xcor = a + 5 and ycor = b + 5 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 5 and ycor = b + 5 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 5 and ycor = b + 5 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 6 6] of patch a b = 0
    [ ask boards with [ xcor = a + 6 and ycor = b + 6 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 6 and ycor = b + 6 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 6 and ycor = b + 6 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 7 7] of patch a b = 0
    [ ask boards with [ xcor = a + 7 and ycor = b + 7 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 7 and ycor = b + 7 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 7 and ycor = b + 7 ]
          [ set color pink ] ] ] 
       stop ]

end

to b-RD
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  let x one-of [who] of pieces with [xcor = a and ycor = b]
  
  ifelse count [pieces-at 1 -1] of patch a b = 0
    [ ask boards with [ xcor = a + 1 and ycor = b - 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 1 and ycor = b - 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 1 and ycor = b - 1 ]
          [ set color pink ] ] ] 
       stop ]       
  ifelse count [pieces-at 2 -2] of patch a b = 0
    [ ask boards with [ xcor = a + 2 and ycor = b - 2 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 2 and ycor = b - 2 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 2 and ycor = b - 2 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 3 -3] of patch a b = 0
    [ ask boards with [ xcor = a + 3 and ycor = b - 3 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 3 and ycor = b - 3 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 3 and ycor = b - 3 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 4 -4] of patch a b = 0
    [ ask boards with [ xcor = a + 4 and ycor = b - 4 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 4 and ycor = b - 4 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 4 and ycor = b - 4 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 5 -5] of patch a b = 0
    [ ask boards with [ xcor = a + 5 and ycor = b - 5 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 5 and ycor = b - 5 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 5 and ycor = b - 5 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 6 -6] of patch a b = 0
    [ ask boards with [ xcor = a + 6 and ycor = b - 6 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 6 and ycor = b - 6 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 6 and ycor = b - 6 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at 7 -7] of patch a b = 0
    [ ask boards with [ xcor = a + 7 and ycor = b - 7 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 7 and ycor = b - 7 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 7 and ycor = b - 7 ]
          [ set color pink ] ] ] 
       stop ]

end

to b-LU
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  let x one-of [who] of pieces with [xcor = a and ycor = b]
  
  ifelse count [pieces-at -1 1] of patch a b = 0
    [ ask boards with [ xcor = a - 1 and ycor = b + 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 1 and ycor = b + 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 1 and ycor = b + 1 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -2 2] of patch a b = 0
    [ ask boards with [ xcor = a - 2 and ycor = b + 2 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 2 and ycor = b + 2 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 2 and ycor = b + 2 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -3 3] of patch a b = 0
    [ ask boards with [ xcor = a - 3 and ycor = b + 3 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 3 and ycor = b + 3 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 3 and ycor = b + 3 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -4 4] of patch a b = 0
    [ ask boards with [ xcor = a - 4 and ycor = b + 4 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 4 and ycor = b + 4 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 4 and ycor = b + 4 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -5 5] of patch a b = 0
    [ ask boards with [ xcor = a - 5 and ycor = b + 5 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 5 and ycor = b + 5 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 5 and ycor = b + 5 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -6 6] of patch a b = 0
    [ ask boards with [ xcor = a - 6 and ycor = b + 6 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 6 and ycor = b + 6 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 6 and ycor = b + 6 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -7 7] of patch a b = 0
    [ ask boards with [ xcor = a - 7 and ycor = b + 7 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 7 and ycor = b + 7 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 7 and ycor = b + 7 ]
          [ set color pink ] ] ] 
       stop ]
end

to b-LD
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  let x one-of [who] of pieces with [xcor = a and ycor = b]
  
  ifelse count [pieces-at -1 -1] of patch a b = 0
    [ ask boards with [ xcor = a - 1 and ycor = b - 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 1 and ycor = b - 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 1 and ycor = b - 1 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -2 -2] of patch a b = 0
    [ ask boards with [ xcor = a - 2 and ycor = b - 2 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 2 and ycor = b - 2 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 2 and ycor = b - 2 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -3 -3] of patch a b = 0
    [ ask boards with [ xcor = a - 3 and ycor = b - 3 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 3 and ycor = b - 3 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 3 and ycor = b - 3 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -4 -4] of patch a b = 0
    [ ask boards with [ xcor = a - 4 and ycor = b - 4 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 4 and ycor = b - 4  ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 4 and ycor = b - 4 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -5 -5] of patch a b = 0
    [ ask boards with [ xcor = a - 5 and ycor = b - 5 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 5 and ycor = b - 5 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 5  and ycor = b - 5 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -6 -6] of patch a b = 0
    [ ask boards with [ xcor = a - 6 and ycor = b - 6 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 6 and ycor = b - 6 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 6 and ycor = b - 6 ]
          [ set color pink ] ] ] 
       stop ]
  ifelse count [pieces-at -7 -7] of patch a b = 0
    [ ask boards with [ xcor = a - 7 and ycor = b - 7 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 7 and ycor = b - 7 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 7 and ycor = b - 7 ]
          [ set color pink ] ] ] 
       stop ]
end

to queen-moves 
  rook-moves
  bishop-moves
end

to king-moves
  let a (round mouse-xcor)
  let b (round mouse-ycor)
  let x one-of [who] of pieces with [xcor = a and ycor = b]
  ifelse count [pieces-at 0 1] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b + 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b + 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b + 1 ]
          [ set color pink ] ] ] ]          
  ifelse count [pieces-at 0 -1] of patch a b = 0
    [ ask boards with [ xcor = a and ycor = b - 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a and ycor = b - 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a and ycor = b - 1 ]
          [ set color pink ] ] ] ]          
  ifelse count [pieces-at -1 0] of patch a b = 0
    [ ask boards with [ xcor = a - 1 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 1 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 1 and ycor = b ]
          [ set color pink ] ] ] ]          
  ifelse count [pieces-at 1 0] of patch a b = 0
    [ ask boards with [ xcor = a + 1 and ycor = b ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 1 and ycor = b ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 1 and ycor = b ]
          [ set color pink ] ] ] ]
  ifelse count [pieces-at 1 1] of patch a b = 0
    [ ask boards with [ xcor = a + 1 and ycor = b + 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 1 and ycor = b + 1]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 1 and ycor = b + 1 ]
          [ set color pink ] ] ] ]
  ifelse count [pieces-at 1 -1] of patch a b = 0
    [ ask boards with [ xcor = a + 1 and ycor = b - 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a + 1 and ycor = b - 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a + 1 and ycor = b - 1 ]
          [ set color pink ] ] ] ]
  ifelse count [pieces-at -1 1] of patch a b = 0
    [ ask boards with [ xcor = a - 1 and ycor = b + 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 1 and ycor = b + 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 1 and ycor = b + 1 ]
          [ set color pink ] ] ] ]
  ifelse count [pieces-at -1 -1] of patch a b = 0
    [ ask boards with [ xcor = a - 1 and ycor = b - 1 ]
      [ set color cyan ] ]
    [ ask boards with [ xcor = a - 1 and ycor = b - 1 ]
      [ if any? pieces-here with [ color != [color] of piece x ]
        [ ask boards with [ xcor = a - 1 and ycor = b - 1 ]
          [ set color pink ] ] ] ]
end

to convert-pawn1
  if any? pieces with [ shape = "chess pawn" and color = white and ycor > -3 ]
    [ ask pieces with [ shape = "chess pawn" and color = white and ycor > -3 ]
      [ set shape "chess pawn2" ] ]
  if any? pieces with [ shape = "chess pawn" and color = black and ycor < 2 ]
    [ ask pieces with [ shape = "chess pawn" and color = black and ycor < 2 ]
      [ set shape "chess pawn2" ] ]    
end

to convert-pawn2
  if any? pieces with [ shape = "chess pawn2" and color = white and ycor = 3 ]
    [ user-message (word "You can promote your pawn!\nWhat piece do you want to promote your pawn to?") 
      ifelse user-yes-or-no? "Queen?"
      [ ask pieces with [ shape = "chess pawn2" and color = white and ycor = 3 ]
        [ set shape "chess queen" ] ]
      [ ifelse user-yes-or-no? "Rook?"        
      [ ask pieces with [ shape = "chess pawn2" and color = white and ycor = 3 ]
        [ set shape "chess rook" ] ]
      [ ifelse user-yes-or-no? "Bishop?"
      [ ask pieces with [ shape = "chess pawn2" and color = white and ycor = 3 ]
        [ set shape "chess bishop" ] ]
      [ ask pieces with [ shape = "chess pawn2" and color = white and ycor = 3 ]
        [ set shape "chess knight" ] ] ] ] ]              
                
  if any? pieces with [ shape = "chess pawn2" and color = black and ycor = -4 ]
    [ user-message (word "You can promote your pawn!\nWhat piece do you want to promote your pawn to?") 
      ifelse user-yes-or-no? "Queen?"
      [ ask pieces with [ shape = "chess pawn2" and color = black and ycor = -4 ]
        [ set shape "chess queen" ] ]
      [ ifelse user-yes-or-no? "Rook?"        
      [ ask pieces with [ shape = "chess pawn2" and color = black and ycor = -4 ]
        [ set shape "chess rook" ] ]
      [ ifelse user-yes-or-no? "Bishop?"
      [ ask pieces with [ shape = "chess pawn2" and color = black and ycor = -4 ]
        [ set shape "chess bishop" ] ]
      [ ask pieces with [ shape = "chess pawn2" and color = black and ycor = -4 ]
        [ set shape "chess knight" ] ] ] ] ] 
end
@#$#@#$#@
GRAPHICS-WINDOW
233
10
859
657
4
4
68.44444444444444
1
20
1
1
1
0
0
0
1
-4
4
-4
4
0
0
1
ticks

CC-WINDOW
5
671
1110
766
Command Center
0

BUTTON
20
67
110
100
New Game
setup
NIL
1
T
OBSERVER
NIL
N
NIL
NIL

BUTTON
34
116
97
149
Start
go
T
1
T
OBSERVER
NIL
S
NIL
NIL

TEXTBOX
9
10
159
52
Move mouse outside of the screen if you want to unhighlight a piece
11
0.0
1

MONITOR
1020
244
1101
289
NIL
turn
17
1
11

@#$#@#$#@
WHAT IS IT?
-----------
This section could give a general understanding of what the model is trying to show or explain.


HOW IT WORKS
------------
This section could explain what rules the agents use to create the overall behavior of the model.


HOW TO USE IT
-------------
This section could explain how to use the model, including a description of each of the items in the interface tab.


THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.


EXTENDING THE MODEL
-------------------
This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.


NETLOGO FEATURES
----------------
This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

chess bishop
false
0
Circle -7500403 true true 135 35 30
Circle -16777216 false false 135 35 30
Rectangle -7500403 true true 90 255 210 300
Line -16777216 false 75 255 225 255
Rectangle -16777216 false false 90 255 210 300
Polygon -7500403 true true 105 255 120 165 180 165 195 255
Polygon -16777216 false false 105 255 120 165 180 165 195 255
Rectangle -7500403 true true 105 165 195 150
Rectangle -16777216 false false 105 150 195 165
Line -16777216 false 137 59 162 59
Polygon -7500403 true true 135 60 120 75 120 105 120 120 105 120 105 90 90 105 90 120 90 135 105 150 195 150 210 135 210 120 210 105 195 90 165 60
Polygon -16777216 false false 135 60 120 75 120 120 105 120 105 90 90 105 90 135 105 150 195 150 210 135 210 105 165 60

chess king
false
0
Polygon -7500403 true true 105 255 120 90 180 90 195 255
Polygon -16777216 false false 105 255 120 90 180 90 195 255
Polygon -7500403 true true 120 85 105 40 195 40 180 85
Polygon -16777216 false false 119 85 104 40 194 40 179 85
Rectangle -7500403 true true 105 105 195 75
Rectangle -16777216 false false 105 75 195 105
Rectangle -7500403 true true 90 255 210 300
Line -16777216 false 75 255 225 255
Rectangle -16777216 false false 90 255 210 300
Rectangle -7500403 true true 165 23 134 13
Rectangle -7500403 true true 144 0 154 44
Polygon -16777216 false false 153 0 144 0 144 13 133 13 133 22 144 22 144 41 154 41 154 22 165 22 165 12 153 12

chess knight
false
0
Line -16777216 false 75 255 225 255
Polygon -7500403 true true 90 255 60 255 60 225 75 180 75 165 60 135 45 90 60 75 60 45 90 30 120 30 135 45 240 60 255 75 255 90 255 105 240 120 225 105 180 120 210 150 225 195 225 210 210 255
Polygon -16777216 false false 210 255 60 255 60 225 75 180 75 165 60 135 45 90 60 75 60 45 90 30 120 30 135 45 240 60 255 75 255 90 255 105 240 120 225 105 180 120 210 150 225 195 225 210
Line -16777216 false 255 90 240 90
Circle -16777216 true false 134 63 24
Line -16777216 false 103 34 108 45
Line -16777216 false 80 41 88 49
Line -16777216 false 61 53 70 58
Line -16777216 false 64 75 79 75
Line -16777216 false 53 100 67 98
Line -16777216 false 63 126 69 123
Line -16777216 false 71 148 77 145
Rectangle -7500403 true true 90 255 210 300
Rectangle -16777216 false false 90 255 210 300

chess pawn
false
0
Circle -7500403 true true 105 65 90
Circle -16777216 false false 105 65 90
Rectangle -7500403 true true 90 255 210 300
Line -16777216 false 75 255 225 255
Rectangle -16777216 false false 90 255 210 300
Polygon -7500403 true true 105 255 120 165 180 165 195 255
Polygon -16777216 false false 105 255 120 165 180 165 195 255
Rectangle -7500403 true true 105 165 195 150
Rectangle -16777216 false false 105 150 195 165

chess pawn2
false
0
Circle -7500403 true true 105 65 90
Circle -16777216 false false 105 65 90
Rectangle -7500403 true true 90 255 210 300
Line -16777216 false 75 255 225 255
Rectangle -16777216 false false 90 255 210 300
Polygon -7500403 true true 105 255 120 165 180 165 195 255
Polygon -16777216 false false 105 255 120 165 180 165 195 255
Rectangle -7500403 true true 105 165 195 150
Rectangle -16777216 false false 105 150 195 165

chess queen
false
0
Circle -7500403 true true 140 11 20
Circle -16777216 false false 139 11 20
Circle -7500403 true true 120 22 60
Circle -16777216 false false 119 20 60
Rectangle -7500403 true true 90 255 210 300
Line -16777216 false 75 255 225 255
Rectangle -16777216 false false 90 255 210 300
Polygon -7500403 true true 105 255 120 90 180 90 195 255
Polygon -16777216 false false 105 255 120 90 180 90 195 255
Rectangle -7500403 true true 105 105 195 75
Rectangle -16777216 false false 105 75 195 105
Polygon -7500403 true true 120 75 105 45 195 45 180 75
Polygon -16777216 false false 120 75 105 45 195 45 180 75
Circle -7500403 true true 180 35 20
Circle -16777216 false false 180 35 20
Circle -7500403 true true 140 35 20
Circle -16777216 false false 140 35 20
Circle -7500403 true true 100 35 20
Circle -16777216 false false 99 35 20
Line -16777216 false 105 90 195 90

chess rook
false
0
Rectangle -7500403 true true 90 255 210 300
Line -16777216 false 75 255 225 255
Rectangle -16777216 false false 90 255 210 300
Polygon -7500403 true true 90 255 105 105 195 105 210 255
Polygon -16777216 false false 90 255 105 105 195 105 210 255
Rectangle -7500403 true true 75 90 120 60
Rectangle -7500403 true true 75 84 225 105
Rectangle -7500403 true true 135 90 165 60
Rectangle -7500403 true true 180 90 225 60
Polygon -16777216 false false 90 105 75 105 75 60 120 60 120 84 135 84 135 60 165 60 165 84 179 84 180 60 225 60 225 105

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 0 0 300 300

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
