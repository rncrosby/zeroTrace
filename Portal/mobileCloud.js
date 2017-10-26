function getJob() {
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
  		publicDatabase.fetchRecords(code[1]).then(function(response) {
  		if (response.hasErrors) {
  				// Insert error handling
  				alert("No Video Found");
  		} else {
  					var fetchedRecord = response.records[0];
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
  							// var driveObject = document.createElement("div");
  							// driveObject.id = "driveObject";
  							// // var btn = document.createElement("button");
  							// // btn.id = "timebutton";
  							// // btn.setAttribute("time", times[i]);
  							// //btn.addEventListener("click", skimToTime);
  							// // var txt = document.createTextNode(serials[i]);
  							// // btn.appendChild(txt);
  							// // driveObject.appendChild(btn);

  						}
  						// var driveSpacer = document.createElement("div");
  						// driveSpacer.id = "driveSpacer";
  						// var container = document.getElementById('container');
  						// container.appendChild(driveSpacer);
  						var date = fetchedRecord['fields']['jobDate']['value'];
  						document.getElementById("menuBarText").innerHTML = date;
  						document.getElementById("DRIVECOUNT").innerHTML = serials.length;
  						document.getElementById("JOBID").innerHTML = fetchedRecord['fields']['code']['value'];
  						var signature = document.getElementById('signature');
  						signature.setAttribute('src', fetchedRecord['fields']['signatueURL']['value'])
  						var playerInstance = jwplayer("videoPlayer");
  						playerInstance.setup({
  						    file: fetchedRecord['fields']['videoURL']['value'],
  						    width: "100%",
  								"skin": {
  									"name" : "myskin"
  								}
  						});
              playerInstance.setControls(true);
              playerInstance.onReady(function(){
                var controlBar = document.getElementsByClassName('videoPlayer')[0];
                controlBar.style.display = "block"
              });
  					}}

  		}
  	);
	// FINISH GET JOBS
	// START GET CURRENTJOB
	}
  function checkCode(form) {
    if (form.code.value.length < 5 || form.code.value.length > 5) {
			document.getElementById("cardHead").innerHTML = "Try Again";
      document.getElementById("cardSubHead").innerHTML = "The code should be<br>5 digits long";
		} else {

			// if (form.code.value == "99999") {
			// 	window.location.href = "jobM.html?code="+form.code.value;
			// } else {
			// 	document.getElementById("cardHead").innerHTML = "Not Activated";
      //   document.getElementById("cardSubHead").innerHTML = "This code is not active";
			// }
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
