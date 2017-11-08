function action(block) {
  if (block == 'A') {
    var a = document.getElementById('blockA');
    if (a.style.width == '0px') {
      a.style.width = '100%';
    } else {
      a.style.width = '0px';
    }
  }
  if (block == 'C') {
    var a = document.getElementById('blockC');
    if (a.style.width == '0px') {
      a.style.width = '100%';
    } else {
      a.style.width = '0px';
    }
  }
  if (block == 'E') {
    var a = document.getElementById('blockE');
    if (a.style.width == '0px') {
      a.style.width = '100%';
    } else {
      a.style.width = '0px';
    }
  }
}

function openPortal() {
  var tabOrWindow = window.open('http://www.portal-zer0trace.com/Portal/clientM.html', '_blank');
  tabOrWindow.focus();

}
