protected boolean isHostOverUtilized(PowerHost host) {
			addHistoryEntry(host, getUtilizationThreshold());
			double totalRequestedMips = 0;
			for (Vm vm : host.getVmList()) {
				totalRequestedMips += vm.getCurrentRequestedTotalMips();
			}
			double utilization = totalRequestedMips / host.getTotalMips();
			return utilization > getUtilizationThreshold();
		}

		//new adding
		

		protected boolean isHostLowUtilized(PowerHost host) {
			//addHistoryEntry(host, getUtilizationThreshold());
			double totalRequestedMips = 0;
			for (Vm vm : host.getVmList()) {
				totalRequestedMips += vm.getCurrentRequestedTotalMips();
			}
			double utilization = totalRequestedMips / host.getTotalMips();
			return utilization < getLowUtilizationThreshold();
		}




                      protected boolean isHostLightUtilized(PowerHost host) {
			//addHistoryEntry(host, getUtilizationThreshold());
			double totalRequestedMips = 0;
			for (Vm vm : host.getVmList()) {
				totalRequestedMips += vm.getCurrentRequestedTotalMips();
			}
			double utilization = totalRequestedMips / host.getTotalMips();
			return ((utilization < getMiddleUtilizationThreshold()) && utilization < getLowUtilizationThreshold()));
		}
		//new adding


		
		protected boolean isHostMiddleUtilized(PowerHost host) {
			//addHistoryEntry(host, getUtilizationThreshold());
			double totalRequestedMips = 0;
			for (Vm vm : host.getVmList()) {
				totalRequestedMips += vm.getCurrentRequestedTotalMips();
			}
			double utilization = totalRequestedMips / host.getTotalMips();
			return utilization > getMiddleUtilizationThreshold();
		}
		//new adding	
		
		
		protected boolean isHostMediumUtilized(PowerHost host) {
			//addHistoryEntry(host, getUtilizationThreshold());
			double totalRequestedMips = 0;
			for (Vm vm : host.getVmList()) {
				totalRequestedMips += vm.getCurrentRequestedTotalMips();
			}
			double utilization = totalRequestedMips / host.getTotalMips();
			return utilization > getMediumUtilizationThreshold();
		}
		
		//new adding	
		
