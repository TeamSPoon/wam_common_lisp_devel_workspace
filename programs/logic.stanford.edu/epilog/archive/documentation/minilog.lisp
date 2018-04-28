;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; (c) Copyright 2005 by Michael Genesereth.  All rights reserved.;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(defconstant *minilog* 1.0  "The value of this variable is the version of Minilog currently loaded.");;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Variables;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(defmethod indvarp (x) "(INDVARP X)  INDVARP takes any object as argument and returns T if and only if the  object is an individual variable."  (and (symbolp x) (eql #\? (char (symbol-name x) 0))))(defun newindvar () (gensym "?"));;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Unifier;;; This version assumes variables have been renamed.;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(defmethod mgu (x y) "(MGU X Y)  MGU takes two expressions as arguments and checks whether they are   meta-unifiable.  MGU returns the unifier if the check is successful,  and it returns NIL otherwise."  (mguexp x y '((t . t))))(defun mguexp (x y al)  (cond ((eq x y) al)	((indvarp x) (mguindvar x y al))	((atom x)         (cond ((indvarp y) (mguindvar y x al))               ((atom y) (if (equalp x y) al))))	((indvarp y) (mguindvar y x al))        ((atom y) nil)        (t (mguexpexp x y al))))(defun mguindvar (x y al)  (let (dum)    (cond ((setq dum (assoc x al :test #'eq)) (mguexp (cdr dum) y al))          ((eq x (setq y (mguindval y al))) al)	  ((and *occurcheck* (mguchkp x y al)) nil)          (t (acons x y al)))))(defun mguindval (x al)  (let (dum)    (cond ((and (varp x) (setq dum (assoc x al :test #'eq))) (mguindval (cdr dum) al))          (t x))))(defun mguchkp (p q al)  (cond ((eq p q))	((indvarp q) (mguchkp p (cdr (assoc q al :test #'eq)) al))        ((seqvarp q) (mguchkplist p (cdr (assoc q al :test #'eq)) al))	((atom q) nil)	(t (mguchkplist p q al))))(defun mguchkplist (p l al)  (some #'(lambda (x) (mguchkp p x al)) l))(defun mguexpexp (l m al)  (do ((l l (cdr l)) (m m (cdr m)))      ((null l) (if (null m) al))      (cond ((null m) (return nil))            ((setq al (mguexp (car l) (car m) al)))            (t (return nil)))));;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Standardizing variables;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(defmethod standardize (x) "(STANDARDIZE X)  STANDARDIZE takes an expression as argument and produces an equivalent   expression in which all variables have been given new names."  (let (alist)    (stdizeexp x)))(defun standardizeexp (x)  (cond ((varp x) (standardizevar x))	((atom x) x)	((eq 'quote (car x)) x)	(t (mapcar 'standardizeexp x))))(defun standardizevar (x)  (cond ((cdr (assoc x alist :test #'eq)))        ((indvarp x) (cdar (setq alist (acons x (newindvar) alist))))));;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Plugging in bindings;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(defmethod plug (x (al list))  (if (null (cdr al)) x (plugexp x al)))(defun plugexp (x al)  (cond ((indvarp x) (plugindvar x al))	((not (listp x)) x)	(t (do ((l x (cdr l)) (nl))               ((null l) (nreverse nl))               (setq nl (cons (plugexp (car l) al) nl))))))(defun plugindvar (x al)  (let (dum)    (cond ((setq dum (assoc x al :test #'eq)) (plugexp (cdr dum) al))          (t x))));;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Global variables for inference subroutines;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(defparameter *thing* nil)(defparameter *answer* nil)(defparameter *answers* nil)(defparameter *theory* nil);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; profindp;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(defun profindp (p th)  (profindx 't p th));;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; profindx;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(defun profindx (*thing* p *theory*)  (let (*answer*)    (when (proone p nil '((t . t))) *answer*)))(defun proone (p pl al)  (cond ((atom p) (prooners p pl al))        ((eq 'not (car p)) (prooneunprovable p pl al))        ((eq 'and (car p)) (prooneand p pl al))        ((eq 'or (car p)) (prooneor p pl al))        ((eq 'same (car p)) (proonesame p pl al))        ((eq 'distinct (car p)) (proonedistinct p pl al))        (t (prooners p pl al))))(defun prooneand (p pl al)  (prooneexit (append (cdr p) pl) al))(defun prooneor (p pl al)  (do ((l (cdr p) (cdr l)))      ((null l) nil)      (when (proone (car l) pl al) (return t))))(defun proonesame (p pl al)  (if (setq al (mguexp (cadr p) (caddr p) al)) (prooneexit pl al)))(defun proonedistinct (p pl al)  (unless (mguexp (cadr p) (caddr p) al) (prooneexit pl al)))(defun prooneunprovable (p pl al)  (unless (proone (cadr p) nil al) (prooneexit pl al)))(defun prooners (p pl al)  (do ((l *theory* (cdr l)) (q) (bl))      ((null l) nil)      (setq q (standardize (car l)))      (cond ((setq bl (mguexp q p al)) (when (prooneexit pl bl) (return t)))            ((and (listp q) (eq '<= (car q)) (setq bl (mguexp (cadr q) p al)))             (when (prooneexit (append (cddr q) pl) bl) (return t))))))(defun prooneexit (pl al)  (cond (pl (proone (car pl) (cdr pl) al))        (t (setq *answer* (plug *thing* al)))));;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; profinds;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(defun profinds (*thing* p *theory*)  (let (*answers*)    (proall p nil '((t . t)))    (nreverse (remove-duplicates *answers*))))(defun proall (p pl al)  (cond ((atom p) (proallrs p pl al))        ((eq 'not (car p)) (proallunprovable (cadr p) pl al))        ((eq 'and (car p)) (proalland p pl al))        ((eq 'or (car p)) (proallor p pl al))        ((eq 'same (car p)) (proallsame p pl al))        ((eq 'distinct (car p)) (proalldistinct p pl al))        (t (proallrs p pl al))))(defun proallunprovable (p pl al)  (unless (proone (cadr p) nil al) (proallexit pl al)))(defun proalland (p pl al)  (proallexit (append (cdr p) pl) al))(defun proallor (p pl al)  (do ((l (cdr p) (cdr l)))      ((null l) nil)      (proall (car l) pl al)))(defun proallsame (p pl al)  (if (setq al (mguexp (cadr p) (caddr p) al)) (proallexit pl al)))(defun proalldistinct (p pl al)  (unless (mguexp (cadr p) (caddr p) al) (proallexit pl al)))(defun proallrs (p pl al)  (do ((l *theory* (cdr l)) (q) (bl))      ((null l) nil)      (setq q (standardize (car l)))      (cond ((setq bl (mguexp q p al)) (proallexit pl bl))            ((and (listp q) (eq '<= (car q)) (setq bl (mguexp (cadr q) p al)))             (proallexit (append (cddr q) pl) bl)))))(defun proallexit (pl al)  (cond (pl (proall (car pl) (cdr pl) al))        (t (setq *answers* (cons (plug *thing* al) *answers*)) nil)));;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;