function openPortal() {
  var tabOrWindow = window.open('http://www.portal-zer0trace.com/Portal/clientM.html', '_blank');
  tabOrWindow.focus();
}

function destructionMethod(text) {
  var title = document.getElementByID('title');
  var description = document.getElementByID('description');
  var how = document.getElementByID('how');
  var when = document.getElementByID('when');
  if (text == 'clear') {
    title.innerHTML = 'Clear';
    description.innerHTML = 'Applies logical techniques to sanitize data in all user-addressable storage locations for protection against simple noninvasive data recovery techniques.';
    when.innerHTML = 'Hardware remains relevant and in good condition; redeploy extending return on investment';
    how.innerHTML = 'Utilize standard Read/Write commands to rewrite with a new value or using a menu option to reset the device to the factory state (where rewriting is not supported).';
  } else if (text == 'purge') {
    title.innerHTML = 'Purge';
    description.innerHTML = 'Applies physical or logical techniques that render target data recovery infeasible using state-of-the art laboratory techniques.';
    when.innerHTML = 'Hardware will be returned to lessor at end of lease OR Hardware has residual value and can be sold to offset replacement cost';
    how.innerHTML = 'Overwrite (aka wipe; erase) the storage media with new data utilizing specially developed and certified destruction software to perform 1 or more overwrite passes with various schemas.';
  } else if (text == 'destroy') {
    title.innerHTML = 'Destroy';
    description.innerHTML = 'Renders target data recovery (using state-of-the-art laboratory techniques) infeasible and results in the subsequent inability to use the media for storage of data.';
    when.innerHTML = 'Hardware is obsolete, has no further use or value or is damaged; recycle raw materials AND/OR contains extremely sensitive or classified information AND/OR is mandated by corporate/company/agency rule/policy';
    how.innerHTML = 'Degaussing with NSA EPL-D certified and calibrated equipment; shred demagnetized drives to 19mm particles.';
  }
}
