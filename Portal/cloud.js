var isComplete = 0;
	function prepareiCloud() {
		console.log("Preparing iCloud");
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
					initialVideo(jobCodes[0]);
					for (var i = 0; i < jobTitles.length; i++) {
						var driveObject = document.createElement("div");
						var line = document.createElement("div");
						line.id = "line";
						driveObject.id = "jobObject";
						var btn = document.createElement("button");
						btn.id = "jobButton";
						btn.setAttribute("code", jobCodes[i]);
						btn.addEventListener("click", getJob);
						var txt = document.createTextNode(jobTitles[i]);
						btn.appendChild(txt);
						driveObject.appendChild(btn);
						var container = document.getElementById('navBar');
						var subtext = document.createElement("p");
						subtext.id = "jobDate";
						var node = document.createTextNode(jobCodes[i]);
						if (jobCompletion[i] == 1) {
							var jobStatus = document.createElement("div");
							jobStatus.id = "jobComplete";
							container.appendChild(jobStatus);
						} else {
							var jobStatus = document.createElement("div");
							jobStatus.id = "jobPending";
							container.appendChild(jobStatus);
						}
						subtext.appendChild(node);
						container.appendChild(driveObject);
						container.appendChild(subtext);
						container.appendChild(line);
						// var btn = document.createElement("button");
						// btn.id = "timebutton";
						// btn.setAttribute("time", times[i]);
						// btn.appendChild(txtTime)
					}
		}
	});
	// FINISH GET JOBS
	// START GET CURRENTJOB
	}
	function getJob(event) {
		var button = event.target;
		var code = button.getAttribute("code");
		var container = CloudKit.getDefaultContainer();
		var publicDatabase = container.publicCloudDatabase;
		publicDatabase.fetchRecords(code).then(function(response) {
		if (response.hasErrors) {
				// Insert error handling
				alert("No Video Found");
		} else {


					var fetchedRecord = response.records[0];
					if (fetchedRecord['fields']['driveSerials']) {
						var myNode = document.getElementById("container");
						myNode.innerHTML = '';
						var serials = fetchedRecord['fields']['driveSerials']['value'];
						var times = fetchedRecord['fields']['driveTimes']['value'];
						for (var i = 0; i < serials.length; i++) {
							var driveObject = document.createElement("div");
							driveObject.id = "driveObject";
							var btn = document.createElement("button");
							btn.id = "timebutton";
							btn.setAttribute("time", times[i]);
							btn.addEventListener("click", skimToTime);
							var txt = document.createTextNode(serials[i]);
							btn.appendChild(txt);
							driveObject.appendChild(btn);
							var container = document.getElementById('container');
							container.appendChild(driveObject);
						}
						var driveSpacer = document.createElement("div");
						driveSpacer.id = "driveSpacer";
						var container = document.getElementById('container');
						container.appendChild(driveSpacer);
						var date = fetchedRecord['fields']['jobDate']['value'];
						document.getElementById("DATE").innerHTML = date;
						document.getElementById("DRIVECOUNT").innerHTML = serials.length + " Drives";
						document.getElementById("CODE").innerHTML = fetchedRecord['fields']['code']['value'];
						var signature = document.getElementById('signature');
						signature.setAttribute('src', fetchedRecord['fields']['signatueURL']['value'])
						var playerInstance = jwplayer("myElement");
						playerInstance.setup({
						    file: fetchedRecord['fields']['videoURL']['value'],
						    mediaid: "xxxxYYYY",
						    width: "60%",
								"skin": {
									"name" : "myskin"
								}
						});
					} else {
						var x = document.getElementById("snackbar")
						document.getElementById("snackbar").innerHTML = "This Job Has Not Occured Yet";
						x.className = "show";
						setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);
					}

		}
	});
	}
	function skimToTime(event) {
		var button = event.target;
		var time = button.getAttribute("time");
		var playerInstance = jwplayer("myElement");
		playerInstance.seek(time);
	}
	function validateFormSignUp(theForm) {
		alert("Coming Soon");
		return false;
	}
	function validateFormSignIn(theForm) {
		alert("Coming Soon");
		return false;
	}
	function validateForm(theForm) {
		if (theForm.code.value.length < 5 || theForm.code.value.length > 5) {
			document.getElementById("Title").innerHTML = "Something's Wrong";
		} else {
			if (theForm.code.value == "99999") {
				window.location.href = "player.html?code="+theForm.code.value;
			} else {
				document.getElementById("Title").innerHTML = "Not Activated";
			}

		}
    return false;
	}
	function initialVideo(code) {
		var container = CloudKit.getDefaultContainer();
		var publicDatabase = container.publicCloudDatabase;
		publicDatabase.fetchRecords(code).then(function(response) {
		if (response.hasErrors) {
				// Insert error handling
				alert("No Video Found");
		} else {

					var myNode = document.getElementById("container");
					myNode.innerHTML = '';
					var fetchedRecord = response.records[0];
					if (fetchedRecord['fields']['driveSerials']) {
						var serials = fetchedRecord['fields']['driveSerials']['value'];
						var times = fetchedRecord['fields']['driveTimes']['value'];
						for (var i = 0; i < serials.length; i++) {
							var driveObject = document.createElement("div");
							driveObject.id = "driveObject";
							var btn = document.createElement("button");
							btn.id = "timebutton";
							btn.setAttribute("time", times[i]);
							btn.addEventListener("click", skimToTime);
							var txt = document.createTextNode(serials[i]);
							btn.appendChild(txt);
							driveObject.appendChild(btn);
							var container = document.getElementById('container');
							container.appendChild(driveObject);
						}
						var driveSpacer = document.createElement("div");
						driveSpacer.id = "driveSpacer";
						var container = document.getElementById('container');
						container.appendChild(driveSpacer);
						var date = fetchedRecord['fields']['jobDate']['value'];
						document.getElementById("DATE").innerHTML = date;
						document.getElementById("DRIVECOUNT").innerHTML = serials.length + " Drives";
						document.getElementById("CODE").innerHTML = fetchedRecord['fields']['code']['value'];
						var signature = document.getElementById('signature');
						signature.setAttribute('src', fetchedRecord['fields']['signatueURL']['value'])
						var playerInstance = jwplayer("myElement");
						playerInstance.setup({
						    file: fetchedRecord['fields']['videoURL']['value'],
						    width: "60%",
								"skin": {
									"name" : "myskin"
								}
						});
						// var video = document.getElementById('video');
						// //video.setAttribute('src', fetchedRecord['fields']['videoURL']['value']);
						// video.currentTime = 0;
						// video.play();
					} else {
						var x = document.getElementById("snackbar")
						document.getElementById("snackbar").innerHTML = "This Job Has Not Occured Yet";
						x.className = "show";
						setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);
					}

		}
	});
	}

	function newJob() {
		var x = document.getElementById("snackbar")
		document.getElementById("snackbar").innerHTML = "Not Activated";
		x.className = "show";
		setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);
	}
