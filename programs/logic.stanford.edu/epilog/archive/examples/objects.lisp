;;; Object indexing via relational indexing;;;;;; Suppose we have the following database.  (p a b)  (p b c)  (q a d)  (q b e)We reformulate the database as shown below.  (a p b)  (a q d)  (b p c)  (b q e)  (<= (p ?x ?y) (?x p ?y))  (<= (q ?x ?y) (?x q ?y))