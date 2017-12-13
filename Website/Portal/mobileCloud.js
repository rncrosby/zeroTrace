function getUpcoming() {
	var sesh = window.sessionStorage.getItem("signedIn");
	var code = window.sessionStorage.getItem("clientCode");
	var email = window.sessionStorage.getItem("email");
	var client = window.sessionStorage.getItem("clientName");
	var jobTitles = [];
	var jobCodes = [];
	var jobCompletion = [];
	var code = window.sessionStorage.getItem("clientCode");
	firebase.database().ref('/upcomingJobs/').once('value').then(function(snapshot) {
		snapshot.forEach(function(child){
			var obj = child.val();
			if (obj["client"] == code) {
				jobTitles.push(obj['dateText']);
				jobCodes.push(obj['code']);
				jobCompletion.push(0);
			}
		});
		var fire = firebase.database();
		fire.ref('/'+code).once('value').then(function(snap) {
			snap.forEach(function(child){
				var obj = child.val();
				jobTitles.push(obj['dateText']);
				jobCodes.push(obj['code']);
				jobCompletion.push(1);
			});
			var container = document.getElementById('jobsContainer');
			for (var i = 0; i < jobTitles.length; i++) {
				var job = document.createElement("div");
				var positionInfo = job.getBoundingClientRect();
				var rightMargin = positionInfo.width.toString() + "px";
				if (jobCompletion[i] == 1) {
					var chevron = document.createElement("img");
					chevron.id = "chevron";
					chevron.style.marginRight = rightMargin;
					job.appendChild(chevron);
					var jobStatus = document.createElement("div");
					jobStatus.id = "jobComplete";
					job.appendChild(jobStatus);
					job.id = "jobObject";
					job.setAttribute("code",jobCodes[i]);
					job.onclick = function() {
							openJob(this);
					}
				} else {
					var jobStatus = document.createElement("div");
					jobStatus.id = "jobPending";
					container.appendChild(jobStatus);
					var job = document.createElement("div");
					job.id = "jobObject";
					job.setAttribute("code",jobCodes[i]);
					job.onclick = function() {
						upcomingJob(this);
					}
				}
				var jobDate = document.createElement("p");
				jobDate.id = "JobDate";
				jobDate.innerHTML = jobTitles[i];
				var jobCode = document.createElement("p");
				jobCode.id = "jobCode";
				jobCode.innerHTML = jobCodes[i];
				job.appendChild(jobDate);
				job.appendChild(jobCode);
				container.appendChild(job);
			}
			});
		});
}

function openJob(object) {
	var jobCode = object.getAttribute("code");
	var clientCode = window.sessionStorage.getItem("clientCode");
	window.location.href = "jobM.html?client=" + clientCode + '?code=' + jobCode;
}

function upcomingJob() {

}

