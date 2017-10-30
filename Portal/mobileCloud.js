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
				alert("Something Went Wrong");
		} else {
					var fetchedRecord = response.records[0];
					var jobTitles = fetchedRecord['fields']['allJobDates']['value'];
					var jobCodes = fetchedRecord['fields']['allJobCodes']['value'];
					var jobCompletion = fetchedRecord['fields']['allJobCompletion']['value'];
					var container = document.getElementById('jobsContainer');
					for (var i = 0; i < jobTitles.length; i++) {

						if (jobCompletion[i] == 1) {
							var chevron = document.createElement("img");
							chevron.id = "chevron";
							container.appendChild(chevron);
							var jobStatus = document.createElement("div");
							jobStatus.id = "jobComplete";
							container.appendChild(jobStatus);
							var job = document.createElement("div");
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
		console.log("Preparing iCloud");
		CloudKit.configure({
				containers: [{
					containerIdentifier: 'iCloud.com.fullytoasted.ZER0trace-Internal',
					apiToken: 'af60d3e793d45807555d470d8a6972dc50b182a36aa0772d612c1c37ad8d16be',
					environment: 'production'
				}]
			});

  		var container = CloudKit.getDefaultContainer();
  		var publicDatabase = container.publicCloudDatabase;
      var full = window.location.href.split("?");
  		var code = full[1].split("=");
  		publicDatabase.fetchRecords(code[1]).then(function(response) {
  		if (response.hasErrors) {
  				alert("No Video Found");
  		} else {
  					var fetchedRecord = response.records[0];
						console.log(fetchedRecord);
  					if (fetchedRecord['fields']['driveSerials']) {
  						var serials = fetchedRecord['fields']['driveSerials']['value'];
  						var times = fetchedRecord['fields']['driveTimes']['value'];
  						for (var i = 0; i < serials.length; i++) {
                var drive = document.createElement("div");
                drive.id = "driveObject";
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
  						var date = fetchedRecord['fields']['jobDate']['value'];
  						document.getElementById("menuBarText").innerHTML = date;
  						document.getElementById("DRIVECOUNT").innerHTML = serials.length;
  						document.getElementById("JOBID").innerHTML = fetchedRecord['fields']['code']['value'];
  						var signature = document.getElementById('signature');
  						signature.setAttribute('src', fetchedRecord['fields']['signatueURL']['value'])
  						var playerInstance = jwplayer("videoPlayer");
							var widthNum = (window.innerWidth > 0) ? window.innerWidth : screen.width;
							var width = (window.innerWidth > 0) ? window.innerWidth : screen.width;
							var heightNum = widthNum/1.8;
							width = width.toString() + "px";
							height = heightNum.toString() + "px";
							newHeight = heightNum + 45;
							Mheight = newHeight.toString() + "px";
							document.getElementById("drives").style.marginTop = Mheight;
  						playerInstance.setup({
  						    file: fetchedRecord['fields']['videoURL']['value'],
  						    width: width,
									height: height,
  								"skin": {
  									"name" : "myskin"
  								}
  						});


  					}
					}

  		}
  	);
	}
  function checkCode(form) {
    if (form.code.value.length < 5 || form.code.value.length > 5) {
			document.getElementById("cardHead").innerHTML = "Try Again";
      document.getElementById("cardSubHead").innerHTML = "The code should be<br>5 digits long";
		} else {
      CloudKit.configure({
  				containers: [{
  					containerIdentifier: 'iCloud.com.fullytoasted.ZER0trace-Internal',
  					apiToken: '2d86e7c79d5ca11b06592a0c703cdfcb3869512c75629ae151d96f924a0fb696',
  					environment: 'production'
  				}]
  			});

    		var container = CloudKit.getDefaultContainer();
    		var publicDatabase = container.publicCloudDatabase;
    		publicDatabase.fetchRecords(form.code.value).then(function(response) {
    		if (response.hasErrors) {
    				// Insert error handling
            document.getElementById("cardHead").innerHTML = "Try Again";
            document.getElementById("cardSubHead").innerHTML = "This code is invalid.";
    		} else {
						window.sessionStorage.setItem("signedIn", "");
            window.location.href = "jobM.html?code="+form.code.value;
          }

    		}
    	);
  	// FINISH GET JOBS
  	// START GET CURRENTJOB
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
		CloudKit.configure({
				containers: [{
					containerIdentifier: 'iCloud.com.fullytoasted.ZER0trace-Internal',
					apiToken: 'af60d3e793d45807555d470d8a6972dc50b182a36aa0772d612c1c37ad8d16be',
					environment: 'production'
				}]
			});

			var container = CloudKit.getDefaultContainer();
			var publicDatabase = container.publicCloudDatabase;
			publicDatabase.fetchRecords(username).then(function(response) {
			if (response.hasErrors) {
					// Insert error handling
					console.log(response.errors);
					document.getElementById("cardHead").innerHTML = "Try Again";
					document.getElementById("cardSubHead").innerHTML = "Something isn't right withyour<br>username or password";
			} else {
					var fetchedRecord = response.records[0];
					console.log(fetchedRecord);
					var retrievedPassword = fetchedRecord['fields']['password']['value'];
					var decryptedretrievedPassword = CryptoJS.AES.decrypt(retrievedPassword, fetchedRecord['recordName']);
					decryptedretrievedPassword = decryptedretrievedPassword.toString(CryptoJS.enc.Utf8);
					if (password == decryptedretrievedPassword) {
						window.sessionStorage.setItem("signedIn", "true");
						window.sessionStorage.setItem("code", fetchedRecord['fields']['client']['value']);
						window.location.href = "clientPortalM.html?code=" + fetchedRecord['fields']['client']['value'];
					}
				}

			}
		);
		return false;
		// var decryptedUsername = CryptoJS.AES.decrypt(encryptedUsername, "encrypt");
		// decryptedUsername = decryptedUsername.toString(CryptoJS.enc.Utf8);
		// var decryptedPassword = CryptoJS.AES.decrypt(encryptedPassword, "encrypt");
		// decryptedPassword = decryptedPassword.toString(CryptoJS.enc.Utf8);
		// alert(username + "->" + encryptedUsername + "->" + decryptedUsername);
		// var decrypted = CryptoJS.AES.decrypt(encrypted, "Secret Passphrase");
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
				var password = CryptoJS.AES.encrypt(entry, window.sessionStorage.getItem("clientName")).toString();
				var dict = []; // create an empty array
				dict.key1 = window.sessionStorage.getItem("clientName");
				dict.key2 = window.sessionStorage.getItem("contactName");
				dict.key3 = window.sessionStorage.getItem("email");
				dict.key4 = window.sessionStorage.getItem("phone");
				dict.key5 = password;
				$.ajax({
            url: 'http://0.0.0.0:8000/register',
            data: dict,
            type: 'POST',
            success: function(response) {
							console.log(response);
							document.getElementById("cardHead").innerHTML = "All Set!";
							document.getElementById("cardSubHead").innerHTML = "Your registration is being processed,<br>you'll recieve an email when your registration is complete.";
            },
            error: function(error) {
							console.log("works");
                console.log(error);
            }
        });


		}
	}

	return false;
}
