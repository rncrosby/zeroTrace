function destroyMethod(type) {
  var x = document.getElementById("typeContainer");
  var op = 1;  // initial opacity
  var timer = setInterval(function () {
        if (op <= 0.1){
            clearInterval(timer);
        }
        x.style.opacity = op;
        x.style.filter = 'alpha(opacity=' + op * 100 + ")";
        op -= op * 0.1;
    }, 15);
  var body = document.getElementsByTagName("BODY")[0];
  if (type == 'clean') {
      body.style.backgroundColor = '#B2DFDB';
      unfade(x);
      // x.innerHTML = "<div class='destructionMethodContainer' id='clean'><img src='clean.png' width='100%' height='auto' style='max-width: 1500px;'/></div>"
  } else if (type == 'purge') {
    body.style.backgroundColor = '#D1C4E9';
    unfade(x);
      // x.innerHTML = "<div class='destructionMethodContainer' id='purge'><img src='purge.png' width='100%' height='auto' style='max-width: 1500px;'/></div>"
  } else if (type == 'destroy') {
    unfade(x);
    body.style.backgroundColor = '#FFCDD2';
      // x.innerHTML = "<div class='destructionMethodContainer' id='destroy'><img src='destroy.png' width='100%' height='auto' style='max-width: 1500px;'/></div>"
  }
}
function unfade(element) {
    var op = 0.1;  // initial opacity
    element.style.display = 'block';
    var timer = setInterval(function () {
        if (op >= 1){
            clearInterval(timer);
        }
        element.style.opacity = op;
        element.style.filter = 'alpha(opacity=' + op * 100 + ")";
        op += op * 0.1;
    }, 10);
}
