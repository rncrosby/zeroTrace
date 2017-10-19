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
		// GET JOBS
		publicDatabase.fetchRecords('12345').then(function(response) {
		if (response.hasErrors) {
				// Insert error handling
				alert("Something Went Wrong");
		} else {
					var fetchedRecord = response.records[0];
					var jobTitles = fetchedRecord['fields']['allJobs']['value'];
					var jobCodes = fetchedRecord['fields']['allJobCodes']['value'];
					for (var i = 0; i < jobTitles.length; i++) {
						var driveObject = document.createElement("div");
						var line = document.createElement("div");
						line.id = "line";
						driveObject.id = "jobObject";
						var btn = document.createElement("button");
						btn.id = "jobButton";
						btn.setAttribute("code", jobCodes[i]);
						btn.addEventListener("click", skimToTime);
						var txt = document.createTextNode(jobTitles[i]);
						btn.appendChild(txt);
						driveObject.appendChild(btn);
						var container = document.getElementById('navBar');
						var subtext = document.createElement("p");
						subtext.id = "jobDate";
						var node = document.createTextNode("Wednesday, October 8");
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
	var full = window.location.href.split("?");
	var code = full[1].split("=");
		publicDatabase.fetchRecords(code[1]).then(function(response) {
		if (response.hasErrors) {
				// Insert error handling
				alert("No Video Found");
		} else {
					var fetchedRecord = response.records[0];
					console.log(fetchedRecord);
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
						// var table = document.getElementById("serials");
						// var tr = document.createElement("tr");
						// var td = document.createElement("td");
						// var txt = document.createTextNode(serials[i]);
						// var tdTime = document.createElement("td");
						// var txtTime = document.createTextNode(times[i]);
						// var btn = document.createElement("button");
						// btn.id = "timebutton";
						// btn.setAttribute("time", times[i]);
						// btn.addEventListener("click", skimToTime);
						// btn.appendChild(txtTime);
						// td.appendChild(txt);
						// tr.appendChild(td);
						// tdTime.appendChild(btn);
						// tr.appendChild(tdTime);
						// table.appendChild(tr);
					}
					var seconds = fetchedRecord['fields']['dateCompleted']['value'];
					document.getElementById("DRIVECOUNT").innerHTML = serials.length + " Drives";
					//document.getElementById("jobTitle").innerHTML = fetchedRecord['fields']['client']['value'];
					var video = document.getElementById('video');
					var source = document.createElement('source');
					source.setAttribute('src', fetchedRecord['fields']['videoURL']['value']);
					video.appendChild(source);
					video.play();
		}
	});
	});

	function skimToTime(event) {
		var button = event.target;
		var time = button.getAttribute("time");
		document.getElementById("video").currentTime = time;
	}
