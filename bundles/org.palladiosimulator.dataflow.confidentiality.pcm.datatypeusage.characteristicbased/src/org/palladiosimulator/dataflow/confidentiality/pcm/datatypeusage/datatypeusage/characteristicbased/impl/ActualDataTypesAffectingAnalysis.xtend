package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.datatypeusage.characteristicbased.impl

import java.util.Map
import org.eclipse.core.runtime.IProgressMonitor
import org.osgi.service.component.annotations.Component
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysis
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall

/**
 * The analysis collects all sent and received data types that can be traced back to the actor
 * process represented by the entry level system calls. Basically, the analysis just works as
 * {@link ActualDataTypesAtELSCsAnalysis} but looks at every process and aggregates the results for
 * one entry level system call afterwards.
 */
@Component
class ActualDataTypesAffectingAnalysis extends CharacteristicBasedAnalysisBase implements DataTypeUsageAnalysis {

	new() {
		super("Actual Data Types Affecting Analysis", "00653144-7c7c-4bc5-8c50-c1a05ec5f998")
	}

	override Map<EntryLevelSystemCall, DataTypeUsageAnalysisResult> getUsedDataTypes(
		Iterable<EntryLevelSystemCall> elscs, IProgressMonitor monitor) throws InterruptedException {

		val analysisRun = new ActualDataTypesAffectingAnalysisRun(elscs)
		analysisRun.run(monitor)
	}

}
