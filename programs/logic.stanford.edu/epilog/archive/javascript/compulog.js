//------------------------------------------------------------------------------

function makereduction (head,body)

function makeuniversal (variable,scope)
  if (s.length == 1) {return s[0]};
 {if (symbolp(p)) {return makenegation(p)};
  if (p[0] == 'not') {return p[1]};
  return makenegation(p)}
  return s}
  for (var i=0; i<r.length; i++)
  return vs}

 {for (var i=0; i<s.length; i++)
      {if (!safep(s[i])) {alert(grind(s[i])); return false}};
  return true}

function safep (exp)
 {if (symbolp(exp)) {return true};
  if (exp[0] != 'rule') {return groundp(exp)};
  return saferulep(exp)}

function groundp (exp)
 {if (varp(exp)) {return false};
  if (symbolp(exp)) {return true};
  for (var i=0; i<exp.length; i++)
      {if (!safep(exp[i])) {return false}};
  return true}

function saferulep (rule)
 {var vs = seq();
  for (var i=2; i<rule.length; i++)
      {vs = safevars(rule[i],vs);
       if (vs === false) {return false}};
  var hs = vars(rule[1]);
  for (var i=0; i<hs.length; i++)
      {if (!findq(hs[i],vs)) {return false}};
  return true}

function safevars (exp,vs)
 {if (varp(exp)) {return adjoin(exp,vs)};
  if (symbolp(exp)) {return vs};
  if (exp[0] == 'distinct')
     {if (groundedp(exp,vs)) {return vs} else {return false}};
  if (exp[0] == 'not')
     {if (groundedp(exp,vs)) {return vs}};
  for (var i=0; i<exp.length; i++)
      {vs = safevars(exp[i],vs);
       if (vs === false) {return false} else {return false}};
  return(vs)}
  
function groundedp (exp,vs)
 {if (varp(exp)) {return find(exp,vs)};
  if (symbolp(exp)) {return true};
  for (var i=0; i<exp.length; i++)
      {if (!groundedp(exp[i],vs)) {return false}};
  return true}

//------------------------------------------------------------------------------
      {exp=cons(arguments[i-1],exp)};
     else {return cons(car(l1),append(cdr(l1),l2))}}
  return assoc(x,cdr(al))}

function getbdg (x,al)
 {return al[x]}

function setbdg (x,al,y,bl)
 {var bdg = seq(y,bl);
  al[x] = bdg;
  return bdg}

function backup (bl)
 {for (var i=0; i<bl.length; i++) {bl[i].length = 0}}

//------------------------------------------------------------------------------
  var dum = al[x];
  return true}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

function vnifier (x,y)
  if (vnify(x,seq(),y,seq(),ol)) {return ol};
  backup(ol);
  return false}
  backup(ol);
  return false}
 {if (varp(x)) {return vnifyvar(x,al,y,bl,ol)};

  return true}

function vnifyval (y,bl)
function vnifyatom (x,al,y,bl,ol)
  if (varp(y)) {return vnifyvar(y,bl,x,al,ol)};
  return false}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

