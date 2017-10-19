window.addEventListener('cloudkitloaded', function() {
	  console.log("listening for cloudkitloaded");
	  // 2
		CloudKit.configure({
				containers: [{
					containerIdentifier: 'iCloud.com.fullytoasted.ZER0trace-Internal',
					apiToken: '2d86e7c79d5ca11b06592a0c703cdfcb3869512c75629ae151d96f924a0fb696',
					environment: 'development'
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
					console.log
					var jobTitles = fetchedRecord['fields']['allJobDates']['value'];
					var jobCodes = fetchedRecord['fields']['allJobCodes']['value'];
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
	});
	function getJob(event) {
		video.pause();
		var button = event.target;
		var code = button.getAttribute("code");
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
						var date = fetchedRecord['fields']['jobDate']['value'];
						document.getElementById("DATE").innerHTML = date;
						document.getElementById("DRIVECOUNT").innerHTML = serials.length + " Drives";
						document.getElementById("jobTitle").innerHTML = fetchedRecord['fields']['code']['value'];
						var video = document.getElementById('video');
						video.setAttribute('src', fetchedRecord['fields']['videoURL']['value']);
						video.currentTime = 0;
						video.addEventListener("canplaythrough", function() {
  					video.play();
					}, false);
					} else {
						alert("this job has not occured yet");
					}

		}
	});
	}
	function skimToTime(event) {
		var button = event.target;
		var time = button.getAttribute("time");
		document.getElementById("video").currentTime = time;
	}
	function validateForm(theForm) {
		if (theForm.code.value.length < 5 || theForm.code.value.length > 5) {
			alert("something isn't right with your code")
		} else {
			window.location.href = "player.html?code="+theForm.code.value;
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
						document.getElementById("jobTitle").innerHTML = fetchedRecord['fields']['code']['value'];
						var video = document.getElementById('video');
						video.setAttribute('src', fetchedRecord['fields']['videoURL']['value']);
						video.currentTime = 0;
						video.play();
					} else {
						alert("this job has not occured yet");
					}

		}
	});
	}
