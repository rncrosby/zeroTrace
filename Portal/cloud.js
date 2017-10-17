window.addEventListener('cloudkitloaded', function() {
	CloudKit.configure({
		containers: [{
			containerIdentifier: 'iCloud.com.fullytoasted.ZER0trace-Internal',
			apiToken: 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEbBQnh6cC/z/qF/bJCQd3/O0LjWdw uxI3QDEueOyrliH0d/GNaUISYT1Mee6AZavHnYTuB/fEmp572BwmIadSdw==',
			environment: 'development'
		}]
	});

	function ZER0traceJobs() {
		var self = this;
		var container = CloudKit.getDefaultContainer();
		var publicDB = container.publicCloudDatabase;
		self.fetchRecords = function() {
			var query = { recordType: 'CloudNote' };

			// Execute the query.
			return publicDB.performQuery(query).then(function (response) {
				if(response.hasErrors) {
					console.error(response.errors[0]);
					return;
				}
				var records = response.records;
				var numberOfRecords = records.length;
				console.log(records);
				if (numberOfRecords === 0) {
					console.error('No matching items');
					return;
				}

				self.notes(records);
			});
		};

	ko.applyBindings(new ZER0traceJobs());

});
