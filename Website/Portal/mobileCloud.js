function getAllJobs() {
		var sesh = window.sessionStorage.getItem("signedIn");
		console.log(sesh);
	  // 2
		CloudKit.configure({
				containers: [{
					containerIdentifier: 'iCloud.com.fullytoasted.ZER0trace-Internal',
					apiToken: '2d86e7c79d5ca11b06592a0c703cdfcb3869512c75629ae151d96f924a0fb696',
					environment: 'production'
				}]
			});

		var container = CloudKit.getDefaultContainer();
		var publicDatabase = container.publicCloudDatabase;
		var full = window.location.href.split("?");
		var code = full[1].split("=");
		// GET JOBS
		publicDatabase.fetchRecords(code[1]).then(function(response) {
		if (response.hasErrors) {
				// Insert error handling
				window.location.href = "processing.html";
		} else {
					var fetchedRecord = response.records[0];
					var jobTitles = fetchedRecord['fields']['allJobDates']['value'];
					var jobCodes = fetchedRecord['fields']['allJobCodes']['value'];
					var jobCompletion = fetchedRecord['fields']['allJobCompletion']['value'];
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
								var x = document.getElementById("snackbar")
								document.getElementById("snackbar").innerHTML = "This Job is Pending Completion";
								x.className = "show";
								setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);
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
					}
		}
	)}
	function openJob(object) {
		var code = object.getAttribute("code");
		window.location.href = "jobM.html?code=" + code;
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
								window.sessionStorage.setItem("signedIn", "");
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
		var sesh = window.sessionStorage.getItem("signedIn");
		if (sesh == "true") {
			window.sessionStorage.setItem("signedIn","");
			window.sessionStorage.setItem("code","");
			window.location.href = "clientM.html";
		} else {
			window.location.href = "codeM.html";
		}
	}
	function handleJobClose() {
		var sesh = window.sessionStorage.getItem("signedIn");
		if (sesh == "true") {
			var code = window.sessionStorage.getItem("code");
			window.location.href = "clientPortalM.html?code="+code.toString();
		} else {
			window.location.href = "codeM.html";
		}
	}
	function checkClient(form){
		var username = form.clientName.value;
		var password = form.password.value;
		firebase.auth().signInWithEmailAndPassword(username, password).then(function(user) {
			var userID = username.split("@");
			firebase.database().ref(userID[0]).once('value').then(function(snapshot) {
				var code = snapshot.val().code;
				window.sessionStorage.setItem("signedIn", "true");
				window.sessionStorage.setItem("code", code);
				window.location.href = "clientPortalM.html?code=" + code;
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
				var rootRef = firebase.database().ref(username[0]).set({
					"client": clientName,
					"contact" : contactName,
					"email" : email,
					"phone" : phone,
					"code"	: makeid()
				});
				firebase.auth().createUserWithEmailAndPassword(email, entry).then(function(user) {
					window.location.href = "processing.html";
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
