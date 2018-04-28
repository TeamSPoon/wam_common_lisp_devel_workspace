;;; -*- Mode: LISP; Syntax: Common-Lisp; Package: BABYLON; Base: 10 -*-

(in-package "BABYLON")
 
;;; adopted to non SYMBOLICS machines for BABYLON 2.1 by Juergen Walther 10.5.89

;; __________________________________________________________________________
;;; make sure the k3-add-ons are loaded

(eval-when (eval compile load)   
  (bab-require 'k3-misc)      ; miscellaneous stuff
  (bab-provide 'k3-misc)
  (bab-require 'k3-print)	
  (bab-provide 'k3-print))    ; printing stuff
;; __________________________________________________________________________

(def-kb-instance k3-kb k3dummyc :pkg :ks)

;;; make sure unit-kb is loaded and imported
(do ()
    ((member 'unit-kb *known-knowledge-bases*)
     (progn
       ($send k3-kb :make-yourself-current)
       (send-kb :send-if-handles :import-kb unit-kb)
       "unit-kb imported"))
  (if (not (member 'unit-kb *known-knowledge-bases*))
    (cerror "Load << unit-kb >> before proceeding!"
            "Unknown Knowledge Base ~S" 'unit-kb)))

;; ********************************************************************************

;;                                 K3 - Stuff

;; ********************************************************************************

;; This file 
;; defines behaviors for translating constraint information
;; in component definitions into constraint nets. Such a constraint net 
;; can then be activated and evaluated using the CONSAT functions or the :put-if-satisfied
;; method.


(defvar *tex-i-constraint-net* nil)
(defvar *tex-i-net-name* (intern "CNET-FOR-K3-ROOT"))

(proclaim '(special *tex-i-constraint-net* *tex-i-net-name*))

;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :after :initialize) (ignore)
  (<- self :create-attachments))

  

;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :install-constraints) ()
  
  "this behavior produces the necessary side effects for
creating a constraint-net corresponding to the implicit
constraint definitions in K3 component hierarchies."
  
  (progn
    (<- self :create-constraint-net *tex-i-constraint-net*)
    (setf *tex-i-constraint-net* nil)))
 

;; ---------------------------------------------------------------------------------


;(defbehavior (compound-unit :you-are-the-root?) ()
;
;  ;; predicate. is true iff the instance is the root of a component hierarchy.
;  ;; if the object is a direct or indirect instance of frame functional-unit
;  ;; then the object is the root iff it has no functional supercomponent.
;  ;; otherwise the same test applies w.r.t. the physical hierarchy.
;
;  ;; Unfortunately, this behavior does not have the desired result when
;  ;; it is used during the automatic instance generation process started by
;  ;; :after :initialize of compound-unit. If it would work, the behaviors
;  ;; :install-constraints and [:after :initialize] could be mixed  into
;  ;; a single behavior, thus providing a fully automatic constraint generation
;  ;; process.
;
;  (<- self :is-recursively-generated) )
;
;  (COND ((<- SELF :TYPE 'FUNCTIONAL-UNIT)
;	 (NULL (<- SELF :GET-FUNCTIONAL-SUPERCOMPONENTS)))
;	(T (NULL (<- SELF :GET-PHYSICAL-SUPERCOMPONENTS)))))
						


;; ---------------------------------------------------------------------------------
  

(defbehavior (compound-unit :create-constraint-net) 
  (restrictions  &optional &key (guarded-option :all)	
                 (protected-option :none)) 
  
  "completes the contents of restrictions (*tex-i-constraint-net*)"
  
  (eval
   `(defrestriction ,*tex-i-net-name*
      (:guarded-slots ,guarded-option)
      (:protected-slots ,protected-option)
      (:restrictions ,@restrictions))))
  


;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :create-attachments) ()
  
  "extends *tex-i-constraint-net* with attachment clauses for the constraints
implicitly defined for the current instance."
  
  (let ((result nil)
        (slots (<- self :slots)))
    (setf result
          (append (<- self :create-horizontal-attachments slots)
                  (<- self :create-vertical-attachments slots)
                  (<- self :create-global-attachments slots)
                  (<- self :create-includes-attachments slots)
                  (<- self :create-region-and-local-attachments slots)))
    (if (<- self :constraints-of-instance-ok? result)
      (<- self :expand-attachments result))))

 
;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :constraints-of-instance-ok?) (constraints)
  (declare (ignore constraints))
  t)


;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :expand-attachments) (new-attachments)
  
  "extends *tex-i-constraint-net* by the attachments for the current
instance generated by :create-attachments. Internal constraint names
for k3-constraint references are omitted (forget-constraint-names)."
  
  (setf *tex-i-constraint-net* 
        (nconc *tex-i-constraint-net* 
               (forget-constraint-names new-attachments))))

;; ---------------------------------------------------------------------------------

(defun forget-constraint-names (an-attachment)

  ;; an-attachment has the structure
  ;;
  ;;    ( ((n1 . n2) (a b) ... (c d)) ...
  ;;      ((n3 . n4) (e f) ... (g h)) )
  ;;
  ;; the first component of the dotted pair is meant to represent the 
  ;; external constraint name, that is the name of the constraint as
  ;; specified in the constraint definition. the second component is 
  ;; the internal name of the constraint. 
  ;; This function modifies its argument (non-destructively in this version)
  ;; by replacing (ni.nj) by the atom ni.

  (mapcan #'(lambda (attach-list)
	      (list (cons (caar attach-list) (cdr attach-list))))
	  an-attachment))


;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :create-horizontal-attachments) (all-slots)
  
  ;; a horizontal specification has the structure
  ;;
  ;;     ( ([name-1] (iref1-1 slot1-1) ... (iref1-n1 s1-n1))
  ;;       ...
  ;;       ([name-m] (irefm-1 slotm-1) ... (irefm-nm sm-nm)) )
  ;;
  ;; this behavior yields a list of of elements each of a similar format. 
  ;; There are two differences: 
  ;; 1. all irefi-j's (which are slot names of the object) are replaced by the instance
  ;; names of the corresponding objects. these names are the values of the irefi-j
  ;; slots.
  ;; 2. The [name-i]-part is extended to a dotted pair (k3-equal-ni . name-i)
  ;; where name-i is nil if the [name-i]-part does not exist, and k3-equal-ni
  ;; is the name of the constraint to be defined for the horizontal definition.
  ;; Equality constraints for up to 5 arguments are predefined in this knowledge base.
  
  
  (prog (horizontal-attachments)
    (dolist (a-slot-name  all-slots)
      (let ((properties 
             (<- self :get-properties a-slot-name))) 
        (dolist (a-property properties)
          (if (equal a-property :HORIZONTAL)
            (extend-list horizontal-attachments
                         (<- self :translate-horizontals
                             all-slots
                             (<- self :get a-slot-name :HORIZONTAL)))))))
    (return horizontal-attachments)))


;; ---------------------------------------------------------------------------------

(defbehavior (compound-unit :translate-horizontals) (all-slots def-of-horizontals)
  (mapcan #'(lambda (def) 
              (list (<- self :create-a-horizontal-attachment def all-slots)))
          def-of-horizontals))


;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :create-a-horizontal-attachment) (a-horizontal all-slots)
  
  ;; result: ((k3-equal-n . [name]) (instance-name-1 slot-ref-1) ...
  ;;                                (instance-name-n slot-ref-n))
  ;; cf. documentation of :create-horizontal-attachments
  
  (let* ((named-p (atom (car a-horizontal)))
         (h-length (cond (named-p (length (cdr a-horizontal)))
                         (t (length a-horizontal))))
         (result nil))
    (prog1
      (setf result
            (cons (cons (intern (format nil "K3-EQUAL-~S" h-length))
                        (and named-p (car a-horizontal)))
                  (mapcan #'(lambda (a-reference)
                              (list (<- self :translate-direct-subcomponent-ref
                                        a-reference all-slots "horizontal")))
                          (cond (named-p (cdr a-horizontal))
                                (t a-horizontal))))))))
  


;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :create-vertical-attachments) (all-slots)
  
  ;; a :VERTICAL specification has the structure
  ;;
  ;;     ( ([name-1] (constraint-name-1 arg-1 ... arg-n))
  ;;       ...
  ;;       ([name-m] (constraint-name-m arg-1-m ... arg-k-m))
  ;;
  ;; where the arg-i's are atoms (parameters of the current instance) or tupels
  ;; (iref slot) with iref being the name of a slot of the current instance containing
  ;; a reference to a subcomponent of the current instance.
  ;;
  ;; This behavior yields a list of elements each having the structure
  ;;
  ;;     ( ((constraint-name-1 . [name-1]) arg-1' ... arg-n') ...
  ;;       ((constraint-name-m . [name-m]) arg-1-m' ... arg-k-m'))
  ;;
  ;; where arg-i' is   (<value(iref)> slot) iff arg-i is (iref slot)
  ;;                   (<object-name> slot) iff arg is slot
  ;;
  ;; At least one arg in each clause must refer to a slot of the current instance.
  ;;
  
  (prog (vertical-attachments)
    (dolist (a-slot-name all-slots)
      (let ((properties 
             (<- self :get-properties a-slot-name)))
        (dolist (a-property properties)
          (if (equal a-property :VERTICAL)
            (extend-list vertical-attachments
                         (<- self :translate-verticals
                             all-slots
                             (<- self :get a-slot-name :VERTICAL)))))))
    (return vertical-attachments)))


;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :translate-verticals) (all-slots def-of-verticals)
  (mapcan #'(lambda (def)
	      (cond ((at-least-one-atom?
		       (cond ((atom (car def)) (cdr def))
			     (t (car def))))
		     (list (<- self :create-a-vertical-attachment all-slots def)))
		    (t (error 
                        "Vertical specification ~S of ~S contains no reference to a slot of ~S" 
                        def ($send self :object-name) ($send self :object-name)))))
	  
	  def-of-verticals))


;; ----------------------------------------------------------------------------------


(defbehavior (compound-unit :create-a-vertical-attachment) (all-slots a-vertical)
  
  ;; result: ((constraint-name . [name]) (instance-name-1 slot-ref-1) ...
  ;;                                     (instance-name-n slot-ref-n))
  ;; cf. documentation of :create-vertical-attachments
  
  (let  ((named-p (atom (car a-vertical))))
    (cons  (cons (cond (named-p (cadr a-vertical))
                       (t       (caar a-vertical)))
                 (and named-p (car a-vertical)))
           (mapcan #'(lambda (a-reference)
                       (cond ((atom a-reference)
                              (list (<- self :translate-own-slot-ref 
                                        a-reference all-slots "vertical")))
                             (t (list (<- self :translate-direct-subcomponent-ref
                                          a-reference all-slots "vertical")))))
                   (cond (named-p (cddr a-vertical))
                         (t (cdar a-vertical)))))))
     


;; ----------------------------------------------------------------------------------


(defbehavior (compound-unit :translate-own-slot-ref) (a-ref all-slots ref-from)
  
  ;; a-ref is an atom and should be in all-slots. This behavior yields a list
  ;; (<object-name> a-ref)
  
  (cond ((not (member a-ref all-slots :test #'equal))	
         (error "~S in ~S specification of ~S is not a slot of ~S"
                a-ref ref-from ($send self :object-name) ($send self :object-name)))
        (t (list ($send self :object-name) a-ref))))


;; ----------------------------------------------------------------------------------


(defbehavior (compound-unit :translate-direct-subcomponent-ref) 
  (a-ref all-slots ref-from)
  
  ;; result: (instance-name-i slot-ref-i)
  ;;
  ;;         if the user specified a valid instance reference and an existing
  ;;         slot for the referred instance
  
  (if (not (and (atom (first a-ref))
                (atom (second a-ref))
                (= (length a-ref) 2)))
    (error "~S is incorrect ~S specification in ~S"
           a-ref  ref-from ($send self :object-name))
    (let ((instance-name (first a-ref))
          (slot-name (second a-ref)))
      (if (not (member instance-name all-slots :test #'equal))
        (error "~S in ~S specification ~S of ~S is not a valid component reference"
               instance-name  ref-from a-ref ($send self :object-name))
        (let ((ref-instance (<- self :get instance-name)))
          (if (not (is-instance ref-instance))
            (error "~S in ~S of ~S specification does not refer to a subcomponent of ~S"
                   instance-name a-ref ref-from ($send self :object-name))
            (let ((slots (<- ref-instance :slots)))
              (if (not (member slot-name slots :test #'equal))
                (error "~S in ~S of a ~S specification is not a slot of ~S"
                       slot-name  a-ref ref-from ref-instance)
                (list ref-instance slot-name)))))))))


;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :create-global-attachments) (all-slots)
  
  ;; a single :GLOBAL specification def-of-globals has the structure
  ;;
  ;;     ( ([name-1] (constraint-name-1 arg-1 ... arg-n))
  ;;       ...
  ;;       ([name-m] (constraint-name-m arg-1-m ... arg-k-m)))
  ;;
  ;; where the arg-i's are tupels 
  ;; (iref slot) with iref being the name of a slot of the current instance containing
  ;; a reference to a subcomponent of the current instance.
  ;;
  ;; This behavior yields a list of elements each having the structure 
  ;;
  ;;     ( ((constraint-name-1 . [name-1]) arg-1' ... arg-n') ...
  ;;       ((constraint-name-m . [name-m]) arg-1-m' ... arg-k-m'))
  ;;
  ;; where arg-i' is   (<value(iref)> slot) iff arg-i is (iref slot)
  ;;
  
  (prog (global-attachments)
    (dolist (a-slot-name  all-slots)
      (let ((properties (<- self :get-properties a-slot-name)))
        (dolist (a-property properties)
          (if (equal a-property :GLOBAL)
            (extend-list global-attachments
                         (<- self :translate-globals
                             all-slots
                             (<- self :get a-slot-name :GLOBAL)))))))
    (return global-attachments)))


;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :translate-globals) (all-slots def-of-globals)
  (mapcan #'(lambda (def)
              (list (<- self :create-a-global-attachment def all-slots)))
          def-of-globals))


;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :create-a-global-attachment) (a-global all-slots)
  
  ;; result: ((constraint-name . [name]) (instance-name-1 slot-ref-1) ...
  ;;                                     (instance-name-n slot-ref-n))
  ;; cf. documentation of :create-global-attachments
  
  (let ((named-p (atom (car a-global))))
    (cons (cons (cond (named-p (caadr a-global))
                      (t       (caar a-global)))
                (and named-p (car a-global)))
          (<- self :translate-ref-list (cond (named-p (cadr a-global))
                                             (t (cdr a-global)))
              all-slots :GLOBAL))))

;; ----------------------------------------------------------------------------------


(defbehavior (compound-unit :create-includes-attachments) (all-slots)
  
  ;; creates a list of attachments with an element for every :INCLUDES
  ;; property appearing under slots 'all-slots.
  ;; The value of an :INCLUDES property is of the form
  ;;
  ;;      ( (cname-1 arg-1-1 ... arg-n-1)
  ;;        ...
  ;;        (cname-m arg-m-1 ... arg-n-m) )
  ;;
  ;; Since :INCLUDES specify additional purely local constraints, all
  ;; arg-i-j's are atoms refering to slots in all-slots.
  
  (prog (includes-attachments)
    (dolist (a-slot-name all-slots)
      (let ((properties (<- self :get-properties a-slot-name)))
        (dolist (a-property properties)
          (if (equal a-property :INCLUDES)
            (progn
              (if (not (member :REGION properties))
                (error ":INCLUDES property of slot ~S has no corresponding :REGION property in ~S"
                       a-slot-name ($send self :object-name)))
              (extend-list includes-attachments
                           (<- self :translate-includes
                               a-slot-name all-slots
                               (<- self :get a-slot-name :INCLUDES))))))))
    
    (return includes-attachments)))


;; ----------------------------------------------------------------------------------

 
(defbehavior (compound-unit :translate-includes) (a-slot-name all-slots def-includes)
  (prog (attachments)
    (if (null def-includes)
      (error ":INCLUDES specification of slot ~S in ~S is empty"
             a-slot-name ($send self :object-name)))
    (dolist (an-include def-includes)
      (let ((cname (car an-include))
            (arglist (cdr an-include)))
        (if (not (atom cname))
          (error "~S in :INCLUDES of slot ~S in ~S is not the name of a constraint"
                 cname a-slot-name ($send self :object-name)))
        (let* ((cname-def (constraint-definition cname))
               (k3-cname (intern (format nil "K3-~S-~S"
                                         cname ($send self :object-name)))))
          (if (null cname-def)
            (error "Constraint ~S must be defined before using it in :INCLUDES of slot ~S of ~S"
                   cname a-slot-name ($send self :object-name)))
          ;;; this 'if' is not yet supported   (if (null k3-cname-def)
          (<- self :extend-constraint-condition 
              cname-def k3-cname (list a-slot-name))
          (extend-list attachments
                       `(((,k3-cname) ,@(<- self :translate-ref-list
                                            arglist all-slots :INCLUDES)))))))
    (return attachments)))


;; ----------------------------------------------------------------------------------

 
(defbehavior (compound-unit :translate-ref-list) (arglist all-slots mode)
  
  ;; arg-list should be a list of atoms or two-element lists.
  ;; 
  ;;    arg-list = (arg-1 ... arg-n)
  ;;
  ;; translate-ref-list returns a list
  ;;
  ;;    ret-arg-list = (ret-arg-1 ... ret-arg-n)
  ;;
  ;; where ret-arg-i is (,object-name arg-i) if arg-i is a slot name in all-slots,
  ;;       ret-arg-i is (<instance refered to by slot s> other-slot) if 
  ;;                 arg-i = (s other-slot) and s is a slot in all-slots.
  ;;
  ;; mode is  :INCLUDES, :REGION ... or . In INCLUDES mode all arg-i's must be atoms.
  
  (prog ()
    (if (and (member mode '(:INCLUDES))
             (not (all-elements-are-atoms? arglist)))
      (error "Argument list ~S of :~S specification of ~S contains non-local reference"
             arglist mode ($send self :object-name)))
    (return (mapcan #'(lambda (a-reference)
                        (cond ((atom a-reference)
                               (list (<- self :translate-own-slot-ref
                                         a-reference all-slots mode)))
                              (t (list (<- self :translate-direct-subcomponent-ref
                                           a-reference all-slots mode)))))
                    arglist))))

;; ----------------------------------------------------------------------------------

 
(defbehavior (compound-unit :extend-constraint-condition) (cname-def cname slot-list)
  
  ;; is used in :translate-includes and in :translate-locals
  
  (let* ((old-cond ($send cname-def :condition))
         (old-cond-t (cond ((null old-cond) t)
                           (t old-cond))))
    (eval `(defconstraint ,cname
             (:type primitive)
             (:interface ,@($send cname-def :interface))
             (:relation ,@($send cname-def :relation))
             (:condition (and ,old-cond-t
                              (or ,@(generate-region-conditions 
                                     slot-list ($send self :object-name)))))))))

	      
;; ----------------------------------------------------------------------------------



(defun generate-region-conditions (slot-list object-name)
  
  ;; for slot-list = (s1 ... sN) a structure
  ;;
  ;;     
  ;; ( (equal (global-values '(object-name s1) '<net-name>) '(T))
  ;;       ...
  ;;   (equal (global-values '(object-name sN)  '<net-name> '(T)) )
  ;; 
  ;; is generated.
  
  (mapcar #'(lambda (a-slot)
              `(equal (global-values '(,object-name ,a-slot) ',*tex-i-net-name*) '(T)))
          slot-list))


 
;; ----------------------------------------------------------------------------------


(defbehavior (compound-unit :create-region-and-local-attachments) (all-slots)
  
  ;; creates and evaluates a constraint
  ;;
  ;;   cn = "k3c-<frame-name>-<slot-name>
  ;;
  ;; for every slot with a :REGION property (in :create-region-constraint).
  ;; For these constraints corresponding attachments are generated.
  ;;
  ;; All constraints occuring in :LOCAL specifications except those which are
  ;; defined for all regions are transformed such that they are only active
  ;; in their respective regions.
  
  (prog (region-attachments region-slots exclude-specs)
    (dolist (a-slot-name all-slots)
      (let ((properties (<- self :get-properties a-slot-name)))
        (dolist (a-property properties)
          (if (equal a-property :REGION)
            (progn
              (extend-list region-attachments (<- self :create-region-constraint a-slot-name all-slots properties))
              (extend-list region-slots (list a-slot-name)))
            (if (equal a-property :EXCLUDES)
              (extend-list exclude-specs `((,a-slot-name . ,(<- self :get a-slot-name :EXCLUDES)))))))))
    (<- self :check-excludes exclude-specs region-slots)
    (dolist (a-slot-name all-slots)
      (let ((properties (<- self :get-properties a-slot-name)))
        (dolist (a-property properties)
          (if (equal a-property :LOCAL)
            (let ((local-definition (<- self :get a-slot-name :LOCAL)))
              (if (null local-definition)
                (error ":LOCAL property of slot ~S in ~S has no value" a-slot-name ($send self :object-name))
                (if (null region-slots)	;no region specified
                  (extend-list region-attachments
                               (<- self :create-local-attachments local-definition all-slots))
                  (extend-list region-attachments
                               (<- self :translate-local-constraints region-slots exclude-specs local-definition all-slots)))))))))  
    (return region-attachments)))


;; ---------------------------------------------------------------------------------

 
(defbehavior (compound-unit :check-excludes) (exclude-specs region-slots)
  
  ;; slot has a property :EXCLUDES which should have the structure
  ;;
  ;;    (cname-1 ... cname-N)
  ;;
  ;; The :EXCLUDES property may only be there if there is also a property
  ;; :REGION under the same slot. 
  
  (dolist (an-exclude exclude-specs)
    (let ((exclude-slot (car an-exclude)))
      (if (not (all-elements-are-atoms? an-exclude))
        (error "Incorrect EXCLUDES definition ~S in Slot ~S of ~S"
               an-exclude exclude-slot ($send self :object-name))
        (if (not (member exclude-slot region-slots :test #'equal))
          (error "Slot ~S of ~S has an :EXCLUDES property but no :REGION property"
                 exclude-slot ($send self :object-name)))))))

;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :create-region-constraint) (slot all-slots properties)
  
  ;; creates and evaluates a constraint definition corresponding to the
  ;; constraint definitions in the :REGION slot. Does also some syntactical
  ;; analysis.
  
  (declare (ignore properties))
  (prog* ((def-region  (<- self :get slot :REGION))
          (def-connector 
            (cond ((null def-region)
                   (error "region definition of region ~S in object ~S is empty"
                          slot ($send self :object-name)))
                  ((atom (car def-region))	
                   (car def-region))
                  (t 'AND)))
          (def-constraints 
            (cond ((null def-region)
                   (error "region definition of region ~S in object ~S is empty"
                          slot ($send self :object-name)))
                  ((atom (car def-region))
                   (cdr def-region))
                  (t def-region)))
          (def-includes (<- self :get slot :INCLUDES))
          (attachments))
    
    ;; attachments temporarily stores the list of variables to be used in
    ;; the result
    
    (analyze-includes  def-includes)
    (if (not (or (equal def-connector 'AND) (equal def-connector 'OR)))
      (error "Incorrect region specification for region ~S of ~S." slot ($send self :object-name)))
    (dolist (constraint-spec def-constraints)
      (extend-list attachments (<- self :define-region-constraint 
                                   slot all-slots constraint-spec)))
    (cond ((equal (length attachments) 1)	        ;only one constraint in region
           (return `((( ,(caaar attachments)) ,@(cdar attachments) (,($send self :object-name) ,slot)))))
          (t  (return (<- self :create-compound-region-constraint 
                          slot  attachments def-connector))))))

		     
				

;; ---------------------------------------------------------------------------------


(defun analyze-includes (include-def)		; not yet written
  (declare (ignore include-def))
  nil)


;; ---------------------------------------------------------------------------------

(defbehavior (compound-unit :define-region-constraint) (slot all-slots constraint)
  
  ;; creates a new constraint by modifying the user specified constraint.
  ;; (only if such a constraint does not already exist due to prior
  ;; activations of this method for the same constraint.
  ;;
  ;; the new constraint-definition is evaluated and corresponding 
  ;; attachments are created as a result
  
  (prog* ((constraint-name (car constraint))
          (old-constraint (constraint-definition constraint-name))
          (new-constraint-name (intern (format nil "K3C-~S" constraint-name))))
    (if (null old-constraint)
      (error "Constraint ~S being used in ~S is not yet defined"
             constraint-name ($send self :object-name)))
    ;;; this 'if is not yet supported:	 (if (null new-constraint)
    (prog ((old-variables ($send old-constraint :interface)))
      (eval `(defconstraint ,new-constraint-name
               (:type primitive)
               (:interface ,@(append old-variables (list 'WW)))
               (:relation
                ,@(translate-region-pattern-element 
                   ($send old-constraint :relation)
                   old-variables constraint-name slot ($send self :object-name)))
               (:condition 
                (and ,($send old-constraint :condition)
                     (constrained-p ,@old-variables))))))
    ;; in a later version one should avoid duplicate expressions of the
    ;; kind "constrained-p variable". This is not yet done.
    (return `(((,new-constraint-name) 
               ,@(<- self :translate-ref-list (cdr constraint) all-slots :REGION))))))



;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :create-compound-region-constraint) (slot attachments connector)
  
  ;; defines and evaluates compound constraint for all constraints composing
  ;; a region. generates corresponding attachments.
  
  (prog* ((constraint-name (intern (format nil "K3-~S-~S"  (<- self :TYPE) slot)))
          ;;	  (compound-constraint (constraint-definition constraint-name))
          (number-of-constraints  (length attachments))
          (and-or-constraint-name (intern (format nil "K3-~S-~S"
                                                  connector number-of-constraints)))
          (all-constraint-names (get-constraint-names attachments))
          (all-local-lists (get-all-variables 
                            all-constraint-names))
          (truth-value-variables (generate-variables number-of-constraints)))
    (if (> number-of-constraints 2)
      (make-compound-and-or-constraint connector number-of-constraints))
    ;; this 'if is not yet supported: (if (null compound-constraint) ...)
    (eval `(defconstraint ,constraint-name
             (:type compound)
             (:interface ,slot ,@(flatten all-local-lists))
             (:constraint-expressions
              (,and-or-constraint-name
               ,@truth-value-variables ,slot)
              ,@(constraint-expressions  
                 all-constraint-names all-local-lists truth-value-variables))))
    (return `(((,constraint-name) (,($send self :object-name) ,slot)
               ,@(get-translated-variables attachments))))))

;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :create-local-attachments) (local-constraints all-slots)
  
  ;; local-constraints is a structure
  ;;
  ;;    ( ([lname-1] (cname-1 slot-ref-1-1 ... slot-ref-n-1))
  ;;      ...
  ;;      ([lname-N] (cname-N slot-ref-1-M ... slot-ref-N-M)) )
  ;;    
  ;; This behavior is only called if constraints cname-1 to cname-N are valid 
  ;; in all regions of the current object. Therefore, no adjustments to particular
  ;; regions are needed. As a consequence, these locals can be handled in much the 
  ;; same way as global constraints. The only difference is that locals may only
  ;; refer to own slots in their slot-ref-i-j's.
  
  (mapcan #'(lambda (def)
              (list (<- self :create-a-local-attachment def all-slots)))
          local-constraints))
  
  
;; ---------------------------------------------------------------------------------
  
  
(defbehavior (compound-unit :create-a-local-attachment) (a-local all-slots)
  
  ;; result: ((constraint-name . [name]) (<object-name> slot-ref-1) ...
  ;;                                     (<object-name> slot-ref-n))
  ;; cf. documentation of :create-local-attachments
  
  (let ((named-p (atom (car a-local))))
    (cons (cons (cond (named-p (caadr a-local))
                      (t       (caar a-local)))
                (and named-p (car a-local)))
          (<- self :translate-ref-list (cond (named-p (cdadr a-local))
                                             (t (cdar a-local)))
              all-slots :LOCAL))))
  
  
  
;; ---------------------------------------------------------------------------------
  
  
(defbehavior (compound-unit :translate-local-constraints)
  (region-slots exclude-specs local-definitions all-slots)
  
  ;; local-definitions is as described for :create-local-attachments. This
  ;; time, however, these local constraints are restricted to those regions
  ;; where they are not explicitly excluded. There are two exceptions, which 
  ;; will cause an individual constraint in local-constraints to be handled 
  ;; the same way as in :create-local-attachments. In particular, a local constraint
  ;; is valid in all regions if
  ;;
  ;;      * it has no local name (hence, it cannot be excluded in any :EXCLUDES)
  ;;      
  ;;      * it is not excluded in any :EXCLUDES specification
  ;;
  ;; If a constraint is not valid in all regions then the constraint definition
  ;; must be extended and corresponding attachments will be generated.
  
  
  (mapcan #'(lambda (def)
              (list (<- self :translate-a-local-constraint 
                        region-slots exclude-specs def all-slots)))
          local-definitions))



;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :translate-a-local-constraint)
  (region-slots exclude-specs a-local all-slots)
  
  ;; result: an attachment for a-local
  
  (prog* 
    
    ((error-message (format nil "Incorrect :LOCAL definition ~S in object ~S."
                            a-local ($send self :object-name)))
     (named-p (cond ((or (null a-local) (atom a-local))
                     (error error-message))
                    (t (atom (car a-local)))))
     (local-name (cond (named-p (car a-local))
                       (t nil)))
     (cname (cond (named-p (cond ((or (null (cdr a-local)) (atom (cdr a-local)))
                                  (error error-message))
                                 (t (cond ((or (null (cadr a-local))
                                               (atom (cadr a-local)))
                                           (error error-message))
                                          (t (caadr a-local))))))
                  (t (cond ((or (null (car a-local)) (atom (car a-local)))
                            (error error-message))
                           (t (caar a-local))))))
     (variable-list (cond (named-p (cdadr a-local))
                          (t (cdar a-local))))
     (regions-of-a-local (set-difference 
                          region-slots
                          (occurs-not-in-regions local-name exclude-specs)
                          :test #'equal)))
    (if (or (not named-p)
            (equal (length region-slots)	;cname occurs in all regions
                   (length regions-of-a-local)))
      (return (<- self :create-a-local-attachment a-local all-slots)))
    (return (<- self :create-local-constraint
                cname local-name variable-list regions-of-a-local all-slots))))

	

;; ---------------------------------------------------------------------------------


(defbehavior (compound-unit :create-local-constraint)
  (cname local-name variable-list regions-of-a-local all-slots)
  (prog*
    ((cname-def (constraint-definition cname))
     (k3-cname (intern (format nil "K3-~S-~S" cname  ($send self :object-name)))))
    (if (null cname-def)
      (error "Constraint ~S must be defined before using it in :LOCAL of of ~S"
             cname  ($send self :object-name)))
    ;; this 'if is not yet supported    (if (null k3-cname-def)
    (<- self :extend-constraint-condition 
        cname-def k3-cname regions-of-a-local)
    (return  `(,(cons k3-cname local-name)
               ,@(<- self :translate-ref-list
                     variable-list all-slots :LOCAL)))))


;;; *********************************************************************************
;;; ************************* K3 constraint definitions *****************************

;;; the following constraint definitions are explicitly specified for efficiency;
;; Corresponding constraints with more than 5 arguments will be dynamically
;; constructed by need (in a later version of this program).

(DEFCONSTRAINT k3-equal-2
  (:TYPE PRIMITIVE)
  (:INTERFACE arg1 arg2)
  (:RELATION  (:PATTERN (arg1 arg1) :IF (constrained-p arg1))
              (:PATTERN (arg2 arg2) :IF (constrained-p arg2)))
  (:CONDITION (or (constrained-p arg1)
                  (constrained-p arg2))))

(DEFCONSTRAINT k3-equal-3
  (:TYPE PRIMITIVE)
  (:INTERFACE arg1 arg2 arg3)
  (:RELATION  (:PATTERN (arg1 arg1 arg1) :IF (constrained-p arg1))
              (:PATTERN (arg2 arg2 arg2) :IF (constrained-p arg2))
              (:PATTERN (arg3 arg3 arg3) :IF (constrained-p arg3)))
  (:CONDITION (or (constrained-p arg1)
                  (constrained-p arg2)
                  (constrained-p arg3))))

(DEFCONSTRAINT k3-equal-4
  (:TYPE PRIMITIVE)
  (:INTERFACE arg1 arg2 arg3 arg4)
  (:RELATION
   (:PATTERN (arg1 arg1 arg1 arg1) :IF (constrained-p arg1))
   (:PATTERN (arg2 arg2 arg2 arg2) :IF (constrained-p arg2))
   (:PATTERN (arg3 arg3 arg3 arg3) :IF (constrained-p arg3))
   (:PATTERN (arg4 arg4 arg4 arg4) :IF (constrained-p arg4)))
  (:CONDITION (or (constrained-p arg1)
                  (constrained-p arg2)
                  (constrained-p arg3)
                  (constrained-p arg4))))

(DEFCONSTRAINT k3-equal-5
  (:TYPE PRIMITIVE)
  (:INTERFACE arg1 arg2 arg3 arg4 arg5)
  (:RELATION
   (:PATTERN (arg1 arg1 arg1 arg1 arg1) :IF (constrained-p arg1))
   (:PATTERN (arg2 arg2 arg2 arg2 arg2) :IF (constrained-p arg2))
   (:PATTERN (arg3 arg3 arg3 arg3 arg3) :IF (constrained-p arg3))
   (:PATTERN (arg4 arg4 arg4 arg4 arg4) :IF (constrained-p arg4))
   (:PATTERN (arg5 arg5 arg5 arg5 arg5) :IF (constrained-p arg5)))
  (:CONDITION (or (constrained-p arg1)
                  (constrained-p arg2)
                  (constrained-p arg3)
                  (constrained-p arg4)
                  (constrained-p arg5))))


;; --------------------------------------------------------------------------------


(DEFCONSTRAINT k3-and-2
  (:TYPE PRIMITIVE)
  (:INTERFACE arg1 arg2 res)
  (:RELATION 
   (:TUPLE (T T T))
   (:TUPLE (T NIL NIL))
   (:TUPLE (NIL T NIL))
   (:TUPLE (NIL NIL NIL))))

(DEFCONSTRAINT k3-or-2
  (:TYPE PRIMITIVE)
  (:INTERFACE arg1 arg2 res)
  (:RELATION 
   (:TUPLE (T T T))
   (:TUPLE (T NIL T))
   (:TUPLE (NIL T T))
   (:TUPLE (NIL NIL NIL))))

;;; eof