function scheduleJob(form) {
	var code = window.sessionStorage.getItem("clientCode");
	var email = window.sessionStorage.getItem("email");
	var client = window.sessionStorage.getItem("clientName");
	var date = form.date.value;
	var drives = form.drives.value;
	var addressLine1 = form.line1.value;
	var addressLine2 = form.line2.value;
	var city = form.city.value;
	var state = form.state.value;
	var zip = form.zip.value;
	var address = addressLine1 + '\n' + addressLine2 + '\n' + city + '\n' + state + '\n' + zip;
	var geocoder = new google.maps.Geocoder();
  geocoder.geocode({'address': address}, function(results, status) {
    if (status === 'OK') {
			var longitude = results[0].geometry.location.lng();
			var latitude = results[0].geometry.location.lat();
      console.log(latitude + ',' + longitude);
			var epoch = moment(date).unix();
			var jobID = makeid();
			var rootRef = firebase.database().ref('upcomingJobs/' + jobID).set({
				"client": code,
				"clientName" : client,
				"code" : jobID,
				"confirmed" : 0,
				"date" : epoch,
				"dateText" : moment(date).format('dddd, MMMM D'),
				"drives" : parseInt(drives),
				"email" : email,
				"location-lat": latitude,
				"location-lon" : longitude
			}, function(error) {
			  if (error) {
			    alert(error);
			  } else {
			    window.location.href = "clientPortalM.html";
			  }
			});
    } else {
      alert('Geocode was not successful for the following reason: ' + status);
    }
	});
	return false;
}

	function getJob() {
		var full = window.location.href.split("?");
		var clientCode = full[1].split("=");
		clientCode = clientCode[1];
		var jobCode = full[2].split("=");
		jobCode = jobCode[1];
		// var jobCode = window.sessionStorage.getItem("jobCode");
		// var clientCode = window.sessionStorage.getItem("clientCode");
		console.log(jobCode + clientCode);
		var database = firebase.database();
		database.ref('/' + clientCode + '/' + jobCode).once('value').then(function(snapshot) {
			var job = snapshot.val();
			var serials = job['driveSerials'];
			var times = job['driveTimes'];
			var date = job['dateText'];
			var signatureURL = job['signatureURL'];
			var videoURL = job['videoURL'];
			var secMHeight = "0px";
			document.getElementById("menuBarText").innerHTML = date;
			document.getElementById("DRIVECOUNT").innerHTML = serials.length;
			document.getElementById("JOBID").innerHTML = jobCode;
			var signature = document.getElementById('signature');
			signature.setAttribute('src', signatureURL)
			var playerInstance = jwplayer("videoPlayer");
			var widthNum = (window.innerWidth > 0) ? window.innerWidth : screen.width;
			var width = (window.innerWidth > 0) ? window.innerWidth : screen.width;
			if (width > 700) {
				width = 700;
				widthNum = 700;
			}
			var heightNum = widthNum/1.8;
			width = width.toString() + "px";
			height = heightNum.toString() + "px";
			newHeight = heightNum + 450;
			secMHeight = newHeight +450+ "px";
			document.getElementById("driveContainer").style.marginTop = secMHeight;
			var stringHeight = -1 * newHeight;
			stringHeight = stringHeight + "px";
			document.getElementById("drives").style.marginTop = stringHeight;
			playerInstance.setup({
			    file: videoURL,
			    width: width,
					height: height,
					"skin": {
						"name" : "myskin"
					}
			});

			for (var i = 0; i < serials.length; i++) {
        var drive = document.createElement("div");
        drive.id = "driveObject";
				drive.className = "driveClass";
        drive.setAttribute("time",times[i]);
				drive.onclick = function() {
					skimToTime(this);
				}
        var container = document.getElementById('drives');
        var serial = document.createElement("p");
        serial.id = "driveSerial";
        serial.innerHTML = serials[i];
        var time = document.createElement("p");
        time.id = "driveTime";
        var date = new Date(null);
        date.setSeconds(times[i]); // specify value for SECONDS here
        var result = date.toISOString().substr(11, 8);
        time.innerHTML = result;
        drive.appendChild(serial);
        drive.appendChild(time);
        container.appendChild(drive);
			}


			});

	}
  function checkCode(form) {
    if (form.code.value.length < 5 || form.code.value.length > 5) {
			document.getElementById("cardHead").innerHTML = "Try Again";
      document.getElementById("cardSubHead").innerHTML = "The code should be<br>5 digits long";
		} else {
			var foundResult = 0;
			var database = firebase.database();
			firebase.database().ref('/').once('value').then(function(snapshot) {
				snapshot.forEach(function(child){
					var obj = child.val();
					if (!("code" in obj)) {
						for (var key in obj) {
							if (key == form.code.value) {
								var foundJob = obj[key];
								window.sessionStorage.setItem("signedIn", "false");
								window.sessionStorage.setItem("clientCode", foundJob["clientCode"]);
								window.sessionStorage.setItem("jobCode", foundJob["code"]);
								window.location.href = "jobM.html?client=" + foundJob["clientCode"] + '?code=' + foundJob["code"];
								foundResult = 1;
								return false;
							}
							}
					}
    		});
				if (foundResult == 0) {
					document.getElementById("cardHead").innerHTML = "Try Again";
		      document.getElementById("cardSubHead").innerHTML = "Code not found";
				}
			});
		}
    return false;
  }
  function skimToTime(object) {
    var playerInstance = jwplayer("videoPlayer");
    playerInstance.seek(object.getAttribute("time"));
  }
	function handleSignout() {
		window.sessionStorage.setItem("signedIn", "false");
		window.sessionStorage.setItem("clientCode", "");
		window.sessionStorage.setItem("email", "");
		window.sessionStorage.setItem("clientName", "");
		window.location.href = "codeM.html";
	}
	function handleJobClose() {
		var text = window.sessionStorage.getItem("signedIn");
		if (text == "true") {
			window.location.href = "clientPortalM.html";
		} else {
			window.location.href = "codeM.html";
			window.sessionStorage.setItem("signedIn","false");
			window.sessionStorage.setItem("code","");
		}
	}
	function checkClient(form){
		var username = form.clientName.value;
		var password = form.password.value;
		firebase.auth().signInWithEmailAndPassword(username, password).then(function(user) {
			var userID = username.split("@");
			firebase.database().ref(userID[0]).once('value').then(function(snapshot) {
				var code = snapshot.val().code;
				var email = snapshot.val().email;
				var clientName = snapshot.val().client;
				window.sessionStorage.setItem("signedIn", "true");
				window.sessionStorage.setItem("clientCode", code);
				window.sessionStorage.setItem("email", email);
				window.sessionStorage.setItem("clientName", clientName);
				window.location.href = "clientPortalM.html"
			});
			}).catch(function(error) {
		  // Handle Errors here.
		  var errorCode = error.code;
		  var errorMessage = error.message;
			if (errorCode) {
				document.getElementById("cardHead").innerHTML = "Error";
				document.getElementById("cardSubHead").innerHTML = error.message;
			}
		});
	}
	function notActivated() {
		var x = document.getElementById("snackbar")
		document.getElementById("snackbar").innerHTML = "Not Activated";
		x.className = "show";
		setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);
	}

	function showFooter() {
		var x = document.getElementById("footer")
		x.className = "show";
		setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);
	}

	function copyToClipboard() {
		var x = document.getElementById("snackbar")
		document.getElementById("snackbar").innerHTML = "Video Copied";
		x.className = "show";
		setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);
  // Create a "hidden" input
  var aux = document.createElement("input");

  // Assign it the value of the specified element
  aux.setAttribute("value", window.location.href);

  // Append it to the body
  document.body.appendChild(aux);

  // Highlight its content
  aux.select();

  // Copy the highlighted text
  document.execCommand("copy");

  // Remove it from the body
  document.body.removeChild(aux);

}

