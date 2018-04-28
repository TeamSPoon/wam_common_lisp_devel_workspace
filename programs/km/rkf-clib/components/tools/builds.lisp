;;
;;    $Id: builds.lisp,v 1.15 2008/02/22 16:33:20 tecuci Exp $
;;

(unless (find-package :km) (make-package :km))
(in-package :km)
(setq *using-km-package* t)

;; defined the driectories used in various builds
;; used in search and in computing spec-filename
(defvar *clib-builds*
    (flet ((translate-paths (dircomps-list)
	     (loop for dircomps in dircomps-list
		 collect (make-pathname :directory (cons :relative dircomps)
					:defaults nil))))
      `(("core" . ,(translate-paths '(("components" "core")
				      ("components" "specs"))))

	("all" . ,(translate-paths '(("components" "core") 
				     ("components" "specs")					     
				     ("components" "science" "shared")
				     ("components" "science" "biology") 
				     ("components" "science" "physics")
				     ("components" "science" "chemistry") 
				     ("components" "bsp"))))

	("science" . ,(translate-paths '(("components" "core") 
					 ("components" "specs") 
					 ("components" "science" "shared")
					 ("components" "science" "biology") 
					 ("components" "science" "physics")
					 ("components" "science" "chemistry") )))
	
	("biology" . ,(translate-paths '(("components" "core") 
					 ("components" "specs") 
					 ("components" "science" "shared")
					 ("components" "science" "biology"))))

	("chemistry" . ,(translate-paths '(("components" "core")
					   ("components" "specs") 
					   ("components" "science" "shared")
					   ("components" "science" "chemistry"))))

	("physics" . ,(translate-paths '(("components" "core") 
					 ("components" "specs") 
					 ("components" "science" "shared")
					 ("components" "science" "physics"))))

	("halo2" . ,(translate-paths '(("components" "core") 
				       ("components" "specs") 
				       ("components" "science" "shared")
				       ("components" "science" "bio-halo")
				       ("components" "science" "phys-halo")
				       ("components" "science" "chem-halo")
				       )))
	;; halo pumppriming
	("bio-halo" . ,(translate-paths '(("components" "core") 
					  ("components" "specs") 
					  ("components" "science" "shared")
					  ("components" "science" "bio-halo"))))
	("chem-halo" . ,(translate-paths '(("components" "core") 
					   ("components" "specs") 
					   ("components" "science" "shared")
					   ("components" "science" "chem-halo"))))
	("phys-halo" . ,(translate-paths '(("components" "core") 
					   ("components" "specs") 
					   ("components" "science" "shared")
					   ("components" "science" "phys-halo"))))

	("halo2-SME-chem" . ,(translate-paths '(("components" "core") 
						("components" "specs") 
						("components" "science" "shared")
						("components" "science" "chem-halo")
						("components" "science" "SME-chem")
				       )))
	("halo2-SME-phys" . ,(translate-paths '(("components" "core") 
						("components" "specs") 
						("components" "science" "shared")
						("components" "science" "phys-halo")
						("components" "science" "SME-phys")
				       )))
	("halo2-SME-bio" . ,(translate-paths '(("components" "core") 
					       ("components" "specs") 
					       ("components" "science" "shared")
					       ("components" "science" "bio-halo")
					       ("components" "science" "SME-bio"))))
	
	("lbr" . ,(translate-paths '(("components" "core") 
				     ("components" "specs") 
				     ("components" "science" "shared")
				     ("components" "science" "bio-lbr")
				     ("components" "science" "engine-lbr")
				     ("components" "science" "phys-halo"))))

	("calo" . ,(translate-paths '(("components" "core") 
				      ("components" "specs") 
				      ("components" "calo"))))

	("temp" . ,(translate-paths '(("components" "temp"))))
	("office" . ,(translate-paths '(("components" "core") 
					("components" "specs") 
					("components" "office")
					("components" "preq-extra"))))

	("bsp" . ,(translate-paths '(("components" "core") 
				     ("components" "specs") 
				     ("components" "bsp"))))

	("hovy" . ,(translate-paths '(("components" "core") 
				      ("components" "specs") 
				      ("components" "office")
				      ("components" "hovy"))))
	
	("exhaustive" . ,(translate-paths '(("components" "core") 
					    ("components" "specs") 
					    ("components" "science" "shared")
					    ("components" "science" "biology") 
					    ("components" "science" "physics")
					    ("components" "science" "chemistry") 
					    ("components" "science" "bio-halo")
					    ("components" "science" "phys-halo")
					    ("components" "science" "chem-halo")
					    ("components" "bsp")
					    ("components" "office"))))
	)))

