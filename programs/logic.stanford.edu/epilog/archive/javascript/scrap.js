//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

function plug (x,bl)

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

function compfindn (m,n,result,query,facts,rules)
 {var results = compfinds(result,query,facts,rules);
  if (results.length>=n) {return results.slice(m,n)};
  if (results.length>=m) {return results.slice(m)};
  return seq()}

function sortfinds (result,query,facts,rules)

function compone (p,pl,al,cont,facts,rules)
  inferences = inferences + 1;
  if (symbolp(str))
      if (matches!=null)
  for (var i=1; i<p.length-1; i++)
      {var arg = pluug(p[i],al,al);
       if (arg=='true') {total += 1}
          else {arg=parseFloat(arg);
                if (!isNaN(arg)) {total += arg}}};
  total = total+'';
  var ol = seq();
     {if (componeexit(pl,al,cont,facts,rules))
  return false}
  for (var i=1; i<p.length-1; i++)
      {var arg = pluug(p[i],al,al);
       if (arg!='true')
          {arg=parseFloat(arg);
           if (isNaN(arg)) {result = 0}
              else {result = result * arg}}};
  result = result + '';
     {if (componeexit(pl,al,cont,facts,rules))
  return false}
  var arg = parseFloat(pluug(p[1],al,al));
  if (!isNaN(arg)) {min = arg};
  for (var i=2; i<p.length-1; i++)
      {var arg = parseFloat(pluug(p[i],al,al));
       if (isNaN(arg)) {arg = 0};
       if (arg<min) {min = arg}};
  min = min+'';
     {if (componeexit(pl,al,cont,facts,rules))
  return false}
  var ol = seq();
  var result = seq('listof').concat(compfinds(p[1],p[2],facts,rules));
  if (vnifyp(p[3],al,result,al,ol))
     {if (componeexit(pl,al,cont,facts,rules))

function componenot (p,pl,al,cont,facts,rules)
  for (var i=0; i<data.length; i++)
  inferences = inferences + 1;

  if (symbolp(str))
      if (matches!=null)
  for (var i=1; i<p.length-1; i++)
      {var arg = pluug(p[i],al,al);
       if (arg=='true') {total += 1}
          else {arg=parseFloat(arg);
                if (!isNaN(arg)) {total += arg}}};
  total = total+'';
  var ol = seq();
     {compallexit(pl,al,cont,facts,rules); backup(ol)};
  return false}
  for (var i=1; i<p.length-1; i++)
      {var arg = pluug(p[i],al,al);
       if (arg!='true')
          {arg=parseFloat(arg);
           if (isNaN(arg)) {result = 0}
              else {result = result * arg}}};
  result = result + '';
     {compallexit(pl,al,cont,facts,rules); backup(ol)};
  return false}
  var arg = parseFloat(pluug(p[1],al,al));
  if (!isNaN(arg)) {min = arg};
  for (var i=2; i<p.length-1; i++)
      {var arg = parseFloat(pluug(p[i],al,al));
       if (isNaN(arg)) {arg = 0};
       if (arg<min) {min = arg}};
  min = min+'';
     {compallexit(pl,al,cont,facts,rules); backup(ol)};
  return false}
  if (varp(arg))  {return false};
  var val = symbolize(arg);
  var ol = seq();
     {compallexit(pl,al,cont,facts,rules); backup(ol)};
  return false}

function compallbagofall (x,p,pl,al,cont,results,facts,rules)
  var ol = seq();
  var answers = seq();
  compall(p[1],p[2],seq(),al,nil,answers,facts,rules);
  var result = seq('list').concat(answers);
  if (vnifyp(p[3],al,result,al,ol))
     {compallexit(x,pl,al,cont,results,facts,rules);
      backup(ol);
      return false};

function compallnot (p,pl,al,cont,facts,rules)
     {compallexit(pl,al,cont,facts,rules)}}
  //var data = indexees(p[0],facts);
  var data = envvndexps(p,al,facts);
  for (var i=0; i<data.length; i++)

//------------------------------------------------------------------------------

function baseonematches (p,pl,al,facts,rules)
  if (symbolp(str))
      if (matches!=null)
  if (symbolp(str))
      if (matches!=null)
//------------------------------------------------------------------------------
// residue
//   current version assumes query is ground
//   current version does not do negation as failure (correctly)
//   current version does not do consistency check (incorrectly)
//------------------------------------------------------------------------------
  return answer}
     {return resoneexit(pl,al,adjoin(p,rl),prims,rules)};
  if (symbolp(str))
      if (matches!=null)
     {return resallprim(p,pl,al,rl,prims,rules)};
  if (symbolp(str))
      if (matches!=null)

function resallprim (p,pl,al,rl,prims,rules)
 {return resallexit(pl,al,rl.concat([p]),prims,rules)}
  return false}

//------------------------------------------------------------------------------
// viewresidue
//   current version assumes query is ground
//   current version does not do negation as failure (correctly)
//   current version does not do consistency check (incorrectly)
//------------------------------------------------------------------------------
  return answer}
     {return viewresoneexit(pl,al,adjoin(p,rl),prims,facts,rules)};
     {return viewresoneexit(pl,al,rl,prims,facts,rules)};
  if (symbolp(str))
      if (matches!=null)
     {return viewresoneexit(pl,al,prims,facts,rules)}
     {return viewresallexit(pl,al,adjoin(p,rl),prims,facts,rules)};
  viewresallbackground(p,pl,al,rl,prims,facts,rules);
     {viewresallexit(pl,al,rl,prims,facts,rules)}}
  if (symbolp(str))
      if (matches!=null)
     {viewresallexit(pl,al,prims,facts,rules)}}
      {viewresall(p[i],pl,al,rl,prims,facts,rules)}}
              {viewresall(copy[2],concatenate(copy.slice(3),pl),bl,rl,prims,facts,rules)}}
     {return viewresall(pl[0],tail(pl),bl,rl,prims,facts,rules)};
  return false}

//------------------------------------------------------------------------------