function handleRegistration(form) {
	var step = window.sessionStorage.getItem("signUp");
	var entry = form.fieldEntry.value;
	if (step == 0) {
		if (entry.length > 0) {
			document.getElementById("card").style.height = 220;
			window.sessionStorage.setItem("clientName", entry);
			window.sessionStorage.setItem("signUp", 1);
			document.getElementById("cardHead").innerHTML = entry;
			document.getElementById("cardSubHead").innerHTML = "Who will be dealing with mostly?";
			document.getElementById("fieldEntry").placeholder = "John Appleseed";
			document.getElementById("fieldEntry").value = "";
		}
	} else if (step == 1) {
		if (entry.length > 0) {
			window.sessionStorage.setItem("contactName", entry);
			window.sessionStorage.setItem("signUp", 2);
			document.getElementById("cardSubHead").innerHTML = "A number we can reach you at?";
			document.getElementById("fieldEntry").placeholder = "0000000000";
			document.getElementById("fieldEntry").value = "";
		}
	} else if (step == 2) {
		if (entry.length > 0) {
			window.sessionStorage.setItem("phone", entry);
			window.sessionStorage.setItem("signUp", 3);
			document.getElementById("cardSubHead").innerHTML = "An email we can reach you at?";
			document.getElementById("fieldEntry").placeholder = "email@email.com";
			document.getElementById("fieldEntry").value = "";
		}
	} else if (step == 3) {
		if (entry.length > 0) {
			window.sessionStorage.setItem("email", entry);
			window.sessionStorage.setItem("signUp", 4);
			document.getElementById("cardHead").innerHTML = "And finally,";
			document.getElementById("cardSubHead").innerHTML = "Create a secure password";
			document.getElementById("fieldEntry").placeholder = "password";
			document.getElementById("fieldEntry").type = "password";
			document.getElementById("fieldEntry").value = "";
		}
	} else if (step == 4) {
		if (entry.length > 0) {
				// var password = CryptoJS.AES.encrypt(entry, window.sessionStorage.getItem("clientName")).toString();
				var dict = []; // create an empty array
				var clientName = window.sessionStorage.getItem("clientName");
				var contactName = window.sessionStorage.getItem("contactName");
				var email = window.sessionStorage.getItem("email");
				var phone = window.sessionStorage.getItem("phone");
				var username = email.split("@");
				var code = makeid();
				var rootRef = firebase.database().ref(username[0]).set({
					"client": clientName,
					"contact" : contactName,
					"email" : email,
					"phone" : phone,
					"code"	: code
				});
				firebase.auth().createUserWithEmailAndPassword(email, entry).then(function(user) {
					}).catch(function(error) {
						window.sessionStorage.setItem("signedIn", "true");
						window.sessionStorage.setItem("clientCode", code);
						window.sessionStorage.setItem("email", email);
						window.sessionStorage.setItem("clientName", clientName);
						window.location.href = "clientPortalM.html"
				  	// Handle Errors here.
				  var errorCode = error.code;
				  var errorMessage = error.message;
					if (errorCode) {
						document.getElementById("cardHead").innerHTML = "Error";
						document.getElementById("cardSubHead").innerHTML = error.message;
					}
				});

			}
	}
	return false;

}
function makeid() {
  var text = "";
  var possible = "0123456789";

  for (var i = 0; i < 5; i++)
    text += possible.charAt(Math.floor(Math.random() * possible.length));

  return text;
}