function pluug (x,al,bl)
 {if (varp(x)) {return pluugvar(x,al,bl)};
  if (al == bl) {return x};
  var rep = newvar();
  al[x] = seq(rep,bl);
// Storage
//------------------------------------------------------------------------------

var indexing = 'fullindexing'
var dataindexing = false
var ruleindexing = false

function definetheory (source,data)
 {emptytheory(source);
  definemore(source,data);
  return true}

function definemore (theory,data)
 {for (var i=0; i<data.length; i++) {insert(data[i],theory)};
  return true}

function definemorerules (theory,data)
 {for (var i=0; i<data.length; i++) {insertrule(data[i],theory)};
  return theory}

function emptytheory (theory)
 {theory.splice(0,theory.length);
  for (var x in theory) {delete theory[x]};
  return true}

//------------------------------------------------------------------------------

function drop (p,theory)
 {data = indexps(p,theory);
  for (var i=0; i<data.length; i++)
      {if (equalp(data[i],p)) {uninsert(data[i],theory); return data[i]}};
  return false}

function eliminate (object,theory)
 {var data = indexps(object,theory).concat();
  for (var i=0; i<data.length; i++)
      {if (data[i][1] == object) {uninsert(data[i],theory)}};
  return object}

//------------------------------------------------------------------------------

function insert (p,theory)
 {addcontent(p,theory);
  if (indexing) {index(p,p,theory)};
  return p}

function insertrule (p,theory)
 {addcontent(p,theory);
  if (ruleindexing) {relindex(p,p,theory)};
  return p}

function addcontent (p,theory)
 {theory.push(p);
  return p}

function index (x,p,theory)
 {if (varp(x)) {return p};
  if (symbolp(x)) {return indexsymbol(x,p,theory)};
  for (var i=0; i<x.length; i++) {index(x[i],p,theory)};
  return p}

function relindex (x,p,theory)
 {if (varp(x)) {return p};
  if (symbolp(x)) {return indexsymbol(x,p,theory)};
  if (x[0] == 'rule') {return relindex(x[1],p,theory)};
  return relindex(x[0],p,theory)}

function indexsymbol (x,p,theory)
 {if (x == 'map') {return p};
  if (!isNaN(Number(x))) {return p};
  var data = theory[x];
  if (data) {data.push(p)} else {theory[x] = seq(p)};
  return p}


function uninsert(p,theory)
 {if (indexing) {unindex(p,p,theory)};
  return remcontent(p,theory)}

function remcontent (p,theory)
 {for (var i=0; i<theory.length; i++)
      {if (theory[i]==p) {theory.splice(i,1); return p}};
  return false}

function unindex (x,p,theory)
 {if (varp(x)) {return p};
  if (symbolp(x)) {return unindexsymbol(x,p,theory)};
  for (var i=0; i<p.length; i++) {unindex(x[i],p,theory)};
  return p}

function unindexsymbol (x,p,theory)
 {if (theory[x]) {return remcontent(p,theory[x])} else {alert(x)}}


function indexps (p,theory)
 {if (indexing) {return fullindexps(p,theory)} else {return theory}}

function fullindexps (p,theory)
 {if (varp(p)) {return theory};
  if (symbolp(p)) {return indexees(p,theory)};
  for (var i=1; i<p.length; i++)
      {if (symbolp(p[i]) && !varp(p[i])) {return indexees(p[i],theory)}};
  return indexees(p[0],theory)}

function indexees (x,theory)
 {if (x != 'map' && isNaN(Number(x)))
     {var data = theory[x];
      if (data) {return data} else {return seq()}};
  return theory}

function envindexps (p,al,theory)
 {if (indexing) {return dataindexps(p,al,theory)} else {return theory}}

function dataindexps (p,al,theory)
 {if (!indexing) {return theory};
  if (varp(p)) {return theory};
  if (symbolp(p)) {return indexees(p,theory)};
  for (var i=1; i<p.length; i++)
      {var dum = unival(p[i],al);
       if (symbolp(dum) && !varp(dum)) {return indexees(dum,theory)}};
  return indexees(p[0],theory)}

function unival (x,al)
 {if (!varp(x)) {return x};
  var dum = assoc(x,al);
  if (dum) {return unival(cdr(dum),al)};
  return x}

function ruleindexps (p,theory)
 {if (!ruleindexing) {return theory};
  if (varp(p)) {return theory};
  if (symbolp(p)) {return indexees(p,theory)};
  if (p[0] == 'rule') {return ruleindexps(p[1],theory)};
  return indexees(p[0],theory)}

//------------------------------------------------------------------------------

function uniquify (ins)
 {var outs = seq();
  for (var i=0; i<ins.length; i++) {outs = adjoinit(ins[i],outs)};
  return outs}

function adjoinit (x,s)

function nconc (l1,l2)
 {for (var i=0; i<l2.length; i++) {l1.push(l2[i])};
  return l1}

//------------------------------------------------------------------------------
// compfindx
// compfinds

var thing;
var epitrace = false;

function compfindp (query,facts,rules)

//------------------------------------------------------------------------------

function compone (p,pl,al,cont,facts,rules)

function componeatom (p,pl,al,cont,facts,rules)
  if (p == 'false') {return false};
  return componers(p,pl,al,cont,facts,rules)}
  backup(ol);
  return false}
  return componeexit(pl,al,cont,facts,rules)}
     {var matches = p[1].match(p[2]);
      for (var i=0; i<matches.length; i++)
          {var ol = seq();
           if (vnifyp(p[3],al,matches[i],al,ol))
              {if (componeexit(pl,bl,cont,facts,rules))
                  {backup(ol); return true}}}};
  return false}
     {return componeexit(pl,al,cont,facts,rules)};
  return false}
      {if (compone(p[i],pl,al,cont,facts,rules)) {return true}};
  return false}

