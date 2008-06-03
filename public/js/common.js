function message(v, cont){
  common_query(v, cont, '/message/complete');
}

function common_query(v, cont, uri){
  $.get(uri, {q:v}, function(obj) {
    var res = [];
    var lines = obj.split("\n");
    $.each(lines, function(i, e){
      res.push({id:i, value:e});
    });
    cont(res);
  });
}
