function scrollTo(id){
  alert(id);
  document.getElementById(id).scrollIntoView();
}

function openPortal() {
  var tabOrWindow = window.open('http://www.portal-zer0trace.com/Portal/clientM.html', '_blank');
  tabOrWindow.focus();

}
