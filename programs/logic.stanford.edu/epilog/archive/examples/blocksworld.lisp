;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; (c) Copyright 1990 Michael R. Genesereth;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Create application as follows:;;;   (1) load quickdraw.lisp;;;   (2) load this file;;;   (3) type (save-application "vagrant:agents:blocks";;;                              :toplevel-function #'blocks-toplevel);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Actions:;;;   (stack <block> <block>);;;   (table <block> <block>);;;   (transfer <block> <block> <block>);;;;;; Blocks (the values of the following variables:;;;   *red*;;;   *orange*;;;   *yellow*;;;   *green*;;;   *blue*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(proclaim '(special *current* *red* *orange* *yellow* *green* *blue*))(proclaim '(object-variable xpos ypos pattern));;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; robot;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(defobject *block*)(defobfun (draw *block*) ()  (let ((xpos (ask (self) xpos))        (ypos (ask (self) ypos))        (pattern (ask (self) pattern)))    (ask *current* (set-pen-pattern pattern))    (ask *current* (paint-rect xpos ypos (+ xpos 40) (+ ypos 40)))    (ask *current* (set-pen-pattern *black-pattern*))    (ask *current* (frame-rect xpos ypos (+ xpos 40) (+ ypos 40)))))(defobfun (erase *block*) ()  (let ((xpos (ask (self) xpos))        (ypos (ask (self) ypos)))    (ask *current* (set-fore-color *light-gray-color*))    (ask *current* (erase-rect xpos ypos (+ xpos 40) (+ ypos 40)))))(defobfun (move-by-hand *block*) ()    (ask *current* (set-pen-pattern *gray-pattern*))    (do ((old-x (ask (self) xpos)) (old-y (ask (self) ypos))         (new) (new-x) (new-y))        ((not (mouse-down-p)))        (setq new (ask *current* (window-mouse-position))              new-x (* (truncate (/ (point-h new) 40)) 40)              new-y (* (truncate (/ (point-v  new) 40)) 40))        (when (and (or (/= old-x new-x) (/= old-y new-y))                   (freep new-x new-y (self)))              (setq old-x new-x old-y new-y)              (erase)              (setq xpos new-x ypos new-y)              (draw)))    (ask *current* (set-pen-pattern *black-pattern*))    (adjust-blocks)    (draw))(defobfun (adjust *block*) ()  (cond ((= ypos 200))        ((insidep xpos (+ ypos 40) *red*))        ((insidep xpos (+ ypos 40) *green*))        ((insidep xpos (+ ypos 40) *yellow*))        ((insidep xpos (+ ypos 40) *blue*))        ((insidep xpos (+ ypos 40) *orange*))        (t (erase)           (setq ypos (+ ypos 40))           (draw)           (adjust-blocks))))(defobfun (support *block*) ()  (cond ((= ypos 200) nil)        ((= (ask *red* ypos) (+ ypos 40)) *red*)        ((= (ask *orange* ypos) (+ ypos 40)) *orange*)        ((= (ask *yellow* ypos) (+ ypos 40)) *yellow*)        ((= (ask *green* ypos) (+ ypos 40)) *green*)        ((= (ask *blue* ypos) (+ ypos 40)) *blue*)))(defobfun (choose-location *block*) ()  (erase)  (do ((x (random 25) (random 25)) (y (random 25) (random 25)))      ((freep (* x 40) (* y 40) (self))       (ask (self) (setq xpos (* x 40) ypos (* y 40)))       (draw))))(defun adjust-blocks ()  (ask *red* (adjust))  (ask *green* (adjust))  (ask *yellow* (adjust))  (ask *blue* (adjust))  (ask *orange* (adjust)));;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; miscellaneous;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(defun stack (x y)  (when (and (clearp x) (tablep x) (clearp y) (not (eq x y)))        (ask x (erase))        (ask x (setq xpos (ask y xpos) ypos (- (ask y ypos) 40)))        (ask x (draw))        (state)))(defun table (x y)  (when (and (clearp x) (onp x y))        (ask x (erase))        (ask x (setq xpos (opening x) ypos 200))        (ask x (draw))        (state)))(defun transfer (x y z)  (when (and (clearp x) (onp x y) (clearp z) (not (eq x z)))        (ask x (erase))        (ask x (setq xpos (ask z xpos) ypos (- (ask z ypos) 40)))        (ask x (draw))        (state)))(defun clearp (x)  (freep (ask x xpos) (- (ask x ypos) 40) x))(defun tablep (x)  (= (ask x ypos) 200))(defun onp (x y)  (and (= (ask x xpos) (ask y xpos)) (= (ask x ypos) (- (ask y ypos) 40))))(defun abovep (x y)  (and (= (ask x xpos) (ask y xpos)) (< (ask x ypos) (ask y ypos))))(defun opening (x)  (cond ((freep 0 200 x) 0)        ((freep 40 200 x) 40)        ((freep 80 200 x) 80)        ((freep 120 200 x) 120)        ((freep 160 200 x) 160)))(defun state ()  (list (ask *red* (support))        (ask *orange* (support))        (ask *yellow* (support))        (ask *green* (support))        (ask *blue* (support))))(defun stdblocks ()  (ask *red* (setq xpos 0))  (ask *red* (have 'ypos 200))  (ask *orange* (have 'xpos 40))  (ask *orange* (have 'ypos 200))  (ask *yellow* (have 'xpos 0))  (ask *yellow* (have 'ypos 160))  (ask *green* (have 'xpos 120))  (ask *green* (have 'ypos 200))  (ask *blue* (have 'xpos 120))  (ask *blue* (have 'ypos 160))  (draw-world))(defun newblocks ()  (ask *red* (choose-location))  (ask *orange* (choose-location))  (ask *yellow* (choose-location))  (ask *green* (choose-location))  (ask *blue* (choose-location))  (adjust-blocks))(defun load-player ()  (load (choose-file-dialog)))(defun run-player ()  (player));;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Menubar setup;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(defparameter *special-menu*  (oneof *menu*         :menu-title "Special"         :menu-items (list (oneof *menu-item*                                  :menu-item-title "Load Player"                                  :menu-item-action 'load-player)                           (oneof *menu-item*                                  :menu-item-title "Run Player"                                  :menu-item-action 'run-player)                           (oneof *menu-item*                                  :menu-item-title "Quit"                                  :menu-item-action 'quit))))(defparameter *operations-menu*  (oneof *menu*         :menu-title "Operations"         :menu-items (list (oneof *menu-item*                                  :menu-item-title "Standard Blocks"                                  :menu-item-action 'stdblocks)                           (oneof *menu-item*                                  :menu-item-title "New Blocks"                                  :menu-item-action 'newblocks))))(defobject *world* *color-window-mixin* *window*)(defobfun (view-draw-contents *world*) ()  (let ((*current* (self)))    (draw-world)))(defun draw-world ()  (ask *red* (draw))  (ask *green* (draw))  (ask *yellow* (draw))  (ask *blue* (draw))  (ask *orange* (draw)))(defobfun (window-click-event-handler *world*) (where)  (let (x y)    (setq x (point-h where) y (point-v where))    (cond ((insidep x y *red*) (ask *red* (move-by-hand)))          ((insidep x y *green*) (ask *green* (move-by-hand)))          ((insidep x y *yellow*) (ask *yellow* (move-by-hand)))          ((insidep x y *blue*) (ask *blue* (move-by-hand)))          ((insidep x y *orange*) (ask *orange* (move-by-hand))))))(defun insidep (x y b)  (and (>= x (ask b xpos))       (<  x (+ (ask b xpos) 40))       (>= y (ask b ypos))       (<  y (+ (ask b ypos) 40))))(defun freep (x y b)  (and (>= x 0) (<= x 160) (>= y 0) (<= y 200)       (or (eq b *red*) (not (insidep x y *red*)))       (or (eq b *green*) (not (insidep x y *green*)))       (or (eq b *yellow*) (not (insidep x y *yellow*)))       (or (eq b *blue*) (not (insidep x y *blue*)))       (or (eq b *orange*) (not (insidep x y *orange*)))))(defun adjacentp (new-x new-y old-x old-y)  (cond ((= new-x old-x) (or (= new-y (+ old-y 40)) (= new-y (- old-y 40))))        ((= new-y old-y) (or (= new-x (+ old-x 40)) (= new-x (- old-x 40))))))(defun blocks-start ()  (setq *red* (oneof *block*))  (ask *red* (have 'xpos 0))  (ask *red* (have 'ypos 200))  (ask *red* (have 'pattern *white-pattern*))  (setq *orange* (oneof *block*))  (ask *orange* (have 'xpos 40))  (ask *orange* (have 'ypos 200))  (ask *orange* (have 'pattern *light-gray-pattern*))  (setq *yellow* (oneof *block*))  (ask *yellow* (have 'xpos 0))  (ask *yellow* (have 'ypos 160))  (ask *yellow* (have 'pattern *gray-pattern*))  (setq *green* (oneof *block*))  (ask *green* (have 'xpos 120))  (ask *green* (have 'ypos 200))  (ask *green* (have 'pattern *dark-gray-pattern*))  (setq *blue* (oneof *block*))  (ask *blue* (have 'xpos 120))  (ask *blue* (have 'ypos 160))  (ask *blue* (have 'pattern *black-pattern*))  (setq *blocks-bindings*        `((forall . ,(list *red* *orange* *yellow* *blue* *green*))          (white . ,*red*)          (light . ,*orange*)          (gray . ,*yellow*)          (dark . ,*green*)          (black . ,*blue*)          (table . tablep)          (clear . clearp)          (on . onp)          (above . abovep)))  (setq *current*        (oneof *world*               :window-position (make-point (truncate (- *screen-width* 220)) 50)               :window-title "Blocks"               :window-size #@(200 240)               :window-show nil))  (ask *current* (window-show)));;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;