function componebackground (p,pl,al,cont,facts,rules)
  for (var i=0; i<data.length; i++)
       var ol = seq();
       if (vnifyp(data[i],bl,p,al,ol))
          {if (componeexit(pl,al,cont,facts,rules)) {backup(ol); return true};
           backup(ol)}}
  return false}

  for (var i=0; i<data.length; i++)
       var ol = seq();
       if (data[i][0] == 'rule')
              {var ql = data[i].slice(3);
               var nc = cons(seq(pl,al,cont),cont);
               if (compone(data[i][2],ql,bl,nc,facts,rules))
                  {backup(ol); return true};
               backup(ol)}}
                {if (componeexit(pl,al,cont,facts,rules))
                    {backup(ol); return true};
                 backup(ol)}}}
  return false}

function componeexit (pl,al,cont,facts,rules)
  if (nullp(cont)) {answer = pluug(thing,al,al); return true};
  return componeexit(car(cont)[0],car(cont)[1],car(cont)[2],facts,rules)}

//------------------------------------------------------------------------------

function compall (p,pl,al,cont,facts,rules)

function compallatom (p,pl,al,cont,facts,rules)
  if (p == 'false') {return false};
  return compallrs(p,pl,al,cont,facts,rules)}
     {compallexit(pl,al,cont,facts,rules); backup(ol)}}
  return compallexit(pl,al,cont,facts,rules)}
     {var matches = p[1].match(p[2]);
      for (var i=0; i<matches.length; i++)
          {var ol = seq();
           if (vnifyp(p[3],al,matches[i],al,ol))
              {compallexit(pl,bl,cont,facts,rules); backup(ol)}}}
  return false}

function compallbackground (p,pl,al,cont,facts,rules)
  for (var i=0; i<data.length; i++)
       var ol = seq();
       if (vnifyp(data[i],bl,p,al,ol))
          {compallexit(pl,al,cont,facts,rules);
           backup(ol)}}}

  for (var i=0; i<data.length; i++)
       var ol = seq();
       if (data[i][0] == 'rule')
              {var ql = data[i].slice(3);
               var nc = cons(seq(pl,al,cont),cont);
               compall(data[i][2],ql,bl,nc,facts,rules);
               backup(ol)}}
                {compallexit(pl,al,cont,facts,rules);
                 backup(ol)}}}}

function compallexit (pl,al,cont,facts,rules)
  if (nullp(cont)) {answers.push(pluug(thing,al,al)); return true};
  return compallexit(car(cont)[0],car(cont)[1],car(cont)[2],facts,rules)}

//------------------------------------------------------------------------------

function scanstring (cur)
  cur++;
   {exp = exp + input[cur];;
    cur++};
  output[output.length] = exp;
function letterp (charcode)
 {return ((charcode >= 65 && charcode <= 90) ||
          (charcode >= 97 && charcode <= 122))}

function parsedata (str)
    exp[exp.length] = parsexp('lparen','rparen')};

function parse (str)

// readkifdata
// readkif
//------------------------------------------------------------------------------

 {return kifdata(kifscan(str))}

function readkif (str)
 {return kif(kifscan(str))}

function kifscan (str)
  var exp = '';
  if (letterp(input.charCodeAt(cur)))
     {exp=input.slice(cur,cur+1).toUpperCase(); cur++}
     else {exp = 'VV'};

function kifscanstring (cur)
        {exp = exp + input[cur]; cur++};
  cur++;
  output[output.length] = exp
  return cur}
  return cur}

function kifdata (str)
 {str.push('eof');
  input = str;
  current = 0;
  exp = seq();
  while (current < input.length && input[current] != 'eof')
   {exp[exp.length] = kifexp()};
  return exp}

function kif (str)
 {str.push('eof');
  input = str;
  current = 0;
  return kifexp()}

function kifexp ()
 {var lexeme = input[current];
  if (lexeme == 'eof') {return nil};
  if (lexeme == '<=') {current++; return 'rule'};
  if (lexeme == 'lparen') {return kifparenlist()};
  current++; return lexeme}

function kifparenlist ()
 {var exp = seq();
  current++;
  if (input[current] == 'rparen') {current++; return exp};
  while (current < input.length && input[current] != 'eof')
   {exp.push(kifexp());
    if (input[current] == 'rparen') {current++; return exp}};
  return exp}

//------------------------------------------------------------------------------
                   '" type="checkbox"/></td